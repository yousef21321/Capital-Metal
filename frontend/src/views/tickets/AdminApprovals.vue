<script setup>
import { ref, onMounted } from 'vue'
import api from '@/api'
import { useToastStore } from '@/stores/toast'
import { formatDate } from './ticketHelpers'

const toast = useToastStore()
const subs = ref([])
const loading = ref(true)
const error = ref('')
const saving = ref(null)
const ticketInputs = ref({})
const pendingFilter = ref('')

const approvalBadge = (status) => {
  const map = {
    approved: { color: 'success', label: 'Approved' },
    pending: { color: 'warning', label: 'Pending' },
    rejected: { color: 'danger', label: 'Rejected' },
  }
  return map[status] || { color: 'secondary', label: status }
}

async function fetchAll() {
  loading.value = true
  error.value = ''
  try {
    const params = {}
    if (pendingFilter.value) params.approval_status = pendingFilter.value
    const { data } = await api.get('/api/admin/subscriptions', { params })
    subs.value = data.data || []
    subs.value.forEach((s) => {
      ticketInputs.value[s.id] = s.tickets_remaining
    })
  } catch (e) {
    error.value = e.response?.data?.message || 'Failed to load subscriptions.'
  } finally {
    loading.value = false
  }
}

async function updateTickets(s) {
  saving.value = s.id
  error.value = ''
  const newValue = parseInt(ticketInputs.value[s.id], 10)
  if (isNaN(newValue) || newValue < 0) {
    toast.error('Ticket count must be 0 or greater.')
    saving.value = null
    return
  }
  try {
    await api.put(`/api/admin/subscriptions/${s.id}/tickets`, {
      tickets_remaining: newValue,
    })
    toast.success('Ticket count updated.')
    await fetchAll()
  } catch (e) {
    error.value = e.response?.data?.message || 'Failed to update tickets.'
  } finally {
    saving.value = null
  }
}

async function approve(id) {
  saving.value = id
  error.value = ''
  try {
    await api.post(`/api/admin/subscriptions/${id}/approve`)
    toast.success('Subscription approved.')
    await fetchAll()
  } catch (e) {
    error.value = e.response?.data?.message || 'Approval failed.'
  } finally {
    saving.value = null
  }
}

async function reject(id) {
  saving.value = id
  error.value = ''
  if (!confirm('Reject this subscription?')) {
    saving.value = null
    return
  }
  try {
    await api.post(`/api/admin/subscriptions/${id}/reject`, {})
    toast.success('Subscription rejected.')
    await fetchAll()
  } catch (e) {
    error.value = e.response?.data?.message || 'Rejection failed.'
  } finally {
    saving.value = null
  }
}

onMounted(fetchAll)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">{{ $t('admin_approvals.title') }}</h3>
        <p class="text-body-secondary mb-0">{{ $t('admin_approvals.desc') }}</p>
      </div>
      <CButton color="secondary" variant="outline" size="sm" @click="fetchAll">
        <CIcon icon="cil-reload" class="me-1" /> {{ $t('admin_approvals.refresh') }}
      </CButton>
    </div>

    <CAlert v-if="error" color="danger" class="mb-3">{{ error }}</CAlert>

    <CCard class="shadow-sm mb-4">
      <CCardBody>
        <div class="d-flex flex-wrap align-items-center gap-2">
          <CFormSelect v-model="pendingFilter" size="sm" style="max-width: 200px" @change="fetchAll">
            <option value="">{{ $t('admin_approvals.all_statuses') }}</option>
            <option value="pending">Pending</option>
            <option value="approved">Approved</option>
            <option value="rejected">Rejected</option>
          </CFormSelect>
        </div>
      </CCardBody>
    </CCard>

    <div v-if="loading" class="text-center py-5"><CSpinner /></div>

    <div v-else-if="!subs.length" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-check-circle" size="3xl" class="mb-3" />
      <h4>{{ $t('admin_approvals.empty') }}</h4>
      <p>{{ $t('admin_approvals.empty_desc') }}</p>
    </div>

    <CCard v-else class="shadow-sm">
      <CTable hover responsive align="middle">
        <CTableHead>
          <CTableRow>
            <CTableHeaderCell>User</CTableHeaderCell>
            <CTableHeaderCell>Plan</CTableHeaderCell>
            <CTableHeaderCell>Status</CTableHeaderCell>
            <CTableHeaderCell>Start</CTableHeaderCell>
            <CTableHeaderCell>Expires</CTableHeaderCell>
            <CTableHeaderCell>Used</CTableHeaderCell>
            <CTableHeaderCell class="text-center">Tickets Remaining</CTableHeaderCell>
            <CTableHeaderCell class="text-end">Actions</CTableHeaderCell>
          </CTableRow>
        </CTableHead>
        <CTableBody>
          <CTableRow v-for="s in subs" :key="s.id">
            <CTableDataCell>
              <div class="fw-semibold">{{ s.user?.name || '-' }}</div>
              <small class="text-body-secondary">{{ s.user?.email }}</small>
            </CTableDataCell>
            <CTableDataCell>
              <div class="fw-semibold">{{ s.plan?.name }}</div>
              <small class="text-body-secondary">{{ s.plan?.ticket_limit }} tickets / {{ s.plan?.duration_days || 30 }} days</small>
            </CTableDataCell>
            <CTableDataCell>
              <CBadge :color="approvalBadge(s.approval_status).color">{{ approvalBadge(s.approval_status).label }}</CBadge>
            </CTableDataCell>
            <CTableDataCell>{{ formatDate(s.start_date) }}</CTableDataCell>
            <CTableDataCell>{{ s.end_date ? formatDate(s.end_date) : '-' }}</CTableDataCell>
            <CTableDataCell>{{ s.tickets_used }}</CTableDataCell>
            <CTableDataCell class="text-center">
              <CInputGroup style="max-width: 140px" class="mx-auto">
                <CFormInput
                  v-model="ticketInputs[s.id]"
                  type="number"
                  min="0"
                  size="sm"
                  class="text-center"
                />
                <CButton
                  color="primary"
                  variant="outline"
                  size="sm"
                  :disabled="saving === s.id"
                  @click="updateTickets(s)"
                >
                  <CSpinner v-if="saving === s.id" size="sm" />
                  <CIcon v-else icon="cil-save" />
                </CButton>
              </CInputGroup>
            </CTableDataCell>
            <CTableDataCell class="text-end">
              <template v-if="s.approval_status === 'pending'">
                <CButton color="success" variant="ghost" size="sm" class="me-1" :disabled="saving === s.id" @click="approve(s.id)">
                  <CIcon icon="cil-check" class="me-1" />{{ $t('admin_approvals.approve') }}
                </CButton>
                <CButton color="danger" variant="ghost" size="sm" :disabled="saving === s.id" @click="reject(s.id)">
                  <CIcon icon="cil-x" class="me-1" />{{ $t('admin_approvals.reject') }}
                </CButton>
              </template>
              <span v-else class="text-body-secondary small">-</span>
            </CTableDataCell>
          </CTableRow>
        </CTableBody>
      </CTable>
    </CCard>
  </div>
</template>
