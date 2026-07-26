<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/api'
import { useI18n } from 'vue-i18n'
import { useCartStore } from '@/stores/cart'
import { useAuthStore } from '@/stores/auth'
import { useToastStore } from '@/stores/toast'
import { formatProductPrice } from '@/utils/price'

const router = useRouter()
const { t } = useI18n()
const cart = useCartStore()
const auth = useAuthStore()
const toast = useToastStore()
const products = ref([])
const loading = ref(true)
const search = ref('')
const productType = ref('')
const currentPage = ref(1)
const lastPage = ref(1)
const addingId = ref(null)
const wishlistIds = ref(new Set())

async function fetchProducts() {
  loading.value = true
  try {
    const params = { page: currentPage.value }
    if (search.value) params.search = search.value
    if (productType.value) params.product_type = productType.value
    const { data } = await api.get('/api/products', { params })
    products.value = data.data
    currentPage.value = data.current_page
    lastPage.value = data.last_page
    await fetchWishlistIds()
  } catch (e) {
    toast.error('Failed to load products.')
  } finally {
    loading.value = false
  }
}

async function fetchWishlistIds() {
  if (!auth.isAuthenticated) return
  try {
    const { data } = await api.get('/api/wishlist')
    wishlistIds.value = new Set(data.map((w) => w.product_id))
  } catch (e) {
    wishlistIds.value = new Set()
  }
}

async function toggleWishlist(productId) {
  if (!auth.isAuthenticated) {
    toast.info('Please login to use wishlist.')
    return
  }
  try {
    const { data } = await api.post('/api/wishlist/toggle', { product_id: productId })
    if (data.wishlisted) {
      wishlistIds.value.add(productId)
      toast.success('Added to wishlist.')
    } else {
      wishlistIds.value.delete(productId)
      toast.info('Removed from wishlist.')
    }
    wishlistIds.value = new Set(wishlistIds.value)
  } catch (e) {
    toast.error('Failed to update wishlist.')
  }
}

const formatPrice = formatProductPrice

function productPriceLabel(product) {
  const variants = (product.variants || []).filter(v => v.is_active)
  if (variants.length === 0) return formatPrice(product)
  const prices = variants.map(v => parseFloat(v.price_egp || 0)).filter(p => p > 0)
  if (prices.length === 0) return formatPrice(product)
  const min = Math.min(...prices)
  const max = Math.max(...prices)
  const auth = useAuthStore()
  const currency = auth.userCurrency || 'EGP'
  const rate = auth.exchangeRate || 30
  if (currency === 'USD') {
    const minUsd = (min / rate).toFixed(2)
    const maxUsd = (max / rate).toFixed(2)
    return min === max ? `${minUsd} USD` : `From ${minUsd} USD`
  }
  return min === max ? `${min.toFixed(2)} EGP` : `From ${min.toFixed(2)} EGP`
}

const productImage = (product) => {
  const img = product.images?.[0]
  if (img && img.image_url) {
    return `/storage/${img.image_url}`
  }
  return null
}

async function addToCart(product) {
  const variants = (product.variants || []).filter(v => v.is_active)
  if (variants.length > 0) {
    viewProduct(product.slug)
    return
  }
  addingId.value = product.id
  try {
    await cart.addItem(product.id, 1)
    toast.success(`"${product.name}" added to cart.`)
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to add to cart.')
  } finally {
    addingId.value = null
  }
}

function shareProduct(product) {
  const url = `${window.location.origin}/products/${product.slug}`
  if (navigator.share) {
    navigator.share({ title: product.name, url })
  } else {
    navigator.clipboard.writeText(url).then(() => {
      toast.success(t('products.link_copied'))
    })
  }
  viewProduct(product.slug)
}

function viewProduct(slug) {
  router.push(`/products/${slug}`)
}

onMounted(fetchProducts)
</script>

<template>
  <div class="products-page">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1 fw-bold">
          <CIcon icon="cil-grid" class="me-2 text-primary" />{{ $t('products.title') }}
        </h3>
        <p class="text-body-secondary mb-0">{{ $t('products.desc') }}</p>
      </div>
    </div>

    <CCard class="mb-4 search-card">
      <CCardBody>
        <CRow class="g-3 align-items-center">
          <CCol md="5">
            <div class="input-group search-input-group">
              <span class="input-group-text bg-transparent border-end-0"><CIcon icon="cil-search" /></span>
              <input v-model="search" class="form-control border-start-0 ps-0" :placeholder="$t('products.search')" @input="fetchProducts" />
            </div>
          </CCol>
          <CCol md="7">
            <div class="filter-buttons d-flex align-items-center gap-2 flex-wrap">
              <span class="filter-label small text-body-secondary fw-semibold me-1">{{ $t('products.type') }}</span>
              <button
                class="filter-btn"
                :class="{ active: productType === '' }"
                @click="productType = ''; fetchProducts()"
              >
                <CIcon icon="cil-grid" class="me-1" />{{ $t('products.all') }}
              </button>
              <button
                class="filter-btn"
                :class="{ active: productType === 'physical' }"
                @click="productType = 'physical'; fetchProducts()"
              >
                <CIcon icon="cil-box" class="me-1" />{{ $t('products.physical') }}
              </button>
              <button
                class="filter-btn"
                :class="{ active: productType === 'digital' }"
                @click="productType = 'digital'; fetchProducts()"
              >
                <CIcon icon="cil-cloud-download" class="me-1" />{{ $t('products.digital') }}
              </button>
              <span class="vr mx-2"></span>
              <CButton color="primary" size="sm" class="btn-search" @click="fetchProducts">
                <CIcon icon="cil-search" class="me-1" />{{ $t('products.search_btn') }}
              </CButton>
            </div>
          </CCol>
        </CRow>
      </CCardBody>
    </CCard>

    <div v-if="loading" class="text-center py-5">
      <div class="loading-spinner">
        <CSpinner color="primary" />
      </div>
    </div>

    <div v-else-if="!products.length" class="text-center py-5 empty-state">
      <div class="empty-icon-wrapper mb-3">
        <CIcon icon="cil-cart" size="3xl" />
      </div>
      <h4 class="fw-semibold">{{ $t('products.no_results') }}</h4>
      <p class="text-body-secondary">{{ $t('products.no_results_desc') }}</p>
    </div>

    <CRow v-else class="g-4 products-grid">
      <CCol v-for="product in products" :key="product.id" sm="6" lg="4" xl="3" class="product-col">
        <CCard class="product-card h-100">
          <div class="product-img-wrapper" @click="viewProduct(product.slug)">
            <img
              v-if="productImage(product)"
              :src="productImage(product)"
              :alt="product.name"
              class="product-img"
              loading="lazy"
              width="400"
              height="240"
            />
            <div v-else class="product-img-fallback">
              <CIcon :icon="product.product_type === 'digital' ? 'cil-cloud-download' : 'cil-box'" size="3xl" class="text-body-secondary" />
              <span class="small text-body-secondary mt-2">{{ $t('products.' + product.product_type) }}</span>
            </div>
            <div class="product-badges">
              <span v-if="product.product_type === 'digital'" class="badge-type badge-digital">
                <CIcon icon="cil-cloud-download" size="sm" class="me-1" />{{ $t('products.digital') }}
              </span>
              <span v-else class="badge-type badge-physical">
                <CIcon icon="cil-box" size="sm" class="me-1" />{{ $t('products.physical') }}
              </span>
            </div>
            <div class="product-actions-overlay">
              <CButton color="light" size="sm" class="action-btn action-view" @click.stop="viewProduct(product.slug)">
                <CIcon icon="cil-zoom-in" />
              </CButton>
              <CButton
                color="light"
                size="sm"
                class="action-btn action-wishlist"
                :class="{ liked: wishlistIds.has(product.id) }"
                @click.stop="toggleWishlist(product.id)"
              >
                <CIcon :icon="wishlistIds.has(product.id) ? 'cil-heart' : 'cil-heart'" />
              </CButton>
              <CButton
                color="light"
                size="sm"
                class="action-btn action-share"
                :title="$t('products.share')"
                @click.stop="shareProduct(product)"
              >
                <CIcon icon="cil-link" />
              </CButton>
              <CButton
                color="primary"
                size="sm"
                class="action-btn action-cart"
                :disabled="addingId === product.id"
                @click.stop="addToCart(product)"
              >
                <CSpinner v-if="addingId === product.id" size="sm" />
                <CIcon v-else icon="cil-cart" />
              </CButton>
            </div>
          </div>
          <CCardBody class="d-flex flex-column">
            <div class="product-type-row d-flex align-items-center gap-2 mb-1">
              <span class="type-dot" :class="product.product_type"></span>
              <span class="small text-body-secondary text-capitalize">{{ product.product_type || 'physical' }}</span>
              <span v-if="product.type_sample" class="badge bg-info ms-1">{{ product.type_sample }}</span>
            </div>
            <CCardTitle class="product-name mb-1" @click="viewProduct(product.slug)">{{ product.name }}</CCardTitle>
            <div class="product-rating d-flex align-items-center gap-1 mb-1">
              <CIcon v-for="i in 5" :key="i" :icon="i <= (product.rating || 4) ? 'cil-star' : 'cil-star-half'" size="sm" class="star-icon" />
              <span class="small text-body-secondary ms-1">({{ product.reviews_count || 0 }})</span>
            </div>
            <p class="product-desc text-body-secondary small flex-grow-1">
              {{ product.description?.slice(0, 70) || $t('products.no_description') }}{{ product.description?.length > 70 ? '...' : '' }}
            </p>
            <div class="d-flex justify-content-between align-items-center mt-auto pt-2">
              <div class="product-price-row">
                <h4 class="product-price mb-0 fs-5">{{ productPriceLabel(product) }}</h4>
                <small v-if="product.compare_price" class="text-decoration-line-through text-body-secondary ms-1">{{ product.compare_price }}</small>
              </div>
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
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>

    <div v-if="lastPage > 1" class="mt-4">
      <CPagination align="center" class="products-pagination">
        <CPaginationItem :disabled="currentPage === 1" @click="currentPage--; fetchProducts()">{{ $t('products.previous') }}</CPaginationItem>
        <CPaginationItem v-for="page in lastPage" :key="page" :active="page === currentPage" @click="currentPage = page; fetchProducts()">{{ page }}</CPaginationItem>
        <CPaginationItem :disabled="currentPage === lastPage" @click="currentPage++; fetchProducts()">{{ $t('products.next') }}</CPaginationItem>
      </CPagination>
    </div>
  </div>
</template>
