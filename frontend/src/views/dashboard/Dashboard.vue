<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import api from '@/api'

const authStore = useAuthStore()
const dashboardData = ref(null)
const loading = ref(true)
const error = ref('')

const roleConfig = {
  admin: {
    title: 'Admin Dashboard',
    color: 'danger',
    icon: 'cil-shield-alt',
    features: ['User Management', 'Orders', 'Revenue Reports', 'System Settings'],
  },
  user: {
    title: 'User Dashboard',
    color: 'primary',
    icon: 'cil-user',
    features: ['My Orders', 'Wishlist', 'Downloads', 'Profile Settings'],
  },
  tester: {
    title: 'Tester Dashboard',
    color: 'warning',
    icon: 'cil-bug',
    features: ['Assigned Tests', 'Test Reports', 'Bug Tracking', 'Test Plans'],
  },
  designer: {
    title: 'Designer Dashboard',
    color: 'info',
    icon: 'cil-color-border',
    features: ['Projects', 'Design Assets', 'Pending Review', 'Portfolio'],
  },
  industor: {
    title: 'Industor Dashboard',
    color: 'success',
    icon: 'cil-industry',
    features: ['Factories', 'Production Orders', 'Inventory', 'Supply Chain'],
  },
}

const role = computed(() => authStore.userRole || 'user')
const config = computed(() => roleConfig[role.value] || roleConfig.user)

function getBorderClass(color) {
  const map = { danger: 'border-start-danger', primary: 'border-start-primary', warning: 'border-start-warning', info: 'border-start-info', success: 'border-start-success' }
  return map[color] || 'border-start-primary'
}

onMounted(async () => {
  if (!authStore.isAuthenticated) return
  try {
    const endpoint = `/api/${role.value}/dashboard`
    const { data } = await api.get(endpoint)
    dashboardData.value = data
  } catch (e) {
    error.value = 'Failed to load dashboard data'
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div>
    <h3 class="mb-4">
      <CIcon :icon="config.icon" size="xl" class="me-2" />
      {{ config.title }}
    </h3>
    <p class="text-body-secondary mb-4">Welcome back, <strong>{{ authStore.userName }}</strong> ({{ authStore.userEmail }})</p>

    <CRow class="mb-4">
      <CCol v-for="(feature, idx) in config.features" :key="idx" sm="6" lg="3">
        <CCard class="mb-3" :color="config.color" text-color="white">
          <CCardBody class="text-center">
            <h5>{{ feature }}</h5>
            <p class="small mb-0">Role: {{ role }}</p>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>

    <CCard v-if="dashboardData" class="mb-4">
      <CCardHeader><strong>{{ dashboardData.message }}</strong></CCardHeader>
      <CCardBody>
        <CRow>
          <CCol v-for="(value, key) in dashboardData.stats" :key="key" sm="4" class="mb-3">
            <div class="border-start border-start-4 py-1 px-3" :class="getBorderClass(config.color)">
              <div class="text-body-secondary small text-capitalize">{{ key.replace('_', ' ') }}</div>
              <div class="fs-4 fw-semibold">{{ value }}</div>
            </div>
          </CCol>
        </CRow>
      </CCardBody>
    </CCard>

    <CCard v-if="!loading && !dashboardData" class="mb-4">
      <CCardBody>
        <p class="text-body-secondary mb-0">{{ error || 'No dashboard data available.' }}</p>
      </CCardBody>
    </CCard>

    <div v-if="loading" class="text-center py-5">
      <CSpinner color="primary" />
      <p class="mt-2 text-body-secondary">Loading dashboard...</p>
    </div>
  </div>
</template>
