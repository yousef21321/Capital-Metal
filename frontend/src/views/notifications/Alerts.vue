<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useNotificationStore } from '@/stores/notifications'
import { useAuthStore } from '@/stores/auth'

const notif = useNotificationStore()
const auth = useAuthStore()
const router = useRouter()
const notifications = ref([])
const loading = ref(true)
const pushBusy = ref(false)
const pushFeedback = ref('')
const currentPage = ref(1)
const lastPage = ref(1)
const filter = ref('all')

async function loadNotifications() {
  loading.value = true
  const unread = filter.value === 'unread'
  const result = await notif.fetchNotifications(currentPage.value, unread)
  if (result) {
    notifications.value = result.data
    currentPage.value = result.current_page
    lastPage.value = result.last_page
  }
  loading.value = false
}

function timeAgo(date) {
  const diff = Date.now() - new Date(date).getTime()
  const mins = Math.floor(diff / 60000)
  if (mins < 1) return 'just now'
  if (mins < 60) return `${mins}m ago`
  const hours = Math.floor(mins / 60)
  if (hours < 24) return `${hours}h ago`
  const days = Math.floor(hours / 24)
  if (days < 30) return `${days}d ago`
  return new Date(date).toLocaleDateString()
}

const filteredNotifications = computed(() => {
  if (filter.value === 'unread') {
    return notifications.value.filter(n => !n.read_at)
  }
  return notifications.value
})

function goToPage(page) {
  currentPage.value = page
  loadNotifications()
}

function openNotification(notification) {
  notif.markAsRead(notification.id)
  const target = notification.data?.url
  if (target) router.push(target)
}

function toggleSound() {
  const enable = !notif.soundEnabled
  notif.setSoundEnabled(enable)
  if (enable) notif.playNotificationSound()
}

function getPushFeedbackKey(result) {
  if (result.ok) return 'enabled'
  const messages = {
    denied: 'denied',
    NotAllowedError: 'denied',
    unsupported: 'unsupported',
    'not-configured': 'not-configured',
    'http-401': 'sign-in-required',
    InvalidAccessError: 'invalid-key',
    SecurityError: 'https-required',
    'http-422': 'invalid-subscription',
    AbortError: 'push-service',
    'http-500': 'server-error',
  }
  return messages[result.reason] || 'error'
}

async function toggleDeviceNotifications() {
  if (!auth.isAuthenticated) {
    pushFeedback.value = 'sign-in-required'
    return
  }

  pushBusy.value = true
  pushFeedback.value = ''

  if (notif.pushSubscribed) {
    try {
      await notif.disableDevicePush()
      pushFeedback.value = 'disabled'
    } catch {
      pushFeedback.value = 'error'
    }
    pushBusy.value = false
    return
  }

  let result
  try {
    result = await notif.enableDevicePush()
  } catch (error) {
    result = { ok: false, reason: error?.name || 'failed' }
  }
  pushFeedback.value = getPushFeedbackKey(result)
  pushBusy.value = false
}

onMounted(() => {
  notif.fetchUnreadCount()
  notif.refreshPushState()
  loadNotifications()
})
</script>

<template>
  <div class="notifications-page">
    <div class="notifications-heading mb-4">
      <div>
        <div class="notifications-eyebrow">YOUR UPDATES</div>
        <h3 class="mb-1"><CIcon icon="cil-bell" class="me-2" />Notifications</h3>
        <p class="mb-0 text-body-secondary">Keep track of your latest activity and updates.</p>
      </div>
      <div class="notification-toolbar">
        <CButton
          :color="notif.soundEnabled ? 'success' : 'secondary'"
          variant="outline"
          size="sm"
          class="notification-sound-toggle"
          :aria-pressed="notif.soundEnabled"
          @click="toggleSound"
        >
          <CIcon icon="cil-bell" class="me-1" />
          {{ notif.soundEnabled ? 'Sound on' : 'Enable sound' }}
        </CButton>
        <CButton
          v-if="notif.soundEnabled"
          color="secondary"
          variant="ghost"
          size="sm"
          class="notification-sound-test"
          @click="notif.playNotificationSound()"
        >
          Test sound
        </CButton>
        <CButton
          v-if="notif.unreadCount > 0"
          color="primary"
          size="sm"
          class="notification-mark-all"
          @click="notif.markAllAsRead(); loadNotifications()"
        >
          <CIcon icon="cil-check-all" class="me-1" />Mark all read
        </CButton>
      </div>
    </div>

    <CCard class="mb-4 device-push-card" :class="{ 'device-push-enabled': notif.pushSubscribed }">
      <CCardBody class="device-push-content">
        <div class="device-push-icon">
          <CIcon icon="cil-bell" size="xl" />
        </div>
        <div class="device-push-copy">
          <h4 class="mb-1">{{ $t('notifications.push_title') }}</h4>
          <p class="mb-0">{{ $t('notifications.push_description') }}</p>
          <small v-if="!auth.isAuthenticated" class="device-push-feedback is-error">{{ $t('notifications.push_sign_in') }}</small>
          <small v-else-if="!notif.pushSupported" class="device-push-feedback is-error">{{ $t('notifications.push_unsupported') }}</small>
          <small v-if="pushFeedback" class="device-push-feedback" :class="{ 'is-error': ['denied', 'unsupported', 'not-configured', 'sign-in-required', 'invalid-key', 'https-required', 'invalid-subscription', 'push-service', 'server-error', 'error'].includes(pushFeedback) }">
            {{ $t(`notifications.push_${pushFeedback}`) }}
          </small>
        </div>
        <CButton
          :color="notif.pushSubscribed ? 'success' : 'primary'"
          :variant="notif.pushSubscribed ? 'outline' : undefined"
          class="device-push-button"
          :disabled="pushBusy || !auth.isAuthenticated || (!notif.pushSupported && !notif.pushSubscribed)"
          @click="toggleDeviceNotifications"
        >
          <CSpinner v-if="pushBusy" size="sm" class="me-2" />
          <CIcon v-else :icon="notif.pushSubscribed ? 'cil-check-circle' : 'cil-bell'" class="me-2" />
          {{ pushBusy ? '…' : notif.pushSubscribed ? $t('notifications.push_disable') : $t('notifications.push_enable') }}
        </CButton>
      </CCardBody>
    </CCard>

    <CCard class="mb-4 notification-filters-card">
      <CCardBody class="notification-filters-body">
        <div class="d-flex gap-2 align-items-center">
          <CButton
            :class="{ active: filter === 'all' }"
            size="sm"
            class="notification-filter"
            @click="filter = 'all'; loadNotifications()"
          >
            All
          </CButton>
          <CButton
            :class="{ active: filter === 'unread' }"
            size="sm"
            class="notification-filter"
            @click="filter = 'unread'; loadNotifications()"
          >
            Unread
            <CBadge v-if="notif.unreadCount > 0" color="danger" class="ms-1">{{ notif.unreadCount }}</CBadge>
          </CButton>
        </div>
      </CCardBody>
    </CCard>

    <div v-if="loading" class="text-center py-5">
      <CSpinner />
    </div>

    <CCard v-else-if="filteredNotifications.length === 0" class="notifications-empty-card">
      <CCardBody class="text-center py-5 text-body-secondary">
        <CIcon icon="cil-bell" size="3xl" class="mb-3" />
        <h4 class="fs-5">No notifications</h4>
        <p class="mb-0">{{ filter === 'unread' ? 'All caught up!' : 'You have no notifications yet.' }}</p>
      </CCardBody>
    </CCard>

    <div v-else class="notification-list">
      <CCard
        v-for="n in filteredNotifications"
        :key="n.id"
        class="notification-card"
        :class="{ 'is-unread': !n.read_at }"
        @click="openNotification(n)"
        style="cursor: pointer"
      >
        <CCardBody class="notification-card-body">
          <div class="notification-card-icon" :class="{ unread: !n.read_at }">
            <CIcon icon="cil-bell" />
          </div>
          <div class="notification-card-content">
            <div class="d-flex align-items-center gap-2 mb-1">
              <CBadge v-if="!n.read_at" color="primary" size="sm" class="notification-new-badge">NEW</CBadge>
              <span class="fw-semibold">{{ n.title }}</span>
            </div>
            <p class="mb-0 text-body-secondary small">
              {{ n.body || n.data?.message || '' }}
            </p>
          </div>
          <small class="notification-time text-body-secondary text-nowrap">{{ timeAgo(n.created_at) }}</small>
        </CCardBody>
      </CCard>

      <div v-if="lastPage > 1" class="mt-4">
        <CPagination align="center">
          <CPaginationItem :disabled="currentPage === 1" @click="goToPage(currentPage - 1)">Previous</CPaginationItem>
          <CPaginationItem
            v-for="p in lastPage"
            :key="p"
            :active="p === currentPage"
            @click="goToPage(p)"
          >{{ p }}</CPaginationItem>
          <CPaginationItem :disabled="currentPage === lastPage" @click="goToPage(currentPage + 1)">Next</CPaginationItem>
        </CPagination>
      </div>
    </div>
  </div>
</template>

<style scoped>
.notifications-page {
  --notification-accent: #B5121B;
  --notification-surface: #fff;
  --notification-border: #e2ebe8;
  --notification-muted: #718187;
  padding-bottom: 2rem;
}
.device-push-card {
  overflow: hidden;
  border: 1px solid rgba(181, 18, 27, .22) !important;
  border-radius: 17px !important;
  background: linear-gradient(115deg, #effaf8, #fff 72%) !important;
  box-shadow: 0 8px 25px rgba(181, 18, 27, .08);
}
.device-push-content { display: flex; align-items: center; gap: 1rem; padding: 1.15rem 1.35rem; }
.device-push-icon {
  display: grid;
  flex: 0 0 48px;
  width: 48px;
  height: 48px;
  place-items: center;
  border-radius: 14px;
  color: #B5121B;
  background: rgba(181, 18, 27, .11);
}
.device-push-copy { flex: 1; min-width: 0; }
.device-push-copy h4 { color: #203a3e; font-size: 1rem; font-weight: 800; }
.device-push-copy p { color: #62777a; font-size: .88rem; }
.device-push-feedback { display: inline-block; margin-top: .35rem; color: #17775e; font-weight: 700; }
.device-push-feedback.is-error { color: #b54747; }
.device-push-button { min-height: 42px; border-radius: 11px; font-weight: 750; white-space: nowrap; }
.notifications-heading {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1.25rem;
  padding: 1.45rem 1.6rem;
  border: 1px solid var(--notification-border);
  border-radius: 18px;
  background: linear-gradient(120deg, #fff, #f2f8f6);
}
.notifications-eyebrow {
  margin-bottom: .3rem;
  color: var(--notification-accent);
  font-size: .68rem;
  font-weight: 800;
  letter-spacing: .13em;
}
.notifications-heading h3 { color: #24383d; font-weight: 800; letter-spacing: -.025em; }
.notification-toolbar { display: flex; align-items: center; justify-content: flex-end; flex-wrap: wrap; gap: .5rem; }
.notification-toolbar .btn {
  min-height: 38px;
  border-radius: 10px;
  font-weight: 700;
}
.notification-sound-toggle { border-color: #cbdcd7; }
.notification-sound-toggle.btn-success { color: #16725f; border-color: #b9ded1; background: #eaf7f1; }
.notification-mark-all { box-shadow: 0 4px 12px rgba(181,18,27,.16); }
.notification-filters-card { border-radius: 14px !important; }
.notification-filters-body { padding: .7rem .85rem; }
.notification-filter {
  min-width: 84px;
  border: 1px solid transparent;
  border-radius: 9px;
  color: var(--notification-muted);
  background: transparent;
}
.notification-filter:hover { color: var(--notification-accent); background: rgba(181,18,27,.07); }
.notification-filter.active { color: #fff; background: var(--notification-accent); box-shadow: 0 4px 10px rgba(181,18,27,.16); }
.notification-list { display: grid; gap: .75rem; }
.notification-card {
  margin: 0 !important;
  overflow: hidden;
  border: 1px solid var(--notification-border) !important;
  border-radius: 15px !important;
  background: var(--notification-surface) !important;
  cursor: pointer;
  transition: transform .18s ease, border-color .18s ease, box-shadow .18s ease;
}
.notification-card:hover { transform: translateY(-2px); border-color: rgba(181,18,27,.32) !important; box-shadow: 0 10px 24px rgba(24,57,58,.08); }
.notification-card.is-unread { border-inline-start: 4px solid var(--notification-accent) !important; }
.notification-card-body { display: flex; align-items: center; gap: 1rem; padding: 1.1rem 1.2rem; }
.notification-card-icon {
  display: grid;
  flex: 0 0 42px;
  width: 42px;
  height: 42px;
  place-items: center;
  border-radius: 13px;
  color: #66787c;
  background: #f0f4f3;
}
.notification-card-icon.unread { color: var(--notification-accent); background: rgba(181,18,27,.1); }
.notification-card-content { flex: 1; min-width: 0; }
.notification-card-content .fw-semibold { color: #2a3c41; }
.notification-card-content p { line-height: 1.55; }
.notification-new-badge { border-radius: 999px; padding: .3rem .55rem; font-size: .62rem; letter-spacing: .04em; }
.notification-time { margin-inline-start: auto; font-size: .76rem; }
.notifications-empty-card { border: 1px dashed var(--notification-border) !important; border-radius: 18px !important; }

:global([data-coreui-theme="dark"]) .notifications-page {
  --notification-surface: #202d31;
  --notification-border: #35484b;
  --notification-muted: #a8b9b7;
}
:global([data-coreui-theme="dark"]) .device-push-card {
  border-color: rgba(77, 196, 179, .24) !important;
  background: linear-gradient(115deg, #1e3335, #202d31 75%) !important;
}
:global([data-coreui-theme="dark"]) .device-push-icon { color: #74d4c9; background: rgba(77, 196, 179, .12); }
:global([data-coreui-theme="dark"]) .device-push-copy h4 { color: #e5eeec; }
:global([data-coreui-theme="dark"]) .device-push-copy p { color: #a8b9b7; }
:global([data-coreui-theme="dark"]) .notifications-heading {
  background: linear-gradient(120deg, #202d31, #23373a);
}
:global([data-coreui-theme="dark"]) .notifications-heading h3,
:global([data-coreui-theme="dark"]) .notification-card-content .fw-semibold { color: #e7efed; }
:global([data-coreui-theme="dark"]) .notification-sound-toggle.btn-success { color: #80d4bd; border-color: #315c53; background: #233d38; }
:global([data-coreui-theme="dark"]) .notification-filter { color: #afbfbc; }
:global([data-coreui-theme="dark"]) .notification-filter.active { color: #fff; background: #B5121B; }
:global([data-coreui-theme="dark"]) .notification-card-icon { color: #b3c2bf; background: #29393d; }
:global([data-coreui-theme="dark"]) .notification-card-icon.unread { color: #73d0c4; background: rgba(31,169,163,.14); }

@media (max-width: 767.98px) {
  .notifications-heading { align-items: flex-start; flex-direction: column; padding: 1.2rem; }
  .device-push-content { align-items: flex-start; flex-wrap: wrap; padding: 1rem; }
  .device-push-copy { flex-basis: calc(100% - 64px); }
  .device-push-button { width: 100%; }
  .notification-toolbar { justify-content: flex-start; width: 100%; }
  .notification-card-body { align-items: flex-start; gap: .75rem; padding: .95rem; }
  .notification-card-icon { flex-basis: 36px; width: 36px; height: 36px; border-radius: 11px; }
  .notification-time { padding-top: .2rem; font-size: .69rem; }
}
</style>
