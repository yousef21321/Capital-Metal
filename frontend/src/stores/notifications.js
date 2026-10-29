import { defineStore } from 'pinia'
import api from '@/api'

const SOUND_STORAGE_KEY = 'notification-sound-enabled'
let notificationAudioContext = null

function supportsDevicePush() {
  return typeof window !== 'undefined'
    && 'Notification' in window
    && 'serviceWorker' in navigator
    && 'PushManager' in window
}

function decodeApplicationServerKey(key) {
  const padded = `${key}${'='.repeat((4 - key.length % 4) % 4)}`
  const base64 = padded.replace(/-/g, '+').replace(/_/g, '/')
  const raw = window.atob(base64)
  return Uint8Array.from(raw, character => character.charCodeAt(0))
}

function readSoundPreference() {
  try {
    return localStorage.getItem(SOUND_STORAGE_KEY) !== 'false'
  } catch {
    return true
  }
}

export const useNotificationStore = defineStore('notifications', {
  state: () => ({
    unreadCount: 0,
    notifications: [],
    loading: false,
    pollInterval: null,
    lastUnreadCount: null,
    soundEnabled: readSoundPreference(),
    pushSupported: supportsDevicePush(),
    pushPermission: supportsDevicePush() ? Notification.permission : 'unsupported',
    pushSubscribed: false,
  }),

  actions: {
    async refreshPushState() {
      this.pushSupported = supportsDevicePush()
      this.pushPermission = this.pushSupported ? Notification.permission : 'unsupported'
      if (!this.pushSupported) {
        this.pushSubscribed = false
        return
      }

      try {
        const registration = await navigator.serviceWorker.getRegistration('/')
        this.pushSubscribed = Boolean(await registration?.pushManager.getSubscription())
      } catch {
        this.pushSubscribed = false
      }
    },

    async enableDevicePush() {
      if (!supportsDevicePush()) return { ok: false, reason: 'unsupported' }

      this.pushPermission = await Notification.requestPermission()
      if (this.pushPermission !== 'granted') {
        return { ok: false, reason: this.pushPermission }
      }

      try {
        const { data } = await api.get('/api/notifications/push-key')
        if (!data.public_key) return { ok: false, reason: 'not-configured' }

        const registration = await navigator.serviceWorker.register('/sw.js', { scope: '/' })
        await navigator.serviceWorker.ready
        let subscription = await registration.pushManager.getSubscription()
        if (!subscription) {
          subscription = await registration.pushManager.subscribe({
            userVisibleOnly: true,
            applicationServerKey: decodeApplicationServerKey(data.public_key),
          })
        }

        await api.post('/api/notifications/push-subscriptions', subscription.toJSON())
        this.pushSubscribed = true
        return { ok: true }
      } catch (error) {
        const status = error?.response?.status
        const reason = status ? `http-${status}` : error?.name || 'failed'
        console.warn('Device push setup failed:', reason)
        return { ok: false, reason }
      }
    },

    async disableDevicePush() {
      if (!supportsDevicePush()) return
      const registration = await navigator.serviceWorker.getRegistration('/')
      const subscription = await registration?.pushManager.getSubscription()
      if (!subscription) {
        this.pushSubscribed = false
        return
      }

      try {
        await api.delete('/api/notifications/push-subscriptions', { data: { endpoint: subscription.endpoint } })
      } finally {
        await subscription.unsubscribe()
        this.pushSubscribed = false
      }
    },

    async fetchUnreadCount() {
      try {
        const { data } = await api.get('/api/notifications/unread-count')
        const unreadCount = Number(data.unread_count) || 0
        if (this.lastUnreadCount !== null && unreadCount > this.lastUnreadCount && this.soundEnabled) {
          this.playNotificationSound()
        }
        this.lastUnreadCount = unreadCount
        this.unreadCount = unreadCount
      } catch {
        // silently fail
      }
    },

    async fetchNotifications(page = 1, unread = false) {
      this.loading = true
      try {
        const params = { page, per_page: 20 }
        if (unread) params.unread = true
        const { data } = await api.get('/api/notifications', { params })
        this.notifications = data.data || []
        return data
      } catch {
        return null
      } finally {
        this.loading = false
      }
    },

    async markAsRead(id) {
      try {
        await api.post(`/api/notifications/${id}/read`)
        const notif = this.notifications.find(n => n.id === id)
        if (notif && !notif.read_at) {
          notif.read_at = new Date().toISOString()
          this.unreadCount = Math.max(0, this.unreadCount - 1)
          this.lastUnreadCount = this.unreadCount
        }
      } catch {
        // silently fail
      }
    },

    async markAllAsRead() {
      try {
        await api.post('/api/notifications/read-all')
        this.notifications.forEach(n => {
          if (!n.read_at) n.read_at = new Date().toISOString()
        })
        this.unreadCount = 0
        this.lastUnreadCount = 0
      } catch {
        // silently fail
      }
    },

    startPolling(interval = 30000) {
      this.stopPolling()
      this.fetchUnreadCount()
      this.pollInterval = setInterval(() => {
        this.fetchUnreadCount()
      }, interval)
    },

    stopPolling() {
      if (this.pollInterval) {
        clearInterval(this.pollInterval)
        this.pollInterval = null
      }
    },

    setSoundEnabled(enabled) {
      this.soundEnabled = Boolean(enabled)
      try {
        localStorage.setItem(SOUND_STORAGE_KEY, String(this.soundEnabled))
      } catch {
        // Keep the in-memory preference if storage is unavailable.
      }
    },

    async playNotificationSound() {
      if (!this.soundEnabled || typeof window === 'undefined') return

      try {
        const AudioContextClass = window.AudioContext || window.webkitAudioContext
        if (!AudioContextClass) return
        if (!notificationAudioContext || notificationAudioContext.state === 'closed') {
          notificationAudioContext = new AudioContextClass()
        }
        if (notificationAudioContext.state === 'suspended') {
          await notificationAudioContext.resume()
        }

        const context = notificationAudioContext
        const start = context.currentTime + 0.015
        ;[880, 1174].forEach((frequency, index) => {
          const oscillator = context.createOscillator()
          const gain = context.createGain()
          const noteStart = start + index * 0.13
          oscillator.type = 'sine'
          oscillator.frequency.setValueAtTime(frequency, noteStart)
          gain.gain.setValueAtTime(0.0001, noteStart)
          gain.gain.exponentialRampToValueAtTime(0.12, noteStart + 0.025)
          gain.gain.exponentialRampToValueAtTime(0.0001, noteStart + 0.22)
          oscillator.connect(gain)
          gain.connect(context.destination)
          oscillator.start(noteStart)
          oscillator.stop(noteStart + 0.23)
        })
      } catch {
        // Browsers can block audio until the user interacts with the page.
      }
    },
  },
})
