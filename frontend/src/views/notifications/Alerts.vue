<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useNotificationStore } from '@/stores/notifications'

const notif = useNotificationStore()
const notifications = ref([])
const loading = ref(true)
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

onMounted(() => {
  loadNotifications()
})
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h3 class="mb-0">
        <CIcon icon="cil-bell" class="me-2" />
        Notifications
      </h3>
      <CButton
        v-if="notif.unreadCount > 0"
        color="primary"
        size="sm"
        variant="outline"
        @click="notif.markAllAsRead(); loadNotifications()"
      >
        <CIcon icon="cil-check-all" class="me-1" />Mark All Read
      </CButton>
    </div>

    <CCard class="mb-4 shadow-sm">
      <CCardBody class="py-2">
        <div class="d-flex gap-2">
          <CButton
            :color="filter === 'all' ? 'primary' : 'outline-secondary'"
            size="sm"
            @click="filter = 'all'; loadNotifications()"
          >
            All
          </CButton>
          <CButton
            :color="filter === 'unread' ? 'primary' : 'outline-secondary'"
            size="sm"
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

    <div v-else-if="filteredNotifications.length === 0" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-bell" size="3xl" class="mb-3" />
      <h4 class="fs-5">No notifications</h4>
      <p class="mb-0">{{ filter === 'unread' ? 'All caught up!' : 'You have no notifications yet.' }}</p>
    </div>

    <div v-else>
      <CCard
        v-for="n in filteredNotifications"
        :key="n.id"
        class="mb-2 notification-card"
        :class="{ 'border-start border-start-4 border-start-primary': !n.read_at }"
        @click="notif.markAsRead(n.id)"
        style="cursor: pointer"
      >
        <CCardBody class="py-3">
          <div class="d-flex justify-content-between align-items-start">
            <div class="flex-grow-1 me-3">
              <div class="d-flex align-items-center gap-2 mb-1">
                <CBadge v-if="!n.read_at" color="primary" size="sm" class="px-1">NEW</CBadge>
                <span class="fw-semibold">{{ n.title }}</span>
              </div>
              <p class="mb-0 text-body-secondary small">
                {{ n.body || n.data?.message || '' }}
              </p>
            </div>
            <small class="text-body-secondary text-nowrap">{{ timeAgo(n.created_at) }}</small>
          </div>
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
.notification-card:hover {
  background-color: var(--cui-body-bg, #f8f9fa);
}
</style>
