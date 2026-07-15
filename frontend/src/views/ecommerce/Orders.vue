<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/api'
import { useAuthStore } from '@/stores/auth'
import { useToastStore } from '@/stores/toast'

const router = useRouter()
const auth = useAuthStore()
const toast = useToastStore()
const orders = ref([])
const loading = ref(true)
const paying = ref(null)

async function fetchOrders() {
  loading.value = true
  try {
    const { data } = await api.get('/api/orders/my')
    orders.value = data.data || []
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

async function payNow(order) {
  paying.value = order.id
  try {
    const { data } = await api.post('/api/paymob/intent', { order_id: order.id })
    if (data?.payment_url) {
      window.location.href = data.payment_url
    } else {
      toast.error('Payment could not be started. Please try again.')
    }
  } catch (e) {
    toast.error(e.response?.data?.message || 'Payment could not be started.')
  } finally {
    paying.value = null
  }
}

const paymentColor = (status) => {
  const colors = { paid: 'success', pending: 'warning', failed: 'danger', refunded: 'info' }
  return colors[status] || 'secondary'
}

const statusColor = (status) => {
  const colors = {
    pending: 'warning',
    under_review: 'info',
    confirmed: 'primary',
    processing: 'info',
    shipped: 'secondary',
    delivered: 'success',
    cancelled: 'danger',
  }
  return colors[status] || 'light'
}

onMounted(fetchOrders)
</script>

<template>
  <div>
    <h3 class="mb-4">{{ $t('orders.title') }}</h3>

    <div v-if="loading" class="text-center py-5">
      <CSpinner />
    </div>

    <div v-else-if="!auth.isAuthenticated && !orders.length" class="text-center py-5 text-body-secondary">
      <h4>{{ $t('orders.login_title') }}</h4>
      <p>{{ $t('orders.login_desc') }}</p>
      <CButton color="primary" class="me-2" @click="router.push('/pages/login')">
        <CIcon icon="cil-account-login" class="me-1" /> {{ $t('orders.login_btn') }}
      </CButton>
      <CButton color="outline-primary" @click="router.push('/products')">
        <CIcon icon="cil-grid" class="me-1" /> {{ $t('orders.browse') }}
      </CButton>
    </div>

    <div v-else-if="!orders.length" class="text-center py-5 text-body-secondary">
      <h4>{{ $t('orders.empty') }}</h4>
      <p>{{ $t('orders.empty_desc') }}</p>
      <RouterLink to="/products" class="btn btn-primary">{{ $t('orders.browse') }}</RouterLink>
    </div>

    <div v-else>
      <div class="d-flex justify-content-end mb-3">
        <RouterLink to="/products" class="btn btn-outline-primary btn-sm">
          <CIcon icon="cil-grid" class="me-1" />{{ $t('orders.browse') }}
        </RouterLink>
      </div>
      <CCard v-for="order in orders" :key="order.id" class="mb-3">
        <CCardBody>
          <div class="d-flex justify-content-between align-items-start">
            <div>
              <h5 class="mb-1">Order #{{ order.order_number }}</h5>
              <small class="text-body-secondary">{{ new Date(order.created_at).toLocaleDateString() }}</small>
            </div>
            <div class="text-end">
              <CBadge :color="statusColor(order.order_status)" class="text-uppercase">
                {{ order.order_status }}
              </CBadge>
              <div class="mt-1">
                <CBadge :color="paymentColor(order.payment_status)" class="text-uppercase">
                  {{ order.payment_status }}
                </CBadge>
              </div>
              <div class="mt-1">{{ order.total_amount }} {{ order.currency }}</div>
              <CButton
                v-if="order.payment_status !== 'paid'"
                color="primary"
                size="sm"
                class="mt-2"
                :disabled="paying === order.id"
                @click="payNow(order)"
              >
                <CSpinner v-if="paying === order.id" size="sm" class="me-1" />
                {{ $t('orders.pay') }}
              </CButton>
            </div>
          </div>
          <hr />
          <h6 class="fw-semibold mb-3">Products</h6>
          <div v-if="order.items?.length">
            <div v-for="item in order.items" :key="item.id" class="d-flex align-items-center gap-3 mb-3">
              <div v-if="item.product?.images?.length" style="width: 60px; height: 60px; flex-shrink: 0;">
                <img :src="'/storage/' + item.product.images[0].image_url" class="rounded w-100 h-100" style="object-fit: cover;" />
              </div>
              <div class="flex-grow-1 min-w-0">
                <RouterLink :to="`/products/${item.product?.id || item.product_id}`" class="fw-semibold text-decoration-none">
                  {{ item.product?.name || 'Product #' + item.product_id }}
                </RouterLink>
                <div class="text-body-secondary small">Qty: {{ item.quantity }}</div>
              </div>
              <div class="text-end flex-shrink-0">
                <div class="fw-semibold">{{ item.price }} {{ order.currency }}</div>
                <div v-if="item.quantity > 1" class="text-body-secondary small">{{ item.price }} each</div>
              </div>
            </div>
          </div>
          <div v-else class="text-body-secondary small">No products found in this order.</div>
        </CCardBody>
      </CCard>
    </div>
  </div>
</template>
