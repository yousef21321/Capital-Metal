<script setup>
import { ref, onMounted, onBeforeUnmount, computed } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/api'
import { formatDate } from './ticketHelpers'

const router = useRouter()
const tickets = ref([])
const loading = ref(true)
const error = ref('')
const accepting = ref(null)

const now = ref(Date.now())
let timer = null

onMounted(() => {
  timer = setInterval(() => {
    now.value = Date.now()
  }, 1000)
})

onBeforeUnmount(() => {
  if (timer) clearInterval(timer)
})

async function fetchAvailable() {
  loading.value = true
  error.value = ''
  try {
    const { data } = await api.get('/api/tickets/available')
    tickets.value = data.data || []
  } catch (e) {
    error.value = e.response?.data?.message || 'Failed to load available tickets.'
  } finally {
    loading.value = false
  }
}

async function accept(id) {
  accepting.value = id
  error.value = ''
  try {
    await api.post(`/api/tickets/${id}/accept`)
    await fetchAvailable()
  } catch (e) {
    error.value = e.response?.data?.message || 'Could not accept ticket.'
  } finally {
    accepting.value = null
  }
}

function openTicket(id) {
  router.push(`/tickets/${id}`)
}

function ticketMetrics(t) {
  const deadlineMs = t.deadline ? new Date(t.deadline).getTime() : 0
  const reviewedMs = t.reviewed_at ? new Date(t.reviewed_at).getTime() : 0

  if (!deadlineMs || !reviewedMs) {
    return { remaining: 0, percentage: 100, type: 'normal', parts: { days: 0, hours: 0, minutes: 0, seconds: 0 } }
  }

  const totalMs = deadlineMs - reviewedMs
  const remainingMs = Math.max(0, deadlineMs - now.value)
  const percentage = totalMs > 0 ? (remainingMs / totalMs) * 100 : 0
  const clampedPct = Math.max(0, Math.min(100, percentage))
  const type = clampedPct > 50 ? 'normal' : 'urgent'

  const totalSec = Math.floor(remainingMs / 1000)
  const days = Math.floor(totalSec / 86400)
  const hours = Math.floor((totalSec % 86400) / 3600)
  const minutes = Math.floor((totalSec % 3600) / 60)
  const seconds = totalSec % 60

  return { remaining: remainingMs, percentage: clampedPct, type, parts: { days, hours, minutes, seconds } }
}

const pad = (n) => String(n).padStart(2, '0')

const sortedTickets = computed(() => {
  return [...tickets.value].sort((a, b) => {
    const ma = ticketMetrics(a)
    const mb = ticketMetrics(b)
    if (ma.type !== mb.type) return ma.type === 'urgent' ? -1 : 1
    return ma.remaining - mb.remaining
  })
})

onMounted(fetchAvailable)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">Available Tickets</h3>
        <p class="text-body-secondary mb-0">Open design requests you can accept. Urgent tickets are highlighted.</p>
      </div>
      <CButton color="secondary" variant="outline" size="sm" @click="fetchAvailable">
        <CIcon icon="cil-reload" class="me-1" /> Refresh
      </CButton>
    </div>

    <CAlert v-if="error" color="danger" class="mb-3">{{ error }}</CAlert>

    <div v-if="loading" class="text-center py-5"><CSpinner /></div>

    <div v-else-if="!tickets.length" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-file" size="3xl" class="mb-3" />
      <h4>No open tickets</h4>
      <p>Check back later for new design requests.</p>
    </div>

    <CRow v-else>
      <CCol v-for="t in sortedTickets" :key="t.id" md="6" lg="4" class="mb-4">
        <CCard
          class="h-100 shadow-sm"
          :class="ticketMetrics(t).type === 'urgent' ? 'border-danger border-2' : 'border-success'"
        >
          <CCardHeader
            class="d-flex justify-content-between align-items-center"
            :class="ticketMetrics(t).type === 'urgent' ? 'bg-danger-subtle' : 'bg-success-subtle'"
          >
            <h5 class="card-title mb-0 text-truncate" style="max-width: 200px;">{{ t.title }}</h5>
            <CBadge :color="ticketMetrics(t).type === 'urgent' ? 'danger' : 'success'" class="text-uppercase">
              <CIcon v-if="ticketMetrics(t).type === 'urgent'" icon="cil-warning" class="me-1" />
              {{ ticketMetrics(t).type === 'urgent' ? 'Urgent' : 'Normal' }}
            </CBadge>
          </CCardHeader>

          <CCardBody class="d-flex flex-column">
            <p class="card-text text-body-secondary small flex-grow-1">
              {{ t.description?.slice(0, 120) }}{{ t.description?.length > 120 ? '...' : '' }}
            </p>

            <div class="small text-body-secondary mb-2">
              <CIcon icon="cil-user" class="me-1" /> {{ t.industor?.name }}
            </div>

            <div v-if="t.designer_price" class="d-flex justify-content-between align-items-center mb-2 p-2 rounded"
              :class="t.urgent_price_applied ? 'bg-warning-subtle' : 'bg-success-subtle'">
              <span class="small fw-semibold">
                <CIcon icon="cil-money" class="me-1" /> Designer Price
              </span>
              <span class="fw-bold fs-5" :class="t.urgent_price_applied ? 'text-warning-emphasis' : 'text-success'">
                {{ parseFloat(t.designer_price).toFixed(2) }} EGP
              </span>
            </div>
            <div v-if="t.urgent_price_applied" class="small text-warning mb-2">
              <CIcon icon="cil-arrow-up" class="me-1" /> +10% urgent bonus applied
            </div>

            <div v-if="t.reviewed_at" class="small text-body-secondary mb-2">
              <CIcon icon="cil-check-circle" class="me-1 text-success" />
              Approved: {{ formatDate(t.reviewed_at) }}
            </div>

            <!-- Countdown -->
            <div
              class="rounded p-2 mb-2 text-center"
              :class="ticketMetrics(t).type === 'urgent' ? 'bg-danger-subtle' : 'bg-light'"
            >
              <div class="small text-body-secondary mb-1">
                <CIcon :icon="ticketMetrics(t).type === 'urgent' ? 'cil-bell' : 'cil-clock'" class="me-1" />
                Time Remaining
              </div>
              <div class="d-flex justify-content-center align-items-center gap-1 font-monospace fs-5">
                <span v-if="ticketMetrics(t).parts.days > 0" class="badge" :class="ticketMetrics(t).type === 'urgent' ? 'text-bg-danger' : 'text-bg-dark'">
                  {{ ticketMetrics(t).parts.days }}d
                </span>
                <span class="badge" :class="ticketMetrics(t).type === 'urgent' ? 'text-bg-danger' : 'text-bg-dark'">{{ pad(ticketMetrics(t).parts.hours) }}</span>
                <span class="text-body-secondary">:</span>
                <span class="badge" :class="ticketMetrics(t).type === 'urgent' ? 'text-bg-danger' : 'text-bg-dark'">{{ pad(ticketMetrics(t).parts.minutes) }}</span>
                <span class="text-body-secondary">:</span>
                <span class="badge" :class="ticketMetrics(t).type === 'urgent' ? 'text-bg-danger' : 'text-bg-dark'">{{ pad(ticketMetrics(t).parts.seconds) }}</span>
              </div>
              <div v-if="ticketMetrics(t).remaining === 0" class="small text-danger fw-bold mt-1">
                <CIcon icon="cil-clock-history" class="me-1" /> Deadline passed
              </div>
            </div>

            <!-- Progress bar -->
            <div class="mb-3">
              <div class="d-flex justify-content-between small text-body-secondary mb-1">
                <span>Time Used</span>
                <span>{{ (100 - ticketMetrics(t).percentage).toFixed(0) }}%</span>
              </div>
              <CProgress height="6px">
                <CProgressBar
                  :color="ticketMetrics(t).type === 'urgent' ? 'danger' : 'success'"
                  :value="100 - ticketMetrics(t).percentage"
                />
              </CProgress>
            </div>

            <div class="d-flex gap-2 mt-auto">
              <CButton
                :color="ticketMetrics(t).type === 'urgent' ? 'danger' : 'primary'"
                class="flex-grow-1"
                :disabled="accepting === t.id"
                @click="accept(t.id)"
              >
                <CSpinner v-if="accepting === t.id" size="sm" class="me-1" />
                {{ ticketMetrics(t).type === 'urgent' ? 'Accept Urgent' : 'Accept' }}
              </CButton>
              <CButton color="secondary" variant="outline" @click="openTicket(t.id)">Details</CButton>
            </div>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>
  </div>
</template>
