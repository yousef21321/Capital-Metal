import { defineStore } from 'pinia'
import api from '@/api'

export const useNotificationStore = defineStore('notifications', {
  state: () => ({
    unreadCount: 0,
    notifications: [],
    loading: false,
    pollInterval: null,
  }),

  actions: {
    async fetchUnreadCount() {
      try {
        const { data } = await api.get('/api/notifications/unread-count')
        this.unreadCount = data.unread_count
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
  },
})
