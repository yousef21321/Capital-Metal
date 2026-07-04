<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/api'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const auth = useAuthStore()
const cart = ref(null)
const loading = ref(true)

async function fetchCart() {
  loading.value = true
  try {
    const { data } = await api.get('/api/cart')
    cart.value = data
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

async function removeItem(itemId) {
  try {
    await api.delete(`/api/cart/items/${itemId}`)
    await fetchCart()
  } catch (e) {
    console.error(e)
  }
}

async function updateQuantity(itemId, quantity) {
  if (quantity < 1) return
  try {
    await api.put(`/api/cart/items/${itemId}`, { quantity })
    await fetchCart()
  } catch (e) {
    console.error(e)
  }
}

async function clearCart() {
  try {
    await api.delete('/api/cart')
    cart.value = null
  } catch (e) {
    console.error(e)
  }
}

const total = () => {
  if (!cart.value?.items) return 0
  const currency = auth.userCurrency
  return cart.value.items.reduce((sum, item) => {
    const price = parseFloat(
      currency === 'USD' ? (item.product?.price_usd || 0) : (item.product?.price_egp || 0)
    )
    return sum + price * item.quantity
  }, 0).toFixed(2)
}

function goToCheckout() {
  router.push('/checkout')
}

onMounted(fetchCart)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h3>Shopping Cart</h3>
      <CButton v-if="cart?.items?.length" color="danger" size="sm" variant="outline" @click="clearCart">Clear Cart</CButton>
    </div>

    <div v-if="loading" class="text-center py-5">
      <CSpinner />
    </div>

    <div v-else-if="!cart?.items?.length" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-basket" size="3xl" class="mb-3" />
      <h4>Your cart is empty</h4>
      <p>Browse products to add items to your cart.</p>
      <CButton color="primary" router-link to="/products">Browse Products</CButton>
    </div>

    <CRow v-else>
      <CCol :md="8">
        <CCard v-for="item in cart.items" :key="item.id" class="mb-3">
          <CCardBody class="d-flex align-items-center">
            <div class="flex-grow-1">
              <h5 class="mb-1">{{ item.product?.name }}</h5>
              <CBadge :color="item.product?.product_type === 'digital' ? 'info' : 'success'" size="sm">
                {{ item.product?.product_type }}
              </CBadge>
              <div class="mt-2 d-flex align-items-center gap-2">
                <CButton size="sm" color="outline-secondary" @click="updateQuantity(item.id, item.quantity - 1)">-</CButton>
                <span class="fw-bold px-2">{{ item.quantity }}</span>
                <CButton size="sm" color="outline-secondary" @click="updateQuantity(item.id, item.quantity + 1)">+</CButton>
                <span class="ms-3 fw-bold text-primary fs-5">{{ auth.userCurrency === 'USD' && item.product?.price_usd ? item.product.price_usd : item.product?.price_egp }} {{ auth.userCurrency === 'USD' ? 'USD' : 'EGP' }}</span>
              </div>
            </div>
            <CButton color="danger" size="sm" variant="ghost" @click="removeItem(item.id)">
              <CIcon icon="cil-trash" />
            </CButton>
          </CCardBody>
        </CCard>
      </CCol>
      <CCol :md="4">
        <CCard class="sticky-top" style="top: 20px;">
          <CCardBody>
            <h5>Order Summary</h5>
            <hr />
            <div class="d-flex justify-content-between mb-2">
              <span>Items ({{ cart.items.length }})</span>
              <span>{{ cart.items.reduce((s, i) => s + i.quantity, 0) }} pcs</span>
            </div>
            <div class="d-flex justify-content-between mb-3">
              <span class="fw-bold">Total</span>
              <span class="fw-bold text-primary fs-5">{{ total() }} {{ auth.userCurrency }}</span>
            </div>
            <CButton color="primary" class="w-100 mt-2" size="lg" @click="goToCheckout">
              Proceed to Checkout
            </CButton>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>
  </div>
</template>
