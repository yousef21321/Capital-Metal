<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '@/api'
import { useCartStore } from '@/stores/cart'
import { useAuthStore } from '@/stores/auth'
import { useToastStore } from '@/stores/toast'
import { formatProductPrice } from '@/utils/price'
import { imageSrcSet, thumbImageUrl } from '@/utils/image'
import { flyToCart } from '@/utils/flyToCart'
import fbPixel from '@/utils/fbPixel'

const route = useRoute()
const router = useRouter()
const cart = useCartStore()
const auth = useAuthStore()
const toast = useToastStore()

const category = ref(null)
const loading = ref(true)
const error = ref('')
const addingId = ref(null)
const productType = ref('')

function shareCategory() {
  const url = `${window.location.origin}/main-categories/${route.params.slug}`
  if (navigator.share) {
    navigator.share({ title: category.value?.name || 'Category', url })
  } else {
    navigator.clipboard.writeText(url).then(() => {
      toast.success('Link copied to clipboard!')
    })
  }
}

const products = computed(() => {
  let list = (category.value?.products || []).filter(p => p.status === 'published')
  if (productType.value) {
    list = list.filter(p => p.product_type === productType.value)
  }
  return list
})

const formatPrice = formatProductPrice

function productPriceLabel(product) {
  const hasBasePrice = parseFloat(product.price_egp) > 0 || parseFloat(product.price_usd) > 0
  if (hasBasePrice) return formatPrice(product)
  const variants = (product.variants || []).filter(v => v.is_active)
  if (variants.length === 0) return formatPrice(product)
  const prices = variants.map(v => parseFloat(v.price_egp || 0)).filter(p => p > 0)
  if (prices.length === 0) return formatPrice(product)
  const min = Math.min(...prices)
  const max = Math.max(...prices)
  const currency = auth.userCurrency || 'EGP'
  const rate = auth.exchangeRate || 30
  if (currency === 'USD') {
    const minUsd = (min / rate).toFixed(2)
    const maxUsd = (max / rate).toFixed(2)
    return min === max ? `${minUsd} USD` : `From ${minUsd} USD`
  }
  return min === max ? `${min.toFixed(2)} EGP` : `From ${min.toFixed(2)} EGP`
}

function productFakePriceLabel(product) {
  const currency = auth.userCurrency || 'EGP'
  const rate = auth.exchangeRate || 30
  const hasBaseFake = parseFloat(product.fake_price_egp) > 0 || parseFloat(product.fake_price_usd) > 0
  if (!hasBaseFake) {
    const variants = (product.variants || []).filter(v => v.is_active)
    if (variants.length === 0) return null
    const fakePrices = variants.map(v => parseFloat(v.fake_price_egp || 0)).filter(p => p > 0)
    if (fakePrices.length === 0) return null
    const min = Math.min(...fakePrices)
    const max = Math.max(...fakePrices)
    if (currency === 'USD') {
      const minUsd = (min / rate).toFixed(2)
      const maxUsd = (max / rate).toFixed(2)
      return min === max ? `${minUsd} USD` : `From ${minUsd} USD`
    }
    return min === max ? `${min.toFixed(2)} EGP` : `From ${min.toFixed(2)} EGP`
  }
  if (currency === 'USD') {
    if (parseFloat(product.fake_price_usd) > 0) return `${parseFloat(product.fake_price_usd).toFixed(2)} USD`
    if (parseFloat(product.fake_price_egp) > 0) return `${(parseFloat(product.fake_price_egp) / rate).toFixed(2)} USD`
  }
  if (parseFloat(product.fake_price_egp) > 0) return `${parseFloat(product.fake_price_egp).toFixed(2)} EGP`
  if (parseFloat(product.fake_price_usd) > 0) return `${(parseFloat(product.fake_price_usd) * rate).toFixed(2)} EGP`
  return null
}

const productImage = (product) => {
  const img = product.images?.[0]
  if (img && img.image_url) return `/storage/${img.image_url}`
  return null
}

function viewProduct(slug) {
  router.push(`/products/${slug}`)
}

async function addToCart(product, event) {
  const variants = (product.variants || []).filter(v => v.is_active)
  if (variants.length > 0) {
    viewProduct(product.slug)
    return
  }
  addingId.value = product.id
  try {
    await cart.addItem(product.id, 1)
    flyToCart({ from: event?.currentTarget || null, imageSrc: product.images?.[0]?.image_url ? `/storage/${product.images[0].image_url}` : null })
    toast.success(`"${product.name}" added to cart.`)
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to add to cart.')
  } finally {
    addingId.value = null
  }
}

async function fetchCategory() {
  loading.value = true
  try {
    const { data } = await api.get(`/api/main-categories/${route.params.slug}`)
    category.value = data
  } catch (e) {
    error.value = 'Failed to load category'
  } finally {
    loading.value = false
  }
}

onMounted(fetchCategory)

watch(() => route.params.slug, (newSlug) => {
  if (newSlug) fetchCategory()
})
</script>

<template>
  <div class="main-category-detail-page">
    <div v-if="loading" class="text-center py-5">
      <div class="loading-spinner">
        <CSpinner color="primary" />
      </div>
      <p class="mt-2 text-body-secondary">Loading category...</p>
    </div>

    <div v-else-if="error" class="text-center py-5 empty-state">
      <CIcon icon="cil-warning" size="3xl" class="text-danger mb-3" />
      <h2 class="fs-5">{{ error }}</h2>
    </div>

    <template v-else-if="category">
      <nav class="breadcrumb-nav small mb-3 d-flex align-items-center gap-2 text-body-secondary">
        <router-link to="/main-categories" class="text-decoration-none">Categories</router-link>
        <CIcon icon="cil-chevron-right" size="sm" />
        <span class="fw-semibold text-body">{{ category.name }}</span>
      </nav>

      <div class="category-hero mb-4">
        <div class="category-hero-inner">
          <div v-if="category.image_url" class="category-hero-bg">
            <img :src="`/storage/${category.image_url}`" :alt="category.name" class="category-hero-img" />
            <div class="category-hero-overlay"></div>
          </div>
          <div class="category-hero-content">
            <h1 class="category-hero-title fw-bold mb-2">{{ category.name }}</h1>
            <p v-if="category.description" class="category-hero-desc mb-3">{{ category.description }}</p>
            <div class="d-flex align-items-center gap-3 flex-wrap">
              <CBadge color="light" class="category-hero-count rounded-pill">{{ products.length }} products</CBadge>
              <CButton color="light" size="sm" class="share-hero-btn" @click="shareCategory">
                <CIcon icon="cil-link" class="me-1" /> Share
              </CButton>
            </div>
          </div>
        </div>
      </div>

      <div class="filter-section mb-4">
        <div class="filter-buttons d-flex align-items-center gap-2 flex-wrap">
          <span class="filter-label small text-body-secondary fw-semibold me-1">Type:</span>
          <button class="filter-btn" :class="{ active: productType === '' }" @click="productType = ''">
            <CIcon icon="cil-grid" class="me-1" />All
          </button>
          <button class="filter-btn" :class="{ active: productType === 'physical' }" @click="productType = 'physical'">
            <CIcon icon="cil-box" class="me-1" />Physical
          </button>
          <button class="filter-btn" :class="{ active: productType === 'digital' }" @click="productType = 'digital'">
            <CIcon icon="cil-cloud-download" class="me-1" />Digital
          </button>
        </div>
      </div>

      <div v-if="!products.length" class="text-center py-5 empty-state">
        <div class="empty-icon-wrapper mb-3">
          <CIcon icon="cil-cart" size="3xl" />
        </div>
        <h4 class="fw-semibold">No products in this category yet</h4>
        <p class="text-body-secondary">Check back later or browse other categories.</p>
      </div>

      <CRow v-else class="g-4 products-grid">
        <CCol v-for="product in products" :key="product.id" sm="6" lg="4" xl="3" class="product-col">
          <CCard class="product-card h-100">
            <div class="product-img-wrapper" @click="viewProduct(product.slug)">
              <img
                v-if="productImage(product)"
                :src="thumbImageUrl(product.images?.[0])"
                :srcset="imageSrcSet(product.images?.[0])"
                sizes="(max-width: 575px) 92vw, (max-width: 991px) 46vw, (max-width: 1199px) 31vw, 24vw"
                :alt="product.name"
                class="product-img"
                loading="lazy"
                width="400"
                height="240"
              />
              <div v-else class="product-img-fallback">
                <CIcon :icon="product.product_type === 'digital' ? 'cil-cloud-download' : 'cil-box'" size="3xl" class="text-body-secondary" />
                <span class="small text-body-secondary mt-2">{{ product.product_type }}</span>
              </div>
              <div class="product-badges">
                <span v-if="product.product_type === 'digital'" class="badge-type badge-digital">
                  <CIcon icon="cil-cloud-download" size="sm" class="me-1" />Digital
                </span>
                <span v-else class="badge-type badge-physical">
                  <CIcon icon="cil-box" size="sm" class="me-1" />Physical
                </span>
              </div>
              <div class="product-actions-overlay">
                <CButton color="light" size="sm" class="action-btn action-view" @click.stop="viewProduct(product.slug)">
                  <CIcon icon="cil-zoom-in" />
                </CButton>
                <CButton color="primary" size="sm" class="action-btn action-cart" :disabled="addingId === product.id" @click.stop="addToCart(product, $event)">
                  <CSpinner v-if="addingId === product.id" size="sm" />
                  <CIcon v-else icon="cil-cart" />
                </CButton>
              </div>
            </div>
            <CCardBody class="d-flex flex-column">
              <div class="product-type-row d-flex align-items-center gap-2 mb-1">
                <span class="type-dot" :class="product.product_type"></span>
                <span class="small text-body-secondary text-capitalize">{{ product.product_type || 'physical' }}</span>
              </div>
              <CCardTitle class="product-name mb-1" @click="viewProduct(product.slug)">{{ product.name }}</CCardTitle>
              <div class="product-rating d-flex align-items-center gap-1 mb-1">
                <template v-for="i in 5" :key="i">
                  <CIcon
                    v-if="i <= Math.floor(product.star_rating || 0)"
                    icon="cil-star" size="sm" class="star-icon"
                  />
                  <CIcon
                    v-else-if="i === Math.ceil(product.star_rating || 0) && (product.star_rating || 0) % 1 !== 0"
                    icon="cil-star-half" size="sm" class="star-icon"
                  />
                  <CIcon
                    v-else
                    icon="cil-star" size="sm" class="star-icon-empty"
                  />
                </template>
                <span class="small text-body-secondary ms-1">({{ product.star_rating || 0 }})</span>
                <span class="small text-body-secondary ms-2">
                  <CIcon icon="cil-basket" size="sm" />{{ product.sold_count || 0 }} sold
                </span>
              </div>
              <p class="product-desc text-body-secondary small flex-grow-1">
                {{ product.description?.slice(0, 70) || 'No description' }}{{ product.description?.length > 70 ? '...' : '' }}
              </p>
              <div class="product-price-row">
                <h4 class="product-price mb-0 fs-5">{{ productPriceLabel(product) }}</h4>
                <small v-if="productFakePriceLabel(product)" class="fake-price text-decoration-line-through text-body-secondary ms-1">{{ productFakePriceLabel(product) }}</small>
              </div>
            </CCardBody>
          </CCard>
        </CCol>
      </CRow>
    </template>
  </div>
</template>

<style scoped>
.main-category-detail-page {
  animation: fadeUp 0.5s ease-out;
}

.loading-spinner {
  padding: 3rem;
}

.empty-state {
  animation: fadeUp 0.6s ease-out;
}

.empty-icon-wrapper {
  display: inline-flex;
  padding: 1.2rem;
  border-radius: 20px;
  background: rgba(14, 165, 233, 0.06);
  color: var(--cui-primary, #0EA5E9);
}

.breadcrumb-nav {
  animation: fadeUp 0.5s ease-out 0.1s both;
}

.breadcrumb-nav a {
  color: var(--cui-primary, #0EA5E9);
  transition: opacity 0.2s ease;
}

.breadcrumb-nav a:hover {
  opacity: 0.8;
}

.category-hero {
  animation: fadeUp 0.5s ease-out 0.15s both;
}

.category-hero-inner {
  position: relative;
  border-radius: 16px;
  overflow: hidden;
  min-height: 200px;
  display: flex;
  align-items: center;
}

.category-hero-bg {
  position: absolute;
  inset: 0;
}

.category-hero-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.category-hero-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, rgba(0, 0, 0, 0.65) 0%, rgba(0, 0, 0, 0.3) 100%);
}

.category-hero-content {
  position: relative;
  z-index: 1;
  padding: 2.5rem;
}

.category-hero-title {
  font-size: 1.8rem;
  color: #fff;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
}

.category-hero-desc {
  font-size: 0.95rem;
  color: rgba(255, 255, 255, 0.85);
  max-width: 500px;
}

.category-hero-count {
  background: rgba(255, 255, 255, 0.2) !important;
  color: #fff !important;
  backdrop-filter: blur(4px);
  border: 1px solid rgba(255, 255, 255, 0.25);
  font-weight: 600;
  padding: 0.35rem 0.9rem;
}

.share-hero-btn {
  background: rgba(255, 255, 255, 0.15) !important;
  color: #fff !important;
  border: 1px solid rgba(255, 255, 255, 0.25) !important;
  backdrop-filter: blur(4px);
  border-radius: 50px;
  font-weight: 600;
  font-size: 0.8rem;
  padding: 0.35rem 1rem;
  transition: all 0.25s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.share-hero-btn:hover {
  background: rgba(255, 255, 255, 0.3) !important;
  transform: scale(1.05);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
}

.filter-section {
  animation: fadeUp 0.5s ease-out 0.2s both;
}

.filter-buttons {
  .filter-label {
    font-size: 0.75rem;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .filter-btn {
    display: inline-flex;
    align-items: center;
    padding: 0.35rem 0.9rem;
    border: 1px solid var(--cui-border-color, rgba(0, 0, 0, 0.1));
    border-radius: 50px;
    background: transparent;
    color: var(--cui-body-color);
    font-size: 0.8rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.25s cubic-bezier(0.34, 1.56, 0.64, 1);

    &:hover {
      border-color: var(--cui-primary, #0EA5E9);
      color: var(--cui-primary, #0EA5E9);
      background: rgba(14, 165, 233, 0.04);
    }

    &.active {
      background: var(--gradient-primary);
      color: #fff;
      border-color: transparent;
      box-shadow: 0 2px 12px rgba(14, 165, 233, 0.25);
    }
  }
}

.products-grid {
  animation: fadeUp 0.5s ease-out 0.25s both;
}

.product-col {
  animation: fadeUp 0.5s ease-out both;
}

.product-col:nth-child(1) { animation-delay: 0.1s; }
.product-col:nth-child(2) { animation-delay: 0.15s; }
.product-col:nth-child(3) { animation-delay: 0.2s; }
.product-col:nth-child(4) { animation-delay: 0.25s; }
.product-col:nth-child(5) { animation-delay: 0.3s; }
.product-col:nth-child(6) { animation-delay: 0.35s; }
.product-col:nth-child(7) { animation-delay: 0.4s; }
.product-col:nth-child(8) { animation-delay: 0.45s; }

.product-card {
  border: none;
  border-radius: 16px;
  overflow: hidden;
  background: var(--glass-bg);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid var(--glass-border);
  transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.product-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 24px 64px rgba(0, 0, 0, 0.1);
}

.product-card .card-body {
  padding: 0.9rem 1rem;
}

.product-img-wrapper {
  position: relative;
  height: 240px;
  overflow: hidden;
  cursor: pointer;
  background: var(--cui-tertiary-bg);
}

.product-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.7s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.product-card:hover .product-img {
  transform: scale(1.15);
}

.product-img-fallback {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  gap: 0.25rem;
}

.product-badges {
  position: absolute;
  top: 10px;
  left: 10px;
  display: flex;
  flex-direction: column;
  gap: 4px;

  .badge-type {
    padding: 0.25rem 0.7rem;
    border-radius: 50px;
    font-size: 0.68rem;
    font-weight: 600;
    letter-spacing: 0.02em;
    display: inline-flex;
    align-items: center;
    backdrop-filter: blur(4px);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);

    &.badge-digital {
      background: linear-gradient(135deg, #0EA5E9, #0284C7);
      color: #fff;
    }

    &.badge-physical {
      background: linear-gradient(135deg, #2eb85c, #45d67a);
      color: #fff;
    }
  }
}

.product-actions-overlay {
  position: absolute;
  bottom: 10px;
  right: 10px;
  display: flex;
  gap: 6px;
  opacity: 0;
  transform: translateY(10px);
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.product-card:hover .product-actions-overlay {
  opacity: 1;
  transform: translateY(0);
}

.action-btn {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.15);
  transition: all 0.25s cubic-bezier(0.34, 1.56, 0.64, 1);

  &.action-view {
    background: rgba(255, 255, 255, 0.95);
    color: #333;
    border: none;
    &:hover { transform: scale(1.1); background: #fff; }
  }

  &.action-cart {
    border: none;
    &:hover { transform: scale(1.1); }
  }
}

.product-type-row {
  .type-dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    display: inline-block;

    &.digital { background: #0EA5E9; }
    &.physical { background: #2eb85c; }
  }
}

.product-name {
  font-size: 0.95rem;
  font-weight: 700;
  cursor: pointer;
  transition: color 0.2s ease;
  line-height: 1.35;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;

  &:hover { color: var(--cui-primary, #0EA5E9); }
}

.product-rating {
  .star-icon {
    color: #f9b115;
  }
  .star-icon-empty {
    color: var(--cui-border-color, rgba(0,0,0,0.15));
  }
}

.product-desc {
  font-size: 0.78rem;
  line-height: 1.5;
  opacity: 0.75;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.product-price-row {
  display: flex;
  align-items: baseline;
  gap: 0.5rem;
  margin-top: auto;
  padding-top: 0.5rem;

  .product-price {
    font-size: 1.05rem;
    font-weight: 800;
    background: linear-gradient(135deg, var(--cui-primary, #0EA5E9), var(--cui-info, #39f));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }

  .fake-price {
    font-size: 0.8rem;
  }
}

@keyframes fadeUp {
  from { opacity: 0; transform: translateY(30px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>
