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
        <h3 class="mb-1">{{ $t('admin_approvals.title') }}</h3>
        <p class="text-body-secondary mb-0">{{ $t('admin_approvals.desc') }}</p>
      </div>
      <CButton color="secondary" variant="outline" size="sm" @click="fetchPending">
        <CIcon icon="cil-reload" class="me-1" /> {{ $t('admin_approvals.refresh') }}
      </CButton>
    </div>

    <CAlert v-if="error" color="danger" class="mb-3">{{ error }}</CAlert>

    <div v-if="loading" class="text-center py-5"><CSpinner /></div>

    <div v-else-if="!subs.length" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-check-circle" size="3xl" class="mb-3" />
      <h4>{{ $t('admin_approvals.empty') }}</h4>
      <p>{{ $t('admin_approvals.empty_desc') }}</p>
    </div>

    <CCard v-else class="shadow-sm">
      <CCardBody>
        <div v-for="s in subs" :key="s.id" class="border-bottom pb-3 mb-3 last:border-0 last:mb-0 last:pb-0">
          <div class="d-flex flex-wrap justify-content-between align-items-start mb-2">
            <div>
              <h4 class="mb-0 fs-5">{{ s.plan?.name }} <CBadge color="info">{{ s.plan?.ticket_limit }} {{ $t('admin_approvals.tickets') }}</CBadge></h4>
              <small class="text-body-secondary">{{ s.user?.name }} ({{ s.user?.email }}) - requested {{ formatDate(s.start_date) }}</small>
            </div>
            <div>
              <CButton color="success" size="sm" class="me-2" :disabled="processing === s.id" @click="approve(s.id)">
                <CSpinner v-if="processing === s.id" size="sm" /> {{ $t('admin_approvals.approve') }}
              </CButton>
            </div>
          </div>
          <CInputGroup>
            <CFormInput v-model="rejectReasons[s.id]" size="sm" :placeholder="$t('admin_approvals.reject_placeholder')" />
            <CButton color="danger" variant="outline" size="sm" :disabled="processing === s.id" @click="reject(s.id)">{{ $t('admin_approvals.reject') }}</CButton>
          </CInputGroup>
        </div>
      </CCardBody>
    </CCard>
  </div>
</template>
