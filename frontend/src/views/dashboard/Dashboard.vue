<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useCartStore } from '@/stores/cart'
import { useToastStore } from '@/stores/toast'
import api from '@/api'

const router = useRouter()
const cart = useCartStore()
const toast = useToastStore()
const authStore = useAuthStore()
const dashboardData = ref(null)
const loading = ref(true)
const error = ref('')
const featuredProducts = ref([])

const roleConfig = {
  admin: {
    title: 'Admin Dashboard',
    color: 'danger',
    icon: 'cil-shield-alt',
    gradient: 'linear-gradient(135deg, #e55353, #c91e1e)',
    features: ['User Management', 'Orders', 'Revenue Reports', 'System Settings'],
  },
  user: {
    title: 'User Dashboard',
    color: 'primary',
    icon: 'cil-user',
    gradient: 'linear-gradient(135deg, #b81300, #7a0d00)',
    features: ['My Orders', 'Wishlist', 'Downloads', 'Profile Settings'],
  },
  tester: {
    title: 'Tester Dashboard',
    color: 'warning',
    icon: 'cil-bug',
    gradient: 'linear-gradient(135deg, #f9b115, #d4950c)',
    features: ['Assigned Tests', 'Test Reports', 'Bug Tracking', 'Test Plans'],
  },
  designer: {
    title: 'Designer Dashboard',
    color: 'info',
    icon: 'cil-color-border',
    gradient: 'linear-gradient(135deg, #39f, #1a6bcc)',
    features: ['Projects', 'Design Assets', 'Pending Review', 'Portfolio'],
  },
  industor: {
    title: 'Industor Dashboard',
    color: 'success',
    icon: 'cil-industry',
    gradient: 'linear-gradient(135deg, #2eb85c, #1a7a3d)',
    features: ['Factories', 'Production Orders', 'Inventory', 'Supply Chain'],
  },
}

const role = computed(() => authStore.userRole || 'user')
const config = computed(() => roleConfig[role.value] || roleConfig.user)

const productImage = (product) => {
  const img = product.images?.[0]
  if (img && img.image_url) {
    return `/storage/${img.image_url}`
  }
  return null
}

const formatPrice = (product) => {
  const currency = authStore.userCurrency
  if (currency === 'USD' && parseFloat(product.price_usd) > 0) return `${parseFloat(product.price_usd).toFixed(2)} USD`
  if (parseFloat(product.price_egp) > 0) {
    if (currency === 'USD') {
      const rate = authStore.exchangeRate || 30
      return `${(parseFloat(product.price_egp) / rate).toFixed(2)} USD`
    }
    return `${parseFloat(product.price_egp).toFixed(2)} EGP`
  }
  if (parseFloat(product.price_usd) > 0) return `${parseFloat(product.price_usd).toFixed(2)} USD`
  return 'Free'
}

async function addToCart(product) {
  try {
    await cart.addItem(product.id, 1)
    toast.success(`"${product.name}" added to cart.`)
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to add to cart.')
  }
}

onMounted(async () => {
  try {
    const { data } = await api.get('/api/products', { params: { page: 1 } })
    featuredProducts.value = data.data?.slice(0, 4) || []
  } catch (_) {}

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
  <div class="dashboard-page">
    <!-- Guest welcome -->
    <div v-if="!authStore.isAuthenticated" class="guest-welcome">
      <div class="hero-section text-center py-5">
        <div class="hero-bg-shapes">
          <span class="shape shape-1"></span>
          <span class="shape shape-2"></span>
          <span class="shape shape-3"></span>
        </div>
        <div class="hero-content">
          <div class="hero-icon-wrapper mb-4">
            <CIcon icon="cil-industry" size="5xl" class="hero-icon" />
          </div>
          <h1 class="hero-title display-4 fw-bold mb-3">
            Welcome to <span class="gradient-text">FLFL_Design</span>
          </h1>
          <p class="hero-subtitle lead text-body-secondary mb-4 mx-auto" style="max-width: 600px;">
            تصفح المنتجات واطلب ما تريد بدون تسجيل دخول
            <br />
            <span class="opacity-75">Browse products and place orders without signing up</span>
          </p>
          <div class="hero-actions d-flex justify-content-center gap-3 mb-5 flex-wrap">
            <CButton color="primary" size="lg" class="btn-hero-primary" router-link to="/products">
              <CIcon icon="cil-grid" class="me-2" />Browse Products
            </CButton>
            <CButton color="outline-primary" size="lg" class="btn-hero-outline" router-link to="/pages/register">
              <CIcon icon="cil-user-plus" class="me-2" />Sign Up
            </CButton>
          </div>
        </div>
      </div>

      <CRow class="g-4 info-cards">
        <CCol sm="6" lg="4">
          <CCard class="info-card h-100" data-delay="0">
            <CCardBody class="text-center">
              <div class="info-icon-wrapper">
                <CIcon icon="cil-basket" size="3xl" class="info-icon text-primary" />
              </div>
              <h5 class="info-title">تصفح المنتجات</h5>
              <p class="text-body-secondary small mb-0">استعرض جميع المنتجات المتاحة واختر ما يناسبك</p>
            </CCardBody>
          </CCard>
        </CCol>
        <CCol sm="6" lg="4">
          <CCard class="info-card h-100" data-delay="100">
            <CCardBody class="text-center">
              <div class="info-icon-wrapper">
                <CIcon icon="cil-cart" size="3xl" class="info-icon text-success" />
              </div>
              <h5 class="info-title">أضف إلى السلة</h5>
              <p class="text-body-secondary small mb-0">أضف المنتجات إلى سلة التسوق بسهولة</p>
            </CCardBody>
          </CCard>
        </CCol>
        <CCol sm="6" lg="4">
          <CCard class="info-card h-100" data-delay="200">
            <CCardBody class="text-center">
              <div class="info-icon-wrapper">
                <CIcon icon="cil-credit-card" size="3xl" class="info-icon text-info" />
              </div>
              <h5 class="info-title">اطلب بدون حساب</h5>
              <p class="text-body-secondary small mb-0">أكمل عملية الشراء وأدخل بياناتك مباشرة بدون تسجيل</p>
            </CCardBody>
          </CCard>
        </CCol>
      </CRow>

      <div v-if="featuredProducts.length" class="featured-products mt-5">
        <div class="d-flex justify-content-between align-items-center mb-4">
          <h4 class="fw-bold mb-0">
            <CIcon icon="cil-star" class="me-2 text-primary" />Featured Products
          </h4>
          <CButton color="primary" variant="outline" size="sm" router-link to="/products" class="rounded-pill">
            View All <CIcon icon="cil-arrow-right" class="ms-1" />
          </CButton>
        </div>
        <CRow class="g-3">
          <CCol v-for="product in featuredProducts" :key="product.id" sm="6" lg="3">
            <CCard class="featured-product-card h-100">
              <div class="product-img-wrapper" @click="router.push('/products')">
                <img
                  v-if="productImage(product)"
                  :src="productImage(product)"
                  :alt="product.name"
                  class="product-img"
                />
                <div v-else class="product-img-fallback">
                  <CIcon :icon="product.product_type === 'digital' ? 'cil-cloud-download' : 'cil-box'" size="2xl" class="text-body-secondary" />
                </div>
                <div class="product-badges">
                  <span class="badge-type" :class="'badge-' + (product.product_type || 'physical')">
                    {{ product.product_type || 'Physical' }}
                  </span>
                </div>
                <div class="product-overlay">
                  <CButton color="light" size="sm" class="overlay-btn" @click.stop="router.push('/products')">
                    <CIcon icon="cil-zoom-in" class="me-1" />View
                  </CButton>
                  <CButton color="primary" size="sm" class="overlay-btn" @click.stop="addToCart(product)">
                    <CIcon icon="cil-cart" class="me-1" />Add
                  </CButton>
                </div>
              </div>
              <CCardBody class="d-flex flex-column">
                <h6 class="product-name mb-1" @click="router.push('/products')">{{ product.name }}</h6>
                <p class="product-desc text-body-secondary small flex-grow-1 mb-2">
                  {{ product.description?.slice(0, 60) || '' }}{{ product.description?.length > 60 ? '...' : '' }}
                </p>
                <div class="d-flex align-items-center justify-content-between mt-auto">
                  <span class="product-price fw-bold">{{ formatPrice(product) }}</span>
                  <span class="type-dot-sm" :class="product.product_type || 'physical'"></span>
                </div>
              </CCardBody>
            </CCard>
          </CCol>
        </CRow>
      </div>
    </div>

    <!-- Authenticated dashboard -->
    <template v-if="authStore.isAuthenticated">
      <div class="auth-dashboard-header mb-4">
        <div class="d-flex align-items-center gap-3 mb-2">
          <div class="role-icon-wrapper" :style="{ background: config.gradient }">
            <CIcon :icon="config.icon" size="xl" />
          </div>
          <div>
            <h3 class="mb-1 fw-bold">{{ config.title }}</h3>
            <p class="text-body-secondary mb-0">
              Welcome back, <strong>{{ authStore.userName }}</strong>
              <span class="mx-2">|</span>
              <span class="small">{{ authStore.userEmail }}</span>
            </p>
          </div>
        </div>
      </div>

      <CRow class="g-4 mb-4">
        <CCol v-for="(feature, idx) in config.features" :key="idx" sm="6" lg="3">
          <CCard class="feature-card h-100" :style="{ '--card-delay': idx * 100 + 'ms' }">
            <CCardBody class="text-center d-flex flex-column align-items-center justify-content-center py-4">
              <div class="feature-icon-wrapper mb-3" :style="{ background: config.gradient }">
                <CIcon icon="cil-star" size="lg" />
              </div>
              <h5 class="fw-semibold">{{ feature }}</h5>
              <p class="small text-body-secondary mb-0 text-capitalize">{{ role }} role</p>
            </CCardBody>
          </CCard>
        </CCol>
      </CRow>

      <CCard v-if="dashboardData" class="dashboard-stats-card mb-4">
        <CCardHeader class="fw-semibold">
          <CIcon icon="cil-graph" class="me-2" />{{ dashboardData.message }}
        </CCardHeader>
        <CCardBody>
          <CRow class="g-3">
            <CCol v-for="(value, key) in dashboardData.stats" :key="key" sm="6" md="4" lg="3">
              <div class="stat-item" :style="{ '--stat-color': config.gradient }">
                <div class="stat-label text-body-secondary small text-capitalize">{{ key.replace(/_/g, ' ') }}</div>
                <div class="stat-value fw-bold">{{ value }}</div>
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
