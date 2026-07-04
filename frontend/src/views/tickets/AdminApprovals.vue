<script setup>
import { ref, onMounted } from 'vue'
import api from '@/api'
import { formatDate } from './ticketHelpers'

const subs = ref([])
const loading = ref(true)
const error = ref('')
const processing = ref(null)
const rejectReasons = ref({})

async function fetchPending() {
  loading.value = true
  error.value = ''
  try {
    const { data } = await api.get('/api/admin/subscriptions/pending')
    subs.value = data.data || []
  } catch (e) {
    error.value = e.response?.data?.message || 'Failed to load pending subscriptions.'
  } finally {
    loading.value = false
  }
}

async function approve(id) {
  processing.value = id
  error.value = ''
  try {
    await api.post(`/api/admin/subscriptions/${id}/approve`)
    await fetchPending()
  } catch (e) {
    error.value = e.response?.data?.message || 'Approval failed.'
  } finally {
    processing.value = null
  }
}

async function reject(id) {
  processing.value = id
  error.value = ''
  try {
    await api.post(`/api/admin/subscriptions/${id}/reject`, {
      rejection_reason: rejectReasons.value[id] || null,
    })
    rejectReasons.value[id] = ''
    await fetchPending()
  } catch (e) {
    error.value = e.response?.data?.message || 'Rejection failed.'
  } finally {
    processing.value = null
  }
}

onMounted(fetchPending)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">Subscription Approvals</h3>
        <p class="text-body-secondary mb-0">Approve industor subscriptions before they can create tickets.</p>
      </div>
      <CButton color="secondary" variant="outline" size="sm" @click="fetchPending">
        <CIcon icon="cil-reload" class="me-1" /> Refresh
      </CButton>
    </div>

    <CAlert v-if="error" color="danger" class="mb-3">{{ error }}</CAlert>

    <div v-if="loading" class="text-center py-5"><CSpinner /></div>

    <div v-else-if="!subs.length" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-check-circle" size="3xl" class="mb-3" />
      <h4>No pending approvals</h4>
      <p>All subscriptions are reviewed.</p>
    </div>

    <CCard v-else class="shadow-sm">
      <CCardBody>
        <div v-for="s in subs" :key="s.id" class="border-bottom pb-3 mb-3 last:border-0 last:mb-0 last:pb-0">
          <div class="d-flex flex-wrap justify-content-between align-items-start mb-2">
            <div>
              <h5 class="mb-0">{{ s.plan?.name }} <CBadge color="info">{{ s.plan?.ticket_limit }} tickets</CBadge></h5>
              <small class="text-body-secondary">{{ s.user?.name }} ({{ s.user?.email }}) - requested {{ formatDate(s.start_date) }}</small>
            </div>
            <div>
              <CButton color="success" size="sm" class="me-2" :disabled="processing === s.id" @click="approve(s.id)">
                <CSpinner v-if="processing === s.id" size="sm" /> Approve
              </CButton>
            </div>
          </div>
          <CInputGroup>
            <CFormInput v-model="rejectReasons[s.id]" size="sm" placeholder="Rejection reason (optional)" />
            <CButton color="danger" variant="outline" size="sm" :disabled="processing === s.id" @click="reject(s.id)">Reject</CButton>
          </CInputGroup>
        </div>
      </CCardBody>
    </CCard>
  </div>
</template>
