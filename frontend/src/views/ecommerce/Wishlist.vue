<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/api'
import { useCartStore } from '@/stores/cart'
import { useAuthStore } from '@/stores/auth'
import { useToastStore } from '@/stores/toast'
import { formatProductPrice } from '@/utils/price'

const router = useRouter()
const cart = useCartStore()
const auth = useAuthStore()
const toast = useToastStore()
const items = ref([])
const loading = ref(true)
const removingId = ref(null)

async function fetchWishlist() {
  loading.value = true
  try {
    const { data } = await api.get('/api/wishlist')
    items.value = data
  } catch (e) {
    toast.error('Failed to load wishlist.')
  } finally {
    loading.value = false
  }
}

async function toggleWishlist(productId) {
  removingId.value = productId
  try {
    await api.post('/api/wishlist/toggle', { product_id: productId })
    items.value = items.value.filter((i) => i.product_id !== productId)
    toast.success('Removed from wishlist.')
  } catch (e) {
    toast.error('Failed to update wishlist.')
  } finally {
    removingId.value = null
  }
}

async function addToCart(item) {
  try {
    await cart.addItem(item.product_id, 1)
    toast.success(`"${item.product?.name}" added to cart.`)
  } catch (e) {
    toast.error('Failed to add to cart.')
  }
}

const formatPrice = formatProductPrice

const productImage = (product) => {
  const img = product?.images?.[0]
  if (img && img.image_url) return `/storage/${img.image_url}`
  return null
}

onMounted(fetchWishlist)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">{{ $t('wishlist.title') }}</h3>
        <p class="text-body-secondary mb-0">{{ $t('wishlist.desc') }}</p>
      </div>
      <CButton color="secondary" variant="outline" size="sm" @click="fetchWishlist">
        <CIcon icon="cil-reload" class="me-1" /> {{ $t('wishlist.refresh') }}
      </CButton>
    </div>

    <div v-if="loading" class="text-center py-5">
      <CSpinner />
    </div>

    <div v-else-if="!items.length" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-heart" size="3xl" class="mb-3" />
      <h4>{{ $t('wishlist.empty') }}</h4>
      <p class="mb-3">{{ $t('wishlist.empty_desc') }}</p>
      <CButton color="primary" router-link to="/products">{{ $t('wishlist.browse') }}</CButton>
    </div>

    <CRow v-else>
      <CCol v-for="item in items" :key="item.id" sm="6" lg="4" xl="3" class="mb-4">
        <CCard class="h-100 shadow-sm">
          <div class="product-img-wrapper text-center bg-light" style="height: 200px; overflow: hidden; cursor: pointer;" @click="router.push(`/products/${item.product?.slug}`)">
            <img
              v-if="productImage(item.product)"
              :src="productImage(item.product)"
              :alt="item.product?.name"
              class="w-100 h-100"
              style="object-fit: cover;"
              loading="lazy"
              width="400"
              height="200"
            />
            <div v-else class="d-flex align-items-center justify-content-center h-100">
              <CIcon :icon="item.product?.product_type === 'digital' ? 'cil-cloud-download' : 'cil-box'" size="3xl" class="text-body-secondary" />
            </div>
          </div>
          <CCardBody class="d-flex flex-column">
            <div class="d-flex justify-content-between align-items-start mb-2">
              <CCardTitle class="mb-0" style="cursor: pointer" @click="router.push(`/products/${item.product?.slug}`)">{{ item.product?.name }}</CCardTitle>
              <CButton color="danger" variant="ghost" size="sm" :disabled="removingId === item.product_id" @click="toggleWishlist(item.product_id)">
                <CSpinner v-if="removingId === item.product_id" size="sm" />
                <CIcon v-else icon="cil-heart" />
              </CButton>
            </div>
            <CBadge :color="item.product?.product_type === 'digital' ? 'info' : 'success'" class="align-self-start mb-2">
              {{ item.product?.product_type }}
            </CBadge>
            <p class="card-text text-body-secondary small flex-grow-1">{{ item.product?.description?.slice(0, 60) || $t('wishlist.no_description') }}{{ item.product?.description?.length > 60 ? '...' : '' }}</p>
            <div class="d-flex justify-content-between align-items-center mt-2">
              <h4 class="text-primary mb-0 fs-5">{{ formatPrice(item.product) }}</h4>
              <CButton color="primary" size="sm" @click="addToCart(item)">
                <CIcon icon="cil-cart" class="me-1" />{{ $t('wishlist.add') }}
              </CButton>
            </div>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>
  </div>
</template>
