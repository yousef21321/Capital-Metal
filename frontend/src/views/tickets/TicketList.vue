<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/api'
import { useAuthStore } from '@/stores/auth'
import { statusMeta, formatDate } from './ticketHelpers'

const router = useRouter()
const auth = useAuthStore()
const tickets = ref([])
const loading = ref(true)
const error = ref('')
const activeStatus = ref('')

const role = () => auth.userRole

async function fetchTickets() {
  loading.value = true
  error.value = ''
  try {
    const params = {}
    if (activeStatus.value) params.status = activeStatus.value
    const { data } = await api.get('/api/tickets', { params })
    tickets.value = data.data || []
  } catch (e) {
    error.value = e.response?.data?.message || 'Failed to load tickets.'
  } finally {
    loading.value = false
  }
}

function openTicket(id) {
  router.push(`/tickets/${id}`)
}

function createTicket() {
  router.push('/tickets/create')
}

const titleByRole = () => {
  const map = {
    industor: 'My Requests',
    tester: 'QA Queue',
    designer: 'My Tickets',
    admin: 'All Tickets',
  }
  return map[role()] || 'Tickets'
}

const canCreate = () => role() === 'industor'

const statusFilters = [
  { value: '', label: 'All' },
  { value: 'pending_tester_review', label: 'Pending Tester' },
  { value: 'waiting_industor_approval', label: 'Awaiting Industor' },
  { value: 'waiting_tester_review', label: 'Awaiting Tester' },
  { value: 'pending_payment', label: 'Pending Payment' },
  { value: 'approved_by_tester', label: 'Available' },
  { value: 'accepted', label: 'Accepted' },
  { value: 'modification_requested', label: 'Mod Requested' },
  { value: 'in_progress', label: 'In Progress' },
  { value: 'awaiting_qa', label: 'Awaiting QA' },
  { value: 'completed', label: 'Completed' },
  { value: 'rejected_qa', label: 'QA Rejected' },
]

onMounted(fetchTickets)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">{{ titleByRole() }}</h3>
        <p class="text-body-secondary mb-0">Track design requests across the workflow.</p>
      </div>
      <CButton v-if="canCreate()" color="primary" @click="createTicket">
        <CIcon icon="cil-plus" class="me-1" /> New Request
      </CButton>
    </div>

    <CCard class="mb-4 shadow-sm">
      <CCardBody>
        <div class="d-flex flex-wrap gap-2">
          <CButton
            v-for="f in statusFilters"
            :key="f.value"
            size="sm"
            :color="activeStatus === f.value ? 'primary' : 'outline-secondary'"
            @click="activeStatus = f.value; fetchTickets()"
          >
            {{ f.label }}
          </CButton>
        </div>
      </CCardBody>
    </CCard>

    <div v-if="loading" class="text-center py-5">
      <CSpinner />
    </div>

    <div v-else-if="error" class="py-3">
      <CAlert color="danger" class="mb-0">{{ error }}</CAlert>
    </div>

    <div v-else-if="!tickets.length" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-file" size="3xl" class="mb-3" />
      <h4>No tickets found</h4>
      <p v-if="canCreate()">Create your first request to get started.</p>
    </div>

    <CCard v-else class="shadow-sm">
      <CTable hover responsive align="middle">
        <CTableHead>
          <CTableRow>
            <CTableHeaderCell>Title</CTableHeaderCell>
            <CTableHeaderCell>Status</CTableHeaderCell>
            <CTableHeaderCell v-if="role() !== 'industor'">Industor</CTableHeaderCell>
            <CTableHeaderCell v-if="role() === 'admin' || role() === 'industor'">Designer</CTableHeaderCell>
            <CTableHeaderCell>Created</CTableHeaderCell>
            <CTableHeaderCell class="text-end">Action</CTableHeaderCell>
          </CTableRow>
        </CTableHead>
        <CTableBody>
          <CTableRow v-for="t in tickets" :key="t.id" style="cursor: pointer" @click="openTicket(t.id)">
            <CTableDataCell class="fw-semibold">{{ t.title }}</CTableDataCell>
            <CTableDataCell>
              <CBadge :color="statusMeta(t.status).color">{{ statusMeta(t.status).label }}</CBadge>
              <span v-if="t.is_overdue" class="badge text-bg-danger ms-1">Overdue</span>
            </CTableDataCell>
            <CTableDataCell v-if="role() !== 'industor'">{{ t.industor?.name || '-' }}</CTableDataCell>
            <CTableDataCell v-if="role() === 'admin' || role() === 'industor'">{{ t.designer?.name || '-' }}</CTableDataCell>
            <CTableDataCell class="small text-body-secondary">{{ formatDate(t.created_at) }}</CTableDataCell>
            <CTableDataCell class="text-end">
              <CButton color="primary" variant="outline" size="sm" @click.stop="openTicket(t.id)">Open</CButton>
            </CTableDataCell>
          </CTableRow>
        </CTableBody>
      </CTable>
    </CCard>
  </div>
</template>
