<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '@/api'

const route = useRoute()
const router = useRouter()
const status = ref('processing')
const message = ref('Processing your payment...')

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms))

onMounted(async () => {
  const urlSuccess = route.query.success === 'true' || route.query.success === true
  const orderId = route.query.order || route.query.order_id

  if (urlSuccess) {
    status.value = 'success'
    message.value = 'Payment received successfully!'
  }

  if (orderId) {
    // Poll a few times so the payment gateway webhook / status API can catch up.
    for (let attempt = 0; attempt < 5; attempt++) {
      try {
        const { data } = await api.get('/api/payment-status', {
          params: { order_id: orderId },
        })
        if (data.payment_status === 'paid' || data.latest_payment_status === 'paid') {
          status.value = 'success'
          message.value = 'Payment received successfully!'
          break
        }
        if (data.payment_status === 'failed' || data.latest_payment_status === 'failed') {
          status.value = 'failed'
          message.value = 'Payment was cancelled or failed.'
          break
        }
      } catch (e) {
        // ignore transient errors, keep polling
      }
      await sleep(1500)
    }

    if (status.value === 'processing') {
      status.value = 'failed'
      message.value = 'Payment was cancelled or failed.'
    }
  } else if (!urlSuccess) {
    status.value = 'failed'
    message.value = 'Payment was cancelled or failed.'
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
