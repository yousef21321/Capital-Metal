<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '@/api'
import { useCartStore } from '@/stores/cart'
import { useAuthStore } from '@/stores/auth'
import { useToastStore } from '@/stores/toast'
import { formatProductPrice } from '@/utils/price'

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

const images = computed(() => product.value?.images || [])
const currentImage = computed(() => {
  if (images.value[selectedImage.value]) {
    return `/storage/${images.value[selectedImage.value].image_url}`
  }
  return null
})

const formatPrice = computed(() => formatProductPrice(product.value))

const reviews = ref([])
const relatedProducts = ref([])

async function fetchProduct() {
  loading.value = true
  try {
    const { data } = await api.get(`/api/products/${route.params.slug}`)
    product.value = data
    await fetchReviews()
    await fetchRelated()
  } catch (e) {
    error.value = 'Failed to load product'
  } finally {
    loading.value = false
  }
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

async function addToCart() {
  if (!product.value) return
  adding.value = true
  try {
    await cart.addItem(product.value.id, quantity.value)
    toast.success(`"${product.value.name}" added to cart.`)
    quantity.value = 1
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to add to cart.')
  } finally {
    adding.value = false
  }
}

onMounted(fetchProduct)

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

      <CRow class="g-4 mb-5">
        <CCol lg="6">
          <div class="gallery-main">
            <img
              v-if="currentImage"
              :src="currentImage"
              :alt="product.name"
              class="gallery-img"
              width="800"
              height="600"
            />
            <div v-else class="gallery-placeholder">
              <CIcon :icon="product.product_type === 'digital' ? 'cil-cloud-download' : 'cil-box'" size="5xl" class="text-body-secondary" />
            </div>
            <span class="gallery-badge" :class="'badge-' + product.product_type">
              {{ product.product_type }}
            </span>
          </div>
          <div v-if="images.length > 1" class="gallery-thumbs mt-3">
            <button
              v-for="(img, idx) in images"
              :key="idx"
              class="thumb-btn"
              :class="{ active: selectedImage === idx }"
              @click="selectedImage = idx"
            >
              <img :src="`/storage/${img.image_url}`" :alt="'Thumbnail ' + (idx + 1)" class="thumb-img" loading="lazy" width="64" height="64" />
            </button>
          </div>
        </CCol>

        <CCol lg="6">
          <div class="product-info">
            <div class="d-flex align-items-center gap-2 mb-2">
              <span class="type-dot-badge" :class="product.product_type"></span>
              <span class="small text-body-secondary text-capitalize">{{ product.product_type }} Product</span>
              <span v-if="product.status" class="vr mx-1"></span>
              <span v-if="product.status" class="small text-capitalize" :class="product.status === 'active' ? 'text-success' : 'text-body-secondary'">{{ product.status }}</span>
            </div>

            <h1 class="product-title fw-bold mb-3">{{ product.name }}</h1>

            <div class="product-meta d-flex align-items-center gap-3 mb-3 flex-wrap">
              <div class="rating-display d-flex align-items-center gap-1">
                <CIcon v-for="i in 5" :key="i" :icon="i <= (product.avg_rating || 4) ? 'cil-star' : 'cil-star-half'" size="sm" class="star-icon" />
                <span class="small text-body-secondary ms-1">({{ reviews.length }})</span>
              </div>
              <span class="vr"></span>
              <span class="small text-body-secondary">
                <CIcon icon="cil-basket" class="me-1" />{{ product.order_items_count || 0 }} sold
              </span>
            </div>

            <div class="price-section mb-4">
              <span class="price-current">{{ formatPrice }}</span>
              <span v-if="product.compare_price" class="price-compare ms-2">{{ product.compare_price }}</span>
            </div>

            <p class="product-description text-body-secondary mb-4">{{ product.description }}</p>

            <div class="product-details-grid mb-4">
              <div class="detail-item">
                <span class="detail-label">Material</span>
                <span class="detail-value">{{ product.material || 'N/A' }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">Manufacturing</span>
                <span class="detail-value">{{ product.manufacturing_method || 'N/A' }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">Type</span>
                <span class="detail-value text-capitalize">{{ product.product_type }}</span>
              </div>
              <div v-if="product.country_availability" class="detail-item">
                <span class="detail-label">Available in</span>
                <span class="detail-value">{{ product.country_availability }}</span>
              </div>
            </div>

            <div class="d-flex align-items-center gap-3 mb-4">
              <div class="quantity-selector">
                <button class="qty-btn" :disabled="quantity <= 1" @click="quantity--">-</button>
                <span class="qty-value">{{ quantity }}</span>
                <button class="qty-btn" @click="quantity++">+</button>
              </div>
              <CButton color="primary" size="lg" class="btn-add-cart-detail flex-grow-1" :disabled="adding" @click="addToCart">
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
              <div class="info-row"><span>SKU</span><span>{{ product.slug || 'N/A' }}</span></div>
              <div class="info-row"><span>Type</span><span class="text-capitalize">{{ product.product_type }}</span></div>
              <div class="info-row"><span>Status</span><span class="text-capitalize">{{ product.status || 'N/A' }}</span></div>
              <div class="info-row"><span>Material</span><span>{{ product.material || 'N/A' }}</span></div>
              <div class="info-row"><span>Manufacturing</span><span>{{ product.manufacturing_method || 'N/A' }}</span></div>
              <div class="info-row"><span>Country</span><span>{{ product.country_availability || 'All' }}</span></div>
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
                    :src="`/storage/${p.images[0].image_url}`"
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
