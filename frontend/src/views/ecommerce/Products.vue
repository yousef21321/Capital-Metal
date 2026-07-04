<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/api'
import { useCartStore } from '@/stores/cart'
import { useAuthStore } from '@/stores/auth'
import { useToastStore } from '@/stores/toast'

const router = useRouter()
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

const formatPrice = (product) => {
  const currency = auth.userCurrency
  if (currency === 'USD' && parseFloat(product.price_usd) > 0) return `${parseFloat(product.price_usd).toFixed(2)} USD`
  if (parseFloat(product.price_egp) > 0) {
    if (currency === 'USD') {
      const rate = auth.exchangeRate || 30
      return `${(parseFloat(product.price_egp) / rate).toFixed(2)} USD`
    }
    return `${parseFloat(product.price_egp).toFixed(2)} EGP`
  }
  if (parseFloat(product.price_usd) > 0) return `${parseFloat(product.price_usd).toFixed(2)} USD`
  return 'Free'
}

const productImage = (product) => {
  const img = product.images?.[0]
  if (img && img.image_url) {
    return `${api.defaults.baseURL}/storage/${img.image_url}`
  }
  return null
}

async function addToCart(product) {
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

function viewProduct(id) {
  router.push(`/products/${id}`)
}

onMounted(fetchProducts)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">Products</h3>
        <p class="text-body-secondary mb-0">Browse and add products to your cart.</p>
      </div>
    </div>

    <CCard class="mb-4 shadow-sm">
      <CCardBody>
        <CRow class="g-2 align-items-center">
          <CCol md="5">
            <div class="input-group">
              <span class="input-group-text"><CIcon icon="cil-search" /></span>
              <input v-model="search" class="form-control" placeholder="Search products..." @input="fetchProducts" />
            </div>
          </CCol>
          <CCol md="3">
            <CFormSelect v-model="productType" @change="fetchProducts">
              <option value="">All Types</option>
              <option value="physical">Physical</option>
              <option value="digital">Digital</option>
            </CFormSelect>
          </CCol>
          <CCol md="2">
            <CButton color="primary" variant="outline" class="w-100" @click="fetchProducts">Search</CButton>
          </CCol>
        </CRow>
      </CCardBody>
    </CCard>

    <div v-if="loading" class="text-center py-5">
      <CSpinner />
    </div>

    <div v-else-if="!products.length" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-cart" size="3xl" class="mb-3" />
      <h4>No products found</h4>
    </div>

    <CRow v-else>
      <CCol v-for="product in products" :key="product.id" sm="6" lg="4" xl="3" class="mb-4">
        <CCard class="h-100 shadow-sm">
          <div class="product-img-wrapper text-center bg-light" style="height: 200px; overflow: hidden; cursor: pointer;" @click="viewProduct(product.id)">
            <img
              v-if="productImage(product)"
              :src="productImage(product)"
              :alt="product.name"
              class="w-100 h-100"
              style="object-fit: cover;"
            />
            <div v-else class="d-flex align-items-center justify-content-center h-100">
              <CIcon :icon="product.product_type === 'digital' ? 'cil-cloud-download' : 'cil-box'" size="3xl" class="text-body-secondary" />
            </div>
          </div>
          <CCardBody class="d-flex flex-column">
            <div class="d-flex justify-content-between align-items-start mb-2">
              <CCardTitle class="mb-0" style="cursor: pointer" @click="viewProduct(product.id)">{{ product.name }}</CCardTitle>
              <CButton
                color="danger"
                :variant="wishlistIds.has(product.id) ? '' : 'ghost'"
                size="sm"
                class="p-1"
                @click="toggleWishlist(product.id)"
              >
                <CIcon :icon="wishlistIds.has(product.id) ? 'cil-heart' : 'cil-heart'" />
              </CButton>
            </div>
            <p class="card-text text-body-secondary small flex-grow-1">{{ product.description?.slice(0, 80) || 'No description' }}{{ product.description?.length > 80 ? '...' : '' }}</p>
            <div class="d-flex justify-content-between align-items-center mt-2">
              <h5 class="text-primary mb-0">{{ formatPrice(product) }}</h5>
              <CButton color="primary" size="sm" :disabled="addingId === product.id" @click="addToCart(product)">
                <CSpinner v-if="addingId === product.id" size="sm" class="me-1" />
                <CIcon v-else icon="cil-cart" class="me-1" />Add
              </CButton>
            </div>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>

    <div v-if="lastPage > 1" class="mt-4">
      <CPagination align="center" aria-label="Products pagination">
        <CPaginationItem :disabled="currentPage === 1" @click="currentPage--; fetchProducts()">Previous</CPaginationItem>
        <CPaginationItem v-for="page in lastPage" :key="page" :active="page === currentPage" @click="currentPage = page; fetchProducts()">{{ page }}</CPaginationItem>
        <CPaginationItem :disabled="currentPage === lastPage" @click="currentPage++; fetchProducts()">Next</CPaginationItem>
      </CPagination>
    </div>
  </div>
</template>
