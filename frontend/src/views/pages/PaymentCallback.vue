<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '@/api'

const route = useRoute()
const router = useRouter()
const status = ref('processing')
const message = ref('Processing your payment...')

onMounted(async () => {
  const success = route.query.success === 'true' || route.query.success === true
  const orderId = route.query.order

  if (success) {
    status.value = 'success'
    message.value = 'Payment received successfully!'
  } else {
    status.value = 'failed'
    message.value = 'Payment was cancelled or failed.'
  }

  if (orderId) {
    try {
      const { data } = await api.get('/api/paymob/redirect', {
        params: { success, order: orderId },
      })
      if (data.success) {
        status.value = 'success'
        message.value = 'Payment received successfully!'
      }
    } catch (e) {
      // ignore
    }
  }

  setTimeout(() => {
    router.push(status.value === 'success' ? '/orders' : '/cart')
  }, 4000)
})
</script>

<template>
  <div class="d-flex justify-content-center align-items-center" style="min-height: 60vh;">
    <CCard class="shadow-sm text-center p-5" style="max-width: 500px;">
      <div v-if="status === 'processing'">
        <CSpinner size="lg" />
        <h5 class="mt-3">{{ message }}</h5>
      </div>
      <div v-else-if="status === 'success'">
        <CIcon icon="cil-check-circle" size="3xl" class="text-success mb-3" />
        <h4 class="text-success">Payment Successful</h4>
        <p class="text-body-secondary">{{ message }}</p>
        <p class="small text-body-secondary">Redirecting to orders...</p>
      </div>
      <div v-else>
        <CIcon icon="cil-x-circle" size="3xl" class="text-danger mb-3" />
        <h4 class="text-danger">Payment Failed</h4>
        <p class="text-body-secondary">{{ message }}</p>
        <p class="small text-body-secondary">Redirecting to cart...</p>
      </div>
    </CCard>
  </div>
</template>
