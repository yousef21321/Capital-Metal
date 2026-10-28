<script setup>
import { ref, onMounted, computed } from 'vue'
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

const role = computed(() => auth.userRole)

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

const translationKey = computed(() => {
  const map = {
    industor: 'tickets.my_requests',
    tester: 'tickets.qa_queue',
    designer: 'tickets.my_tickets',
    admin: 'tickets.all_tickets',
  }
  return map[role.value] || 'tickets.tickets'
})

const canCreate = computed(() => role.value === 'industor')

const statusFilters = [
  { value: '', label: '', translationKey: 'all', icon: 'cil-grid' },
  { value: 'pending_tester_review', label: '', translationKey: 'pending_tester_review', icon: 'cil-hourglass' },
  { value: 'waiting_industor_approval', label: '', translationKey: 'waiting_industor_approval', icon: 'cil-clock' },
  { value: 'pending_payment', label: '', translationKey: 'pending_payment', icon: 'cil-credit-card' },
  { value: 'approved_by_tester', label: '', translationKey: 'available', icon: 'cil-check' },
  { value: 'in_progress', label: '', translationKey: 'in_progress', icon: 'cil-settings' },
  { value: 'completed', label: '', translationKey: 'completed', icon: 'cil-check-circle' },
]

const statusCount = computed(() => {
  const counts = {}
  tickets.value.forEach((t) => {
    counts[t.status] = (counts[t.status] || 0) + 1
  })
  return counts
})

onMounted(fetchTickets)
</script>

<template>
  <div class="ticket-list-page">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1 fw-bold">
          <CIcon icon="cil-description" class="me-2 text-primary" />{{ $t(translationKey) }}
        </h3>
        <p class="text-body-secondary mb-0">{{ $t('tickets.desc') }}</p>
      </div>
      <CButton v-if="canCreate" color="primary" class="btn-new-ticket" @click="createTicket">
        <CIcon icon="cil-plus" class="me-1" /> {{ $t('tickets.new_request') }}
      </CButton>
    </div>

    <CCard class="mb-4 filter-card">
      <CCardBody>
        <div class="filter-pills d-flex flex-wrap gap-2">
          <button
            v-for="f in statusFilters"
            :key="f.value"
            class="filter-pill"
            :class="{ active: activeStatus === f.value }"
            @click="activeStatus = f.value; fetchTickets()"
          >
            <CIcon :icon="f.icon" class="me-1" />
            {{ $t('tickets.' + f.translationKey) }}
            <span v-if="statusCount[f.value]" class="filter-count">{{ statusCount[f.value] }}</span>
          </button>
        </div>
      </CCardBody>
    </CCard>

    <div v-if="loading" class="text-center py-5">
      <div class="loading-spinner">
        <CSpinner color="primary" />
      </div>
    </div>

    <div v-else-if="error" class="py-3">
      <CAlert color="danger" class="mb-0">{{ error }}</CAlert>
    </div>

    <div v-else-if="!tickets.length" class="text-center py-5 empty-state">
      <div class="empty-icon-wrapper mb-3">
        <CIcon icon="cil-file" size="3xl" />
      </div>
      <h4 class="fw-semibold">{{ $t('tickets.no_tickets') }}</h4>
      <p v-if="canCreate" class="text-body-secondary">{{ $t('tickets.no_tickets_desc') }}</p>
    </div>

    <CCard v-else class="tickets-card">
      <div class="ticket-list">
        <div
          v-for="(t, idx) in tickets"
          :key="t.id"
          class="ticket-row"
          :style="{ '--row-delay': idx * 0.05 + 's' }"
          @click="openTicket(t.id)"
        >
          <div class="ticket-left">
            <div class="ticket-icon">
              <CIcon icon="cil-description" />
            </div>
            <div class="ticket-info">
              <h4 class="ticket-title mb-1 fs-6">
                <span v-if="t.num_order" class="me-1 text-body-secondary">#{{ t.num_order }}</span>{{ t.title }}
              </h4>
              <div class="ticket-meta d-flex align-items-center gap-2 flex-wrap">
                <CBadge :color="statusMeta(t.status).color" class="ticket-badge">{{ statusMeta(t.status).label }}</CBadge>
                <span v-if="t.is_overdue" class="overdue-badge">{{ $t('tickets.overdue') }}</span>
                <span class="small text-body-secondary">
                  <CIcon icon="cil-clock" size="sm" class="me-1" />{{ formatDate(t.created_at) }}
                </span>
              </div>
            </div>
          </div>
          <div class="ticket-right">
            <div v-if="role !== 'industor' && t.industor" class="ticket-person">
              <span class="person-avatar" :style="{ background: '#0EA5E9' }">{{ t.industor.name?.charAt(0) }}</span>
              <span class="person-name small">{{ t.industor.name }}</span>
            </div>
            <div v-if="(role === 'admin' || role === 'industor') && t.designer" class="ticket-person">
              <span class="person-avatar" :style="{ background: '#39f' }">{{ t.designer.name?.charAt(0) }}</span>
              <span class="person-name small">{{ t.designer.name }}</span>
            </div>
            <CButton color="primary" variant="outline" size="sm" class="btn-open" @click.stop="openTicket(t.id)">
              {{ $t('tickets.open') }} <CIcon icon="cil-arrow-right" class="ms-1" />
            </CButton>
          </div>
        </div>
      </div>
    </CCard>
  </div>
</template>
