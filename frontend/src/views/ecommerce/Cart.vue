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

const itemPrice = (item) => {
  const currency = auth.userCurrency
  const source = item.variant || item.product
  if (currency === 'USD' && parseFloat(source?.price_usd) > 0) return parseFloat(source.price_usd)
  if (parseFloat(source?.price_egp) > 0) {
    if (currency === 'USD') {
      const rate = auth.exchangeRate || 30
      return parseFloat(source.price_egp) / rate
    }
    return parseFloat(source.price_egp)
  }
  return 0
}

const total = () => {
  if (!cart.value?.items) return 0
  return cart.value.items.reduce((sum, item) => {
    return sum + itemPrice(item) * item.quantity
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
      <h3>{{ $t('cart.title') }}</h3>
      <CButton v-if="cart?.items?.length" color="danger" size="sm" variant="outline" @click="clearCart">{{ $t('cart.clear') }}</CButton>
    </div>

    <div v-if="loading" class="text-center py-5">
      <CSpinner />
    </div>

    <div v-else-if="!cart?.items?.length" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-basket" size="3xl" class="mb-3" />
      <h4>{{ $t('cart.empty') }}</h4>
      <p>{{ $t('cart.empty_desc') }}</p>
      <RouterLink to="/products" class="btn btn-primary">{{ $t('cart.browse') }}</RouterLink>
    </div>

    <CRow v-else>
      <CCol :md="8">
        <CCard v-for="item in cart.items" :key="item.id" class="mb-3">
          <CCardBody class="d-flex align-items-center">
            <div class="flex-grow-1">
              <h4 class="mb-1 fs-5">{{ item.product?.name }}</h4>
              <div class="d-flex align-items-center gap-2">
                <CBadge :color="item.product?.product_type === 'digital' ? 'info' : 'success'" size="sm">
                  {{ item.product?.product_type }}
                </CBadge>
                <CBadge v-if="item.variant" color="warning" size="sm">{{ item.variant.name }}</CBadge>
              </div>
              <div class="mt-2 d-flex align-items-center gap-2">
                <CButton size="sm" color="outline-secondary" @click="updateQuantity(item.id, item.quantity - 1)">-</CButton>
                <span class="fw-bold px-2">{{ item.quantity }}</span>
                <CButton size="sm" color="outline-secondary" @click="updateQuantity(item.id, item.quantity + 1)">+</CButton>
                <span class="ms-3 fw-bold text-primary fs-5">{{ itemPrice(item).toFixed(2) }} {{ auth.userCurrency }}</span>
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
            <h4 class="fs-5">{{ $t('cart.summary') }}</h4>
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
              {{ $t('cart.checkout') }}
            </CButton>
            <br/>
                        <br/>
            <br/>

      <RouterLink to="/products" class="btn btn-primary">{{ $t('orders.browse') }}</RouterLink>
            
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>
  </div>
</template>
