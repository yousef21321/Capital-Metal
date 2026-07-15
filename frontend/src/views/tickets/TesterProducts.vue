<script setup>
import { ref, onMounted } from 'vue'
import api from '@/api'

const products = ref([])
const loading = ref(false)
const actionLoading = ref(null)

async function fetchProducts() {
  loading.value = true
  try {
    const { data } = await api.get('/api/tester/products/pending')
    products.value = data
  } finally {
    loading.value = false
  }
}

async function approve(id) {
  actionLoading.value = id
  try {
    await api.post(`/api/tester/products/${id}/approve`)
    products.value = products.value.filter(p => p.id !== id)
  } finally {
    actionLoading.value = null
  }
}

async function returnWithFeedback(id) {
  const p = products.value.find(x => x.id === id)
  if (!p) return
  const priceEGP = prompt('Suggested price (EGP):', p.tester_suggested_price_egp || '')
  if (priceEGP === null) return
  const priceUSD = prompt('Suggested price (USD):', p.tester_suggested_price_usd || '')
  if (priceUSD === null) return
  const comment = prompt('Feedback / comment:', p.tester_comment || '')
  if (comment === null) return
  actionLoading.value = id
  try {
    await api.post(`/api/tester/products/${id}/return`, {
      suggested_price_egp: priceEGP || null,
      suggested_price_usd: priceUSD || null,
      comment: comment || null,
    })
    products.value = products.value.filter(p => p.id !== id)
  } finally {
    actionLoading.value = null
  }
}

onMounted(fetchProducts)
</script>

<template>
  <div>
    <h3 class="mb-4">Product Review</h3>
    <CSpinner v-if="loading" />
    <CAlert v-else-if="!products.length" color="info">No products pending review.</CAlert>
    <CRow v-else :gutter="{ md: 24 }">
      <CCol v-for="p in products" :key="p.id" :md="6" :lg="4" class="mb-4">
        <CCard class="shadow-sm h-100">
          <CCardBody>
            <div class="d-flex align-items-start gap-3 mb-3">
              <div v-if="p.images?.length" style="width: 80px; height: 80px; flex-shrink: 0;">
                <img :src="'/storage/' + p.images[0].image_url" class="rounded w-100 h-100" style="object-fit: cover;" loading="lazy" width="80" height="80" />
              </div>
              <div class="flex-grow-1 min-w-0">
                <h4 class="mb-1 text-truncate fs-6">{{ p.name }}</h4>
                <small class="text-body-secondary d-block">Designer: {{ p.designer?.name || 'N/A' }}</small>
                <small class="text-body-secondary d-block">Status: <CBadge :color="p.status === 'pending_tester_review' ? 'warning' : 'secondary'">{{ p.status }}</CBadge></small>
                <div class="mt-1">
                  <small class="text-body-secondary">EGP: {{ p.price_egp || 0 }}</small>
                  <small class="text-body-secondary ms-2">USD: {{ p.price_usd || 0 }}</small>
                </div>
                <div v-if="p.tester_suggested_price_egp" class="mt-1 p-2 rounded" style="background: #fff3cd;">
                  <small class="fw-semibold">Suggested:</small><br />
                  <small>EGP: {{ p.tester_suggested_price_egp }} | USD: {{ p.tester_suggested_price_usd }}</small>
                  <small v-if="p.tester_comment" class="d-block mt-1"><em>"{{ p.tester_comment }}"</em></small>
                </div>
              </div>
            </div>
            <div class="d-flex gap-2">
              <CButton color="success" size="sm" class="w-50" :disabled="actionLoading === p.id" @click="approve(p.id)">
                <CSpinner v-if="actionLoading === p.id" size="sm" class="me-1" />
                Approve
              </CButton>
              <CButton color="warning" size="sm" class="w-50" :disabled="actionLoading === p.id" @click="returnWithFeedback(p.id)">
                Return w/ Feedback
              </CButton>
            </div>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>
  </div>
</template>
