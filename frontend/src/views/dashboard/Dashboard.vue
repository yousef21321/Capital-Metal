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
  if (!authStore.isAuthenticated) {
    loading.value = false
    return
  }
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
    <!-- Guest welcome -->
    <div v-if="!authStore.isAuthenticated">
      <div class="text-center py-5">
        <CIcon icon="cil-industry" size="5xl" class="text-primary mb-4" />
        <h1 class="display-5 fw-bold mb-3">Welcome to FLFL_Design</h1>
        <p class="lead text-body-secondary mb-4">
          تصفح المنتجات واطلب ما تريد بدون تسجيل دخول<br />
          Browse products and place orders without signing up
        </p>
        <div class="d-flex justify-content-center gap-3 mb-5">
          <CButton color="primary" size="lg" router-link to="/products">
            <CIcon icon="cil-grid" class="me-2" />تصفح المنتجات / Browse Products
          </CButton>
          <CButton color="outline-primary" size="lg" router-link to="/pages/register">
            <CIcon icon="cil-user-plus" class="me-2" />إنشاء حساب / Sign Up
          </CButton>
        </div>
      </div>

      <CRow class="g-4">
        <CCol sm="6" lg="4">
          <CCard class="shadow-sm text-center h-100">
            <CCardBody>
              <CIcon icon="cil-basket" size="3xl" class="text-primary mb-3" />
              <h5>تصفح المنتجات</h5>
              <p class="text-body-secondary small mb-0">استعرض جميع المنتجات المتاحة واختر ما يناسبك</p>
            </CCardBody>
          </CCard>
        </CCol>
        <CCol sm="6" lg="4">
          <CCard class="shadow-sm text-center h-100">
            <CCardBody>
              <CIcon icon="cil-cart" size="3xl" class="text-success mb-3" />
              <h5>أضف إلى السلة</h5>
              <p class="text-body-secondary small mb-0">أضف المنتجات إلى سلة التسوق بسهولة</p>
            </CCardBody>
          </CCard>
        </CCol>
        <CCol sm="6" lg="4">
          <CCard class="shadow-sm text-center h-100">
            <CCardBody>
              <CIcon icon="cil-credit-card" size="3xl" class="text-info mb-3" />
              <h5>اطلب بدون حساب</h5>
              <p class="text-body-secondary small mb-0">أكمل عملية الشراء وأدخل بياناتك مباشرة بدون تسجيل</p>
            </CCardBody>
          </CCard>
        </CCol>
      </CRow>
    </div>

    <!-- Authenticated dashboard -->
    <template v-if="authStore.isAuthenticated">
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
    </template>
  </div>
</template>
