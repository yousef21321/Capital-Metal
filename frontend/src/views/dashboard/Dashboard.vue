<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useAuthStore } from '@/stores/auth'
import { useCartStore } from '@/stores/cart'
import { useToastStore } from '@/stores/toast'
import api from '@/api'
import { RouterLink, useRoute, useRouter } from 'vue-router'

const { t } = useI18n()
const router = useRouter()
const cart = useCartStore()
const toast = useToastStore()
const authStore = useAuthStore()
const dashboardData = ref(null)
const loading = ref(true)
const error = ref('')
const featuredProducts = ref([])
const heroImages = ref([])

const featureKeys = {
  admin: ['dashboard.feature_user_mgmt', 'dashboard.feature_orders', 'dashboard.feature_revenue', 'dashboard.feature_settings'],
  user: ['dashboard.feature_my_orders', 'dashboard.feature_wishlist', 'dashboard.feature_downloads', 'dashboard.feature_profile'],
  tester: ['dashboard.feature_tests', 'dashboard.feature_reports', 'dashboard.feature_bugs', 'dashboard.feature_test_plans'],
  designer: ['dashboard.feature_projects', 'dashboard.feature_assets', 'dashboard.feature_pending_review', 'dashboard.feature_portfolio'],
  industor: ['dashboard.feature_factories', 'dashboard.feature_production', 'dashboard.feature_inventory', 'dashboard.feature_supply'],
}

const roleConfig = {
  admin: {
    color: 'danger',
    icon: 'cil-shield-alt',
    gradient: 'linear-gradient(135deg, #e55353, #c91e1e)',
  },
  user: {
    color: 'primary',
    icon: 'cil-user',
    gradient: 'linear-gradient(135deg, #b81300, #7a0d00)',
  },
  tester: {
    color: 'warning',
    icon: 'cil-bug',
    gradient: 'linear-gradient(135deg, #f9b115, #d4950c)',
  },
  designer: {
    color: 'info',
    icon: 'cil-color-border',
    gradient: 'linear-gradient(135deg, #39f, #1a6bcc)',
  },
  industor: {
    color: 'success',
    icon: 'cil-industry',
    gradient: 'linear-gradient(135deg, #2eb85c, #1a7a3d)',
  },
}

const role = computed(() => authStore.userRole || 'user')
const config = computed(() => roleConfig[role.value] || roleConfig.user)
const dashboardTitle = computed(() => `dashboard.role_${role.value}`)
const features = computed(() => (featureKeys[role.value] || featureKeys.user).map(k => t(k)))

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
  return t('dashboard.free')
}

async function addToCart(product) {
  try {
    await cart.addItem(product.id, 1)
    toast.success(t('dashboard.added_to_cart', { name: product.name }))
  } catch (e) {
    toast.error(e.response?.data?.message || t('dashboard.add_to_cart_failed'))
  }
}

function shareProduct(product) {
  const url = `${window.location.origin}/#/products/${product.id}`
  if (navigator.share) {
    navigator.share({ title: product.name, url })
  } else {
    navigator.clipboard.writeText(url).then(() => {
      toast.success(t('products.link_copied'))
    })
  }
  router.push(`/products/${product.id}`)
}

onMounted(async () => {
  try {
    const { data } = await api.get('/api/products', { params: { page: 1 } })
    featuredProducts.value = data.data?.slice(0, 4) || []
  } catch (_) {}
  try {
    const { data } = await api.get('/api/hero-images')
    heroImages.value = data
  } catch (_) {}
  notifInterval = setInterval(addDummyPurchase, 10000)

  if (!authStore.isAuthenticated) {
    loading.value = false
    return
  }
  try {
    const endpoint = `/api/${role.value}/dashboard`
    const { data } = await api.get(endpoint)
    dashboardData.value = data
  } catch (e) {
    error.value = t('dashboard.load_error')
  } finally {
    loading.value = false
  }
})

onUnmounted(() => {
  clearInterval(notifInterval)
})

const dummyUsers = ['Ahmed', 'Mariam', 'Omar', 'Nour', 'Khaled', 'Laila', 'Youssef', 'Sara', 'Adam', 'Huda', 'Ali', 'Rana']
const dummyProducts = ['Modern Logo Pack', 'Business Card Template', 'Brand Identity Kit', 'Social Media Bundle', 'UI Dashboard Kit', 'Icon Set Pro', 'Mockup Generator', 'Font Pack Premium', 'Animation Reel', '3D Model Pack']
const notifications = ref([])
let notifId = 0

function addDummyPurchase() {
  const user = dummyUsers[Math.floor(Math.random() * dummyUsers.length)]
  const product = dummyProducts[Math.floor(Math.random() * dummyProducts.length)]
  const id = ++notifId
  const amount = (Math.random() * 200 + 10).toFixed(2)
  notifications.value.push({ id, user, product, amount })
  setTimeout(() => {
    notifications.value = notifications.value.filter(n => n.id !== id)
  }, 5000)
}

let notifInterval
</script>

<template>
  <div class="dashboard-page">
    <!-- Guest welcome -->
    <div v-if="!authStore.isAuthenticated" class="guest-welcome">
      <div class="hero-section text-center py-5">
        <div class="hero-bg-shapes">
          <img
            v-for="img in heroImages"
            :key="img.id"
            :src="`/storage/${img.image_url}`"
            class="hero-bg-img"
            loading="lazy"
            alt=""
          />
          <span class="shape shape-1"></span>
          <span class="shape shape-2"></span>
          <span class="shape shape-3"></span>
        </div>
        <div class="hero-content">
          <div class="hero-icon-wrapper mb-4">
            <!-- <CIcon icon="cil-industry" size="5xl" class="hero-icon" /> -->
          </div>
          <h1 class="hero-title display-4 fw-bold mb-3">
            {{ $t('dashboard.welcome') }}
          </h1>
          <!-- <p class="hero-subtitle lead text-body-secondary mb-4 mx-auto" style="max-width: 600px;">
            {{ $t('dashboard.browse_products_desc') }}
          </p> -->
          <div class="hero-actions d-flex justify-content-center gap-3 mb-5 flex-wrap">
            <RouterLink to="/products">
              <CButton color="primary" size="lg" class="btn-hero-primary">
                <CIcon icon="cil-grid" class="me-2" />{{ $t('dashboard.browse_products') }}
              </CButton>
            </RouterLink>
            <RouterLink to="/pages/register">
              <CButton color="outline-primary" size="lg" class="btn-hero-outline">
                <CIcon icon="cil-user-plus" class="me-2" />{{ $t('dashboard.sign_up') }}
              </CButton>
            </RouterLink>
          </div>
        </div>
      </div>

      <div class="featured-products-container mt-5">
        <div class="d-flex justify-content-between align-items-center mb-4">
          <h2 class="fw-bold mb-0 fs-5">
            <CIcon icon="cil-star" class="me-2 text-primary" />{{ $t('dashboard.featured_products') }}
          </h2>
          <RouterLink to="/products">
            <CButton color="primary" variant="outline" size="sm" class="rounded-pill">
              {{ $t('dashboard.view_all') }} <CIcon icon="cil-arrow-right" class="ms-1" />
            </CButton>
          </RouterLink>
        </div>
        <CRow v-if="featuredProducts.length" class="g-3">
          <CCol v-for="product in featuredProducts" :key="product.id" sm="6" lg="3">
            <CCard class="featured-product-card h-100">
              <RouterLink to="/products">
                <div class="product-img-wrapper">
                  <img
                    v-if="productImage(product)"
                    :src="productImage(product)"
                    :alt="product.name"
                    class="product-img"
                    loading="lazy"
                    width="320"
                    height="160"
                  />
                  <div v-else class="product-img-fallback">
                    <CIcon :icon="product.product_type === 'digital' ? 'cil-cloud-download' : 'cil-box'" size="2xl" class="text-body-secondary" />
                  </div>
                  <div class="product-badges">
                    <span class="badge-type" :class="'badge-' + (product.product_type || 'physical')">
                      {{ $t('products.' + (product.product_type || 'physical')) }}
                    </span>
                  </div>
                  <div class="product-overlay">
                    <CButton color="light" size="sm" class="overlay-btn">
                      <CIcon icon="cil-zoom-in" class="me-1" />{{ $t('products.view') }}
                    </CButton>
                    <CButton color="light" size="sm" class="overlay-btn" :title="$t('products.share')" @click.stop="shareProduct(product)">
                      <CIcon icon="cil-link" class="me-1" />{{ $t('products.share') }}
                    </CButton>
                    <CButton color="primary" size="sm" class="overlay-btn" @click.stop="addToCart(product)">
                      <CIcon icon="cil-cart" class="me-1" />{{ $t('products.add_to_cart') }}
                    </CButton>
                  </div>
                </div>
              </RouterLink>
              <CCardBody class="d-flex flex-column">
                <RouterLink to="/products">
                  <h3 class="product-name mb-1 fs-6">{{ product.name }}</h3>
                </RouterLink>
                <p class="product-desc text-body-secondary small flex-grow-1 mb-2">
                  {{ product.description?.slice(0, 60) || '' }}{{ product.description?.length > 60 ? '...' : '' }}
                </p>
                <div class="d-flex align-items-center justify-content-between mt-auto">
                  <span class="product-price fw-bold">{{ formatPrice(product) }}</span>
                  <div class="d-flex align-items-center gap-2">
                    <span class="type-dot-sm" :class="product.product_type || 'physical'"></span>
                    <CButton
                      color="light"
                      size="sm"
                      class="btn-share-product"
                      :title="$t('products.share')"
                      @click.stop="shareProduct(product)"
                    >
                      <CIcon icon="cil-share-alt" class="me-1" />{{ $t('products.share') }}
                    </CButton>
                  </div>
                </div>
              </CCardBody>
            </CCard>
          </CCol>
        </CRow>
        <CRow v-else class="g-3">
          <CCol v-for="n in 4" :key="'skeleton-' + n" sm="6" lg="3">
            <CCard class="featured-product-card h-100 skeleton-card">
              <div class="skeleton-img"></div>
              <CCardBody>
                <div class="skeleton-line skeleton-line-title"></div>
                <div class="skeleton-line skeleton-line-text"></div>
                <div class="skeleton-line skeleton-line-short"></div>
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
            <h2 class="mb-1 fw-bold fs-5">{{ $t(dashboardTitle) }}</h2>
            <p class="text-body-secondary mb-0">
              {{ $t('dashboard.welcome_back') }}, <strong>{{ authStore.userName }}</strong>
              <span class="mx-2">|</span>
              <span class="small">{{ authStore.userEmail }}</span>
            </p>
          </div>
        </div>
      </div>

      <CRow class="g-4 mb-4">
        <CCol v-for="(feature, idx) in features" :key="idx" sm="6" lg="3">
          <CCard class="feature-card h-100" :style="{ '--card-delay': idx * 100 + 'ms' }">
            <CCardBody class="text-center d-flex flex-column align-items-center justify-content-center py-4">
              <div class="feature-icon-wrapper mb-3" :style="{ background: config.gradient }">
                <CIcon icon="cil-star" size="lg" />
              </div>
              <h3 class="fw-semibold fs-6">{{ feature }}</h3>
              <p class="small text-body-secondary mb-0 text-capitalize">{{ $t('dashboard.role_label', { role }) }}</p>
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

      <CCard v-else-if="!loading" class="mb-4">
        <CCardBody>
          <p class="text-body-secondary mb-0">{{ error || $t('dashboard.no_data') }}</p>
        </CCardBody>
      </CCard>

      <div v-if="loading" class="text-center dashboard-loading-placeholder py-5">
        <CSpinner color="primary" />
        <p class="mt-2 text-body-secondary">{{ $t('dashboard.loading') }}</p>
      </div>
    </template>

    <!-- WhatsApp floating button -->
    <a
      href="https://wa.me/201109055371"
      target="_blank"
      rel="noopener noreferrer"
      class="whatsapp-float"
      aria-label="WhatsApp"
    >
      <svg viewBox="0 0 24 24" fill="white" width="28" height="28">
        <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
      </svg>
    </a>



    <!-- Purchase notifications -->
    <div class="notification-stack">
      <TransitionGroup name="notif">
        <div
          v-for="n in notifications"
          :key="n.id"
          class="purchase-notif"
        >
          <div class="notif-avatar">{{ n.user[0] }}</div>
          <div class="notif-body">
            <p class="notif-text">
              <strong>{{ n.user }}</strong> {{ $t('dashboard.purchased') }}
              <strong>{{ n.product }}</strong>
            </p>
            <span class="notif-price">${{ n.amount }}</span>
          </div>
        </div>
      </TransitionGroup>
    </div>
  </div>
</template>
