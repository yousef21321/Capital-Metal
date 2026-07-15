<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/api'

const router = useRouter()
const products = ref([])
const loading = ref(false)

async function fetchProducts() {
  loading.value = true
  try {
    const { data } = await api.get('/api/designer/products')
    products.value = data
  } finally {
    loading.value = false
  }
}

function statusBadgeColor(status) {
  switch (status) {
    case 'pending_tester_review': return 'warning'
    case 'modification_requested': return 'danger'
    case 'published': return 'success'
    case 'draft': return 'secondary'
    default: return 'primary'
  }
}

function statusLabel(status) {
  switch (status) {
    case 'pending_tester_review': return 'Pending Review'
    case 'modification_requested': return 'Modification Needed'
    case 'published': return 'Published'
    case 'draft': return 'Draft'
    default: return status
  }
}

onMounted(fetchProducts)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h3 class="mb-0">My Digital Products</h3>
      <CButton color="primary" @click="router.push('/designer/products/create')">
        + New Product
      </CButton>
    </div>

    <CSpinner v-if="loading" />

    <CAlert v-else-if="!products.length" color="info">You haven't created any products yet.</CAlert>

    <CRow v-else :gutter="{ md: 24 }">
      <CCol v-for="p in products" :key="p.id" :md="6" :lg="4" class="mb-4">
        <CCard class="shadow-sm h-100">
          <CCardBody>
            <div class="d-flex align-items-start gap-3 mb-3">
              <div v-if="p.images?.length" style="width: 80px; height: 80px; flex-shrink: 0;">
                <img :src="'/storage/' + p.images[0].image_url" class="rounded w-100 h-100" style="object-fit: cover;" />
              </div>
              <div class="flex-grow-1 min-w-0">
                <h6 class="mb-1 text-truncate">{{ p.name }}</h6>
                <CBadge :color="statusBadgeColor(p.status)" size="sm">{{ statusLabel(p.status) }}</CBadge>
                <div class="mt-1">
                  <small class="text-body-secondary">EGP: {{ p.price_egp || 0 }}</small>
                  <small class="text-body-secondary ms-2">USD: {{ p.price_usd || 0 }}</small>
                </div>
                <div v-if="p.tester_comment" class="mt-1 p-2 rounded" style="background: #fff3cd;">
                  <small class="fw-semibold">Tester feedback:</small>
                  <small class="d-block"><em>"{{ p.tester_comment }}"</em></small>
                </div>
              </div>
            </div>
            <div class="d-flex gap-2">
              <CButton
                v-if="p.status === 'modification_requested'"
                color="warning"
                size="sm"
                class="w-100"
                @click="router.push(`/designer/products/${p.id}/edit`)"
              >
                Edit & Resubmit
              </CButton>
              <CButton
                v-else
                color="primary"
                size="sm"
                variant="outline"
                class="w-100"
                @click="router.push(`/products/${p.id}`)"
              >
                View
              </CButton>
            </div>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>
  </div>
</template>
