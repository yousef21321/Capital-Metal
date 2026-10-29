<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
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

const product = ref(null)
const loading = ref(true)
const error = ref('')
const selectedImage = ref(0)
const quantity = ref(1)
const adding = ref(false)
const selectedVariant = ref(null)

const zoomLevel = ref(2)
const zoomMin = 1.5
const zoomMax = 5
const zoomStep = 0.5
const isZooming = ref(false)
const zoomX = ref(0)
const zoomY = ref(0)
const galleryRef = ref(null)
const galleryRect = ref(null)

function zoomIn() {
  zoomLevel.value = Math.min(zoomLevel.value + zoomStep, zoomMax)
}

function zoomOut() {
  zoomLevel.value = Math.max(zoomLevel.value - zoomStep, zoomMin)
}

let rectRafId = null

function refreshGalleryRect() {
  rectRafId = null
  galleryRect.value = galleryRef.value ? galleryRef.value.getBoundingClientRect() : null
}

function scheduleGalleryRectRefresh() {
  if (rectRafId === null) rectRafId = requestAnimationFrame(refreshGalleryRect)
}

function onGalleryMouseMove(e) {
  const rect = galleryRect.value
  if (!rect) return
  const x = e.clientX - rect.left
  const y = e.clientY - rect.top
  zoomX.value = (x / rect.width) * 100
  zoomY.value = (y / rect.height) * 100
}

function onGalleryEnter() {
  refreshGalleryRect()
  window.addEventListener('resize', scheduleGalleryRectRefresh, { passive: true })
  window.addEventListener('scroll', scheduleGalleryRectRefresh, { passive: true })
  isZooming.value = true
}

function onGalleryLeave() {
  window.removeEventListener('resize', scheduleGalleryRectRefresh)
  window.removeEventListener('scroll', scheduleGalleryRectRefresh)
  isZooming.value = false
}

const hasVariants = computed(() => (product.value?.variants?.length || 0) > 0)

const activeVariants = computed(() =>
  (product.value?.variants || []).filter(v => v.is_active)
)

const isBaseSelected = computed(() => selectedVariant.value === null)

const currentImages = computed(() => {
  if (selectedVariant.value) {
    const variantImages = selectedVariant.value.images || []
    if (variantImages.length > 0) return variantImages
  }
  return product.value?.images || []
})

const currentImage = computed(() => {
  if (currentImages.value[selectedImage.value]) {
    return `/storage/${currentImages.value[selectedImage.value].image_url}`
  }
  return null
})

const displayProduct = computed(() => {
  if (selectedVariant.value) {
    return {
      ...product.value,
      price_egp: selectedVariant.value.price_egp,
      price_usd: selectedVariant.value.price_usd,
      fake_price_egp: selectedVariant.value.fake_price_egp,
      fake_price_usd: selectedVariant.value.fake_price_usd,
      description: selectedVariant.value.description || product.value.description,
    }
  }
  return product.value
})

function renderDescription(text) {
  if (!text) return ''
  const lines = text.split('\n')
  const hasBullets = lines.some(l => l.trimStart().startsWith('- '))
  if (!hasBullets) return text.replace(/\n/g, '<br>')
  let html = ''
  let inList = false
  for (const line of lines) {
    const trimmed = line.trimStart()
    if (trimmed.startsWith('- ')) {
      if (!inList) { html += '<ul class="desc-list mb-2">'; inList = true }
      html += `<li>${trimmed.slice(2)}</li>`
    } else {
      if (inList) { html += '</ul>'; inList = false }
      if (line.trim()) html += `<p class="mb-1">${line}</p>`
    }
  }
  if (inList) html += '</ul>'
  return html
}

const formatPrice = computed(() => formatProductPrice(displayProduct.value))

const fakePriceLabel = computed(() => {
  const p = displayProduct.value
  if (!p) return null
  const currency = auth.userCurrency || 'EGP'
  const rate = auth.exchangeRate || 30
  if (currency === 'USD') {
    if (parseFloat(p.fake_price_usd) > 0) return `${parseFloat(p.fake_price_usd).toFixed(2)} USD`
    if (parseFloat(p.fake_price_egp) > 0) return `${(parseFloat(p.fake_price_egp) / rate).toFixed(2)} USD`
  }
  if (parseFloat(p.fake_price_egp) > 0) return `${parseFloat(p.fake_price_egp).toFixed(2)} EGP`
  if (parseFloat(p.fake_price_usd) > 0) return `${(parseFloat(p.fake_price_usd) * rate).toFixed(2)} EGP`
  return null
})

const reviews = ref([])
const relatedProducts = ref([])

function selectVariant(variant) {
  selectedVariant.value = variant
  selectedImage.value = 0
}

function selectBase() {
  selectedVariant.value = null
  selectedImage.value = 0
}

async function fetchProduct() {
  loading.value = true
  try {
    const { data } = await api.get(`/api/products/${route.params.slug}`)
    product.value = data
    selectedVariant.value = null
    selectedImage.value = 0
    await fetchReviews()
    await fetchRelated()
    trackViewContent(data)
  } catch (e) {
    error.value = 'Failed to load product'
  } finally {
    loading.value = false
  }
}

function trackViewContent(p) {
  const value = parseFloat(p.price_usd) > 0 ? p.price_usd : p.price_egp
  const currency = parseFloat(p.price_usd) > 0 ? 'USD' : 'EGP'
  fbPixel.viewContent({
    content_name: p.name,
    content_category: p.product_type,
    content_ids: [String(p.id)],
    content_type: 'product',
    value: parseFloat(value || 0),
    currency,
  })
}

async function fetchReviews() {
  try {
    const { data } = await api.get(`/api/products/${route.params.slug}/reviews`)
    reviews.value = data
  } catch (_) {}
}

async function fetchRelated() {
  try {
    const { data } = await api.get('/api/products', { params: { per_page: 4 } })
    relatedProducts.value = data.data?.filter((p) => p.id !== product.value?.id).slice(0, 4) || []
  } catch (_) {}
}

async function addToCart(event) {
  if (!product.value) return
  adding.value = true
  try {
    const variantId = selectedVariant.value?.id || null
    await cart.addItem(product.value.id, quantity.value, variantId)
    flyToCart({ from: event?.currentTarget || null, imageSrc: currentImage.value })
    toast.success(`"${product.value.name}" added to cart.`)
    quantity.value = 1
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to add to cart.')
  } finally {
    adding.value = false
  }
}

onMounted(fetchProduct)

onUnmounted(() => {
  if (rectRafId !== null) cancelAnimationFrame(rectRafId)
  window.removeEventListener('resize', scheduleGalleryRectRefresh)
  window.removeEventListener('scroll', scheduleGalleryRectRefresh)
})

watch(() => route.params.slug, (newSlug) => {
  if (newSlug) {
    selectedImage.value = 0
    quantity.value = 1
    fetchProduct()
  }
})
</script>

<template>
  <div class="product-detail-page">
    <div v-if="loading" class="text-center py-5">
      <CSpinner color="primary" />
      <p class="mt-2 text-body-secondary">Loading product...</p>
    </div>

    <div v-else-if="error" class="text-center py-5">
      <CIcon icon="cil-warning" size="3xl" class="text-danger mb-3" />
      <h2 class="fs-5">{{ error }}</h2>
    </div>

    <template v-else-if="product">
      <nav class="breadcrumb-nav small mb-3 d-flex align-items-center gap-2 text-body-secondary">
        <router-link to="/products" class="text-decoration-none">Products</router-link>
        <span>/</span>
        <span class="fw-semibold text-body">{{ product.name }}</span>
      </nav>

      <CRow class="g-4 mb-5 product-hero-row">
        <CCol lg="6" class="product-gallery-col">
          <div class="gallery-zoom-wrapper" @mouseleave="onGalleryLeave">
            <div
              ref="galleryRef"
              class="gallery-main"
              @mousemove="onGalleryMouseMove"
              @mouseenter="onGalleryEnter"
            >
              <img
                v-if="currentImage"
                :src="thumbImageUrl(currentImages[selectedImage])"
                :srcset="imageSrcSet(currentImages[selectedImage])"
                sizes="(max-width: 991px) 92vw, 600px"
                :alt="product.name"
                class="gallery-img"
                width="800"
                height="600"
                draggable="false"
              />
              <div v-else class="gallery-placeholder">
                <CIcon :icon="product.product_type === 'digital' ? 'cil-cloud-download' : 'cil-box'" size="5xl" class="text-body-secondary" />
              </div>
              <span class="gallery-badge" :class="'badge-' + product.product_type">
                {{ product.product_type }}
              </span>
            </div>
            <div
              v-if="isZooming && currentImage"
              class="zoom-result"
            >
              <img
                :src="currentImage"
                :alt="product.name"
                class="zoom-result-img"
                :style="{
                  width: zoomLevel * 100 + '%',
                  marginLeft: -(zoomX * zoomLevel - 50) + '%',
                  marginTop: -(zoomY * zoomLevel - 50) + '%',
                }"
                draggable="false"
              />
            </div>
            <div v-if="currentImage" class="zoom-controls">
              <button class="zoom-btn" :disabled="zoomLevel >= zoomMax" @click="zoomIn" title="Zoom In">
                <CIcon icon="cil-plus" />
              </button>
              <span class="zoom-level">{{ Math.round(zoomLevel * 100) }}%</span>
              <button class="zoom-btn" :disabled="zoomLevel <= zoomMin" @click="zoomOut" title="Zoom Out">
                <CIcon icon="cil-minus" />
              </button>
            </div>
          </div>
          <div v-if="currentImages.length > 1" class="gallery-thumbs mt-3">
            <button
              v-for="(img, idx) in currentImages"
              :key="img.id || idx"
              class="thumb-btn"
              :class="{ active: selectedImage === idx }"
              @click="selectedImage = idx"
            >
              <img :src="thumbImageUrl(img)" :alt="'Thumbnail ' + (idx + 1)" class="thumb-img" loading="lazy" width="64" height="64" />
            </button>
          </div>
        </CCol>

        <CCol lg="6" class="product-info-col">
          <div class="product-info product-summary-card">
            <div class="d-flex align-items-center gap-2 mb-2">
              <span class="type-dot-badge" :class="product.product_type"></span>
              <span class="small text-body-secondary text-capitalize">{{ product.product_type }} Product</span>
              <span v-if="product.status" class="vr mx-1"></span>
              <span v-if="product.status" class="small text-capitalize" :class="product.status === 'active' ? 'text-success' : 'text-body-secondary'">{{ product.status }}</span>
            </div>

            <h1 class="product-title fw-bold mb-3">{{ product.name }}</h1>

            <div class="product-meta d-flex align-items-center gap-3 mb-3 flex-wrap">
              <div class="rating-display d-flex align-items-center gap-1">
                <template v-for="i in 5" :key="i">
                  <CIcon
                    v-if="i <= Math.floor(displayProduct.star_rating || 0)"
                    icon="cil-star" size="sm" class="star-icon"
                  />
                  <CIcon
                    v-else-if="i === Math.ceil(displayProduct.star_rating || 0) && (displayProduct.star_rating || 0) % 1 !== 0"
                    icon="cil-star-half" size="sm" class="star-icon"
                  />
                  <CIcon
                    v-else
                    icon="cil-star" size="sm" class="star-icon-empty"
                  />
                </template>
                <span class="small text-body-secondary ms-1">({{ displayProduct.star_rating || 0 }})</span>
              </div>
              <span class="vr"></span>
              <span class="small text-body-secondary">
                <CIcon icon="cil-basket" class="me-1" />{{ displayProduct.sold_count || 0 }} sold
              </span>
            </div>

            <!-- Variant Selector -->
            <div v-if="hasVariants && activeVariants.length > 0" class="variant-selector mb-4">
              <label class="form-label fw-semibold small text-body-secondary mb-2">Type:</label>
              <div class="d-flex flex-wrap gap-2">
                <button
                  class="variant-btn"
                  :class="{ active: isBaseSelected }"
                  @click="selectBase"
                >
                  {{ product.name }}
                </button>
                <button
                  v-for="variant in activeVariants"
                  :key="variant.id"
                  class="variant-btn"
                  :class="{ active: selectedVariant?.id === variant.id }"
                  @click="selectVariant(variant)"
                >
                  {{ variant.name }}
                </button>
              </div>
            </div>

            <div class="price-section mb-4">
              <span class="price-current">{{ formatPrice }}</span>
              <span v-if="fakePriceLabel" class="fake-price text-decoration-line-through text-body-secondary ms-2">{{ fakePriceLabel }}</span>
            </div>

            <div class="product-description text-body-secondary mb-4" v-html="renderDescription(displayProduct.description)"></div>

            <div class="product-details-grid mb-4">
              <div class="detail-item">
                <span class="detail-label">Material</span>
                <span class="detail-value">{{ selectedVariant?.material || product.material || 'N/A' }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">Manufacturing</span>
                <span class="detail-value">{{ selectedVariant?.manufacturing_method || product.manufacturing_method || 'N/A' }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">Type</span>
                <span class="detail-value text-capitalize">{{ product.product_type }}</span>
              </div>
              <div v-if="selectedVariant?.sku" class="detail-item">
                <span class="detail-label">SKU</span>
                <span class="detail-value">{{ selectedVariant.sku }}</span>
              </div>
              <div v-if="product.country_availability" class="detail-item">
                <span class="detail-label">Available in</span>
                <span class="detail-value">{{ product.country_availability }}</span>
              </div>
            </div>

            <div class="d-flex align-items-center gap-3 mb-4">
              <div v-if="product.product_type !== 'digital'" class="quantity-selector">
                <button class="qty-btn" :disabled="quantity <= 1" @click="quantity--">-</button>
                <span class="qty-value">{{ quantity }}</span>
                <button class="qty-btn" @click="quantity++">+</button>
              </div>
              <CButton color="primary" size="lg" class="btn-add-cart-detail flex-grow-1" :disabled="adding" @click="(e) => addToCart(e)">
                <CSpinner v-if="adding" size="sm" class="me-2" />
                <CIcon v-else icon="cil-cart" class="me-2" />
                Add to Cart
              </CButton>
              <CButton color="danger" variant="outline" size="lg" class="btn-wishlist-detail">
                <CIcon icon="cil-heart" />
              </CButton>
            </div>

            <div v-if="product.tags?.length" class="tags-section">
              <span class="small fw-semibold text-body-secondary me-2">Tags:</span>
              <span v-for="tag in product.tags" :key="tag" class="tag-pill">{{ tag }}</span>
            </div>

            <div v-if="product.digital_files?.length" class="files-section mt-4">
              <h6 class="fw-semibold mb-2">
                <CIcon icon="cil-files" class="me-1" /> Included Files ({{ product.digital_files.length }})
              </h6>
              <div class="d-flex flex-column gap-1">
                <div v-for="file in product.digital_files" :key="file.id" class="d-flex align-items-center gap-2 p-2 rounded" style="background: var(--cui-tertiary-bg, #f8f9fa);">
                  <CIcon icon="cil-file" class="text-primary" />
                  <span class="small flex-grow-1 text-truncate">{{ file.file_url.split('/').pop() }}</span>
                  <CBadge color="info" class="text-capitalize">{{ file.license_type }}</CBadge>
                </div>
              </div>
            </div>
          </div>
        </CCol>
      </CRow>

      <CRow class="g-4 mb-5">
        <CCol lg="8">
          <CCard class="detail-section-card">
            <CCardHeader class="fw-semibold">
              <CIcon icon="cil-comment-bubble" class="me-2" />Reviews ({{ reviews.length }})
            </CCardHeader>
            <CCardBody>
              <div v-if="!reviews.length" class="text-center py-4 text-body-secondary">
                <CIcon icon="cil-comment-bubble" size="3xl" class="mb-2" />
                <p class="mb-0">No reviews yet.</p>
              </div>
              <div v-for="review in reviews" :key="review.id" class="review-item">
                <div class="d-flex align-items-start gap-3">
                  <div class="review-avatar">{{ review.user?.name?.charAt(0) || '?' }}</div>
                  <div class="flex-grow-1">
                    <div class="d-flex align-items-center gap-2 mb-1">
                      <span class="fw-semibold small">{{ review.user?.name || 'Anonymous' }}</span>
                      <span class="small text-body-secondary">{{ new Date(review.created_at).toLocaleDateString() }}</span>
                    </div>
                    <div class="d-flex align-items-center gap-1 mb-1">
                      <CIcon v-for="i in 5" :key="i" :icon="i <= (review.rating || 0) ? 'cil-star' : 'cil-star-half'" size="sm" :class="i <= (review.rating || 0) ? 'star-icon' : 'star-icon-empty'" />
                    </div>
                    <p class="review-comment mb-0 small">{{ review.comment }}</p>
                  </div>
                </div>
              </div>
            </CCardBody>
          </CCard>
        </CCol>

        <CCol lg="4">
          <CCard class="detail-section-card">
            <CCardHeader class="fw-semibold">
              <CIcon icon="cil-info" class="me-2" />Product Details
            </CCardHeader>
            <CCardBody>
              <div class="info-row"><span>SKU</span><span>{{ selectedVariant?.sku || product.slug || 'N/A' }}</span></div>
              <div class="info-row"><span>Type</span><span class="text-capitalize">{{ product.product_type }}</span></div>
              <div class="info-row"><span>Status</span><span class="text-capitalize">{{ product.status || 'N/A' }}</span></div>
              <div v-if="selectedVariant" class="info-row"><span>Variant</span><span>{{ selectedVariant.name }}</span></div>
              <div v-else-if="hasVariants" class="info-row"><span>Variant</span><span class="text-body-secondary">Base Product</span></div>
              <div class="info-row"><span>Material</span><span>{{ selectedVariant?.material || product.material || 'N/A' }}</span></div>
              <div class="info-row"><span>Manufacturing</span><span>{{ selectedVariant?.manufacturing_method || product.manufacturing_method || 'N/A' }}</span></div>
              <div class="info-row"><span>Country</span><span>{{ product.country_availability || 'All' }}</span></div>
              <div class="info-row"><span>Star Rating</span><span>{{ product.star_rating || 0 }}</span></div>
              <div class="info-row"><span>Sold</span><span>{{ product.sold_count || 0 }}</span></div>
              <div class="info-row"><span>Published</span><span>{{ product.publish_date ? new Date(product.publish_date).toLocaleDateString() : 'N/A' }}</span></div>
            </CCardBody>
          </CCard>
        </CCol>
      </CRow>

      <div v-if="relatedProducts.length" class="related-section mb-5">
        <h2 class="fw-bold mb-4 fs-5">
          <CIcon icon="cil-grid" class="me-2 text-primary" />Related Products
        </h2>
        <CRow class="g-3">
          <CCol v-for="p in relatedProducts" :key="p.id" sm="6" lg="3">
            <router-link :to="`/products/${p.slug}`" class="text-decoration-none">
              <CCard class="related-card h-100">
                <div class="related-img-wrapper">
                  <img
                    v-if="p.images?.[0]"
                    :src="thumbImageUrl(p.images[0])"
                    :srcset="imageSrcSet(p.images[0])"
                    sizes="(max-width: 575px) 92vw, (max-width: 991px) 46vw, 23vw"
                    :alt="p.name"
                    class="related-img"
                    loading="lazy"
                    width="320"
                    height="160"
                  />
                  <div v-else class="related-img-placeholder">
                    <CIcon :icon="p.product_type === 'digital' ? 'cil-cloud-download' : 'cil-box'" size="2xl" class="text-body-secondary" />
                  </div>
                </div>
                <CCardBody>
                  <h3 class="related-name mb-1 fs-6">{{ p.name }}</h3>
                  <span class="related-price">{{ formatProductPrice(p) }}</span>
                </CCardBody>
              </CCard>
            </router-link>
          </CCol>
        </CRow>
      </div>
    </template>
  </div>
</template>

<style scoped>
.gallery-zoom-wrapper {
  position: relative;
}
.gallery-main {
  position: relative;
  border-radius: 12px;
  overflow: hidden;
  cursor: crosshair;
}
.zoom-result {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  border-radius: 12px;
  overflow: hidden;
  border: 2px solid var(--cui-primary, #0EA5E9);
  box-shadow: 0 4px 20px rgba(0,0,0,0.25);
  z-index: 20;
  background: #fff;
  pointer-events: none;
}
.zoom-result-img {
  position: absolute;
  top: 0;
  left: 0;
  min-width: 100%;
  min-height: 100%;
  object-fit: cover;
}
.zoom-controls {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  margin-top: 10px;
  position: relative;
  z-index: 21;
}
.zoom-btn {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  border: 2px solid var(--cui-border-color, #dee2e6);
  background: var(--cui-body-bg, #fff);
  color: var(--cui-body-color, inherit);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 0.85rem;
}
.zoom-btn:hover:not(:disabled) {
  border-color: var(--cui-primary, #0EA5E9);
  color: var(--cui-primary, #0EA5E9);
}
.zoom-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}
.zoom-level {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--cui-body-color, inherit);
  min-width: 45px;
  text-align: center;
}
.variant-selector {
  padding: 12px 16px;
  background: var(--cui-tertiary-bg, #f8f9fa);
  border-radius: 10px;
  border: 1px solid var(--cui-border-color, rgba(0,0,0,0.08));
}
.variant-btn {
  padding: 8px 20px;
  border: 2px solid var(--cui-border-color, #dee2e6);
  border-radius: 8px;
  background: white;
  cursor: pointer;
  font-weight: 500;
  font-size: 0.9rem;
  transition: all 0.2s ease;
  color: var(--cui-body-color, inherit);
}
.variant-btn:hover {
  border-color: var(--cui-primary, #0EA5E9);
  color: var(--cui-primary, #0EA5E9);
}
.variant-btn.active {
  border-color: var(--cui-primary, #0EA5E9);
  background: var(--cui-primary, #0EA5E9);
  color: white;
}
.desc-list {
  padding-left: 1.25rem;
  margin-bottom: 0.5rem;
}
.desc-list li {
  margin-bottom: 0.25rem;
  line-height: 1.6;
}
.star-icon {
  color: #f9b115;
}
.star-icon-empty {
  color: var(--cui-border-color, rgba(0,0,0,0.15));
}

/* Product detail page refresh */
.product-detail-page {
  --detail-accent: #087f8c;
  --detail-surface: #fff;
  --detail-border: #e3ece9;
  --detail-muted: #718187;
  padding-block: .5rem 2rem;
}
.product-detail-page .breadcrumb-nav {
  padding: .8rem 1rem;
  margin-bottom: 1.25rem !important;
  border: 1px solid var(--detail-border);
  border-radius: 12px;
  background: var(--detail-surface);
}
.product-detail-page .breadcrumb-nav a {
  color: var(--detail-accent) !important;
  font-weight: 650;
}
.product-detail-page .product-hero-row { align-items: start; }
.product-detail-page .gallery-main {
  aspect-ratio: 4 / 3;
  border: 1px solid #e3e9e7;
  border-radius: 22px;
  background: #fff;
  box-shadow: 0 18px 48px rgba(15, 37, 39, .13);
  cursor: zoom-in;
}
.product-detail-page .gallery-img {
  width: 100%;
  height: 100%;
  object-fit: contain !important;
  padding: clamp(12px, 2.2vw, 28px);
  transition: transform .35s ease;
}
.product-detail-page .gallery-main:hover .gallery-img { transform: scale(1.025); }
.product-detail-page .gallery-badge {
  top: 18px !important;
  inset-inline-start: 18px;
  padding: .5rem .9rem !important;
  border-radius: 999px !important;
  background: #16866f !important;
  box-shadow: 0 5px 15px rgba(22,134,111,.24);
  font-size: .72rem !important;
  letter-spacing: .06em !important;
}
.product-detail-page .zoom-controls { gap: 10px; margin-top: 14px; }
.product-detail-page .zoom-btn {
  border: 1px solid var(--detail-border);
  background: var(--detail-surface);
  box-shadow: 0 3px 10px rgba(20,48,48,.06);
}
.product-detail-page .zoom-level { color: var(--detail-muted); }
.product-detail-page .gallery-thumbs { gap: 10px; }
.product-detail-page .gallery-thumbs .thumb-btn {
  width: 72px;
  height: 72px;
  border: 1px solid var(--detail-border);
  background: #fff;
}
.product-detail-page .gallery-thumbs .thumb-img { object-fit: contain; padding: 4px; }
.product-detail-page .gallery-thumbs .thumb-btn.active {
  border: 2px solid var(--detail-accent);
  box-shadow: 0 0 0 3px rgba(8,127,140,.12);
}
.product-detail-page .product-summary-card {
  height: 100%;
  padding: clamp(20px, 2.2vw, 34px);
  border: 1px solid var(--detail-border);
  border-radius: 22px;
  background: var(--detail-surface);
  box-shadow: 0 12px 36px rgba(15, 37, 39, .07);
}
.product-detail-page .product-summary-card > .d-flex:first-child {
  width: fit-content;
  padding: .45rem .75rem;
  border: 1px solid rgba(8,127,140,.12);
  border-radius: 999px;
  background: rgba(8,127,140,.07);
}
.product-detail-page .product-title {
  margin-top: 1rem;
  margin-bottom: .8rem !important;
  color: #203237;
  font-size: clamp(1.65rem, 2.2vw, 2.35rem) !important;
  line-height: 1.35 !important;
  letter-spacing: -.035em;
  text-wrap: balance;
}
.product-detail-page .product-meta {
  padding-bottom: 1.15rem;
  border-bottom: 1px solid var(--detail-border);
}
.product-detail-page .product-meta .vr { height: 18px; }
.product-detail-page .price-section {
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  gap: .5rem;
  margin: 1.2rem 0 !important;
  padding: 1rem 1.15rem;
  border: 1px solid rgba(8,127,140,.12);
  border-radius: 15px;
  background: linear-gradient(120deg, rgba(8,127,140,.09), rgba(8,127,140,.025));
}
.product-detail-page .price-section .price-current {
  color: #087f8c;
  background: none !important;
  -webkit-text-fill-color: currentColor !important;
  font-size: clamp(1.7rem, 2.4vw, 2.2rem) !important;
  font-weight: 850;
  letter-spacing: -.035em;
}
.product-detail-page .product-description {
  color: var(--detail-muted) !important;
  font-size: .95rem;
  line-height: 1.8;
}
.product-detail-page .product-details-grid {
  gap: .65rem;
  padding: 0;
  border: 0;
  background: transparent;
}
.product-detail-page .product-details-grid .detail-item {
  min-height: 76px;
  justify-content: center;
  padding: .8rem .95rem;
  border: 1px solid var(--detail-border);
  border-radius: 13px;
  background: rgba(243,248,246,.8);
}
.product-detail-page .product-details-grid .detail-label {
  font-size: .67rem !important;
  letter-spacing: .075em !important;
}
.product-detail-page .product-details-grid .detail-value {
  color: #263a3f;
  font-size: .93rem !important;
}
.product-detail-page .variant-selector {
  border-radius: 14px;
  border-color: var(--detail-border);
  background: #f7faf9;
}
.product-detail-page .variant-btn {
  border: 1px solid #dbe7e3;
  border-radius: 10px;
  background: #fff;
}
.product-detail-page .variant-btn.active {
  border-color: var(--detail-accent);
  background: var(--detail-accent);
  box-shadow: 0 5px 14px rgba(8,127,140,.18);
}
.product-detail-page .product-summary-card > .d-flex.align-items-center.gap-3 {
  gap: .7rem !important;
  margin-bottom: 0 !important;
}
.product-detail-page .quantity-selector {
  min-height: 48px;
  border-color: var(--detail-border);
  border-radius: 12px;
  background: #fff;
}
.product-detail-page .quantity-selector .qty-btn { width: 40px; height: 46px; }
.product-detail-page .quantity-selector .qty-value { min-width: 40px; }
.product-detail-page .btn-add-cart-detail {
  min-height: 52px;
  border: 0;
  border-radius: 13px;
  background: linear-gradient(135deg, #087f8c, #0c9b99);
  box-shadow: 0 8px 20px rgba(8,127,140,.2);
  font-size: 1rem;
  font-weight: 750;
}
.product-detail-page .btn-wishlist-detail {
  width: 50px;
  min-height: 50px;
  border-radius: 13px;
}
.product-detail-page .detail-section-card,
.product-detail-page .related-card {
  border-radius: 18px !important;
}

[data-coreui-theme="dark"] .product-detail-page,
[data-coreuiTheme="dark"] .product-detail-page {
  --detail-surface: #202d31;
  --detail-border: #36494c;
  --detail-muted: #a8b9b7;
}
[data-coreui-theme="dark"] .product-detail-page .product-title,
[data-coreuiTheme="dark"] .product-detail-page .product-title,
[data-coreui-theme="dark"] .product-detail-page .product-details-grid .detail-value,
[data-coreuiTheme="dark"] .product-detail-page .product-details-grid .detail-value { color: #eaf2f0; }
[data-coreui-theme="dark"] .product-detail-page .product-details-grid .detail-item,
[data-coreuiTheme="dark"] .product-detail-page .product-details-grid .detail-item,
[data-coreui-theme="dark"] .product-detail-page .variant-selector,
[data-coreuiTheme="dark"] .product-detail-page .variant-selector {
  background: #26363a;
}
[data-coreui-theme="dark"] .product-detail-page .variant-btn,
[data-coreuiTheme="dark"] .product-detail-page .variant-btn,
[data-coreui-theme="dark"] .product-detail-page .quantity-selector,
[data-coreuiTheme="dark"] .product-detail-page .quantity-selector {
  color: #eaf2f0;
  background: #202d31;
  border-color: #46595c;
}
[data-coreui-theme="dark"] .product-detail-page .variant-btn.active,
[data-coreuiTheme="dark"] .product-detail-page .variant-btn.active {
  color: #fff;
  background: var(--detail-accent);
}

@media (min-width: 992px) {
  .product-detail-page .product-info-col { display: flex; }
  .product-detail-page .product-summary-card { width: 100%; }
}
@media (max-width: 991.98px) {
  .product-detail-page .product-summary-card { padding: 22px; }
  .product-detail-page .gallery-main { aspect-ratio: 1 / .82; }
}
@media (max-width: 575.98px) {
  .product-detail-page { padding-top: 0; }
  .product-detail-page .breadcrumb-nav { padding: .65rem .75rem; font-size: .78rem; }
  .product-detail-page .gallery-main { border-radius: 17px; aspect-ratio: 1 / .9; }
  .product-detail-page .product-summary-card { padding: 18px 15px; border-radius: 17px; }
  .product-detail-page .product-details-grid { grid-template-columns: 1fr 1fr; }
  .product-detail-page .product-details-grid .detail-item { min-height: 68px; padding: .7rem; }
  .product-detail-page .product-summary-card > .d-flex.align-items-center.gap-3 { flex-wrap: wrap; }
  .product-detail-page .btn-add-cart-detail { order: -1; flex-basis: 100%; }
}
</style>
