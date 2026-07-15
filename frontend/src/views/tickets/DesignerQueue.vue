<script setup>
import { ref, onMounted, onBeforeUnmount, computed } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/api'
import { useAuthStore } from '@/stores/auth'
import { formatDate } from './ticketHelpers'
import { formatPrice } from '@/utils/price'

const router = useRouter()
const auth = useAuthStore()
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

const isAdmin = computed(() => auth.userRole === 'admin')

async function cancelTicket(id) {
  if (!confirm('Delete this ticket? This cannot be undone.')) return
  try {
    await api.post(`/api/tickets/${id}/cancel`)
    await fetchAvailable()
  } catch (e) {
    error.value = e.response?.data?.message || 'Failed to delete ticket.'
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
  <div class="designer-queue-page">
    <div class="queue-top-header"></div>

    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1 fw-bold">
          <CIcon icon="cil-color-border" class="me-2 queue-header-icon" />
          {{ $t('designer_queue.title') }}
        </h3>
        <p class="text-body-secondary mb-0">{{ $t('designer_queue.desc') }}</p>
      </div>
      <CButton color="secondary" variant="outline" size="sm" class="btn-refresh" @click="fetchAvailable">
        <CIcon icon="cil-reload" class="me-1" /> {{ $t('designer_queue.refresh') }}
      </CButton>
    </div>

    <CAlert v-if="error" color="danger" class="mb-3 animated-alert">{{ error }}</CAlert>

    <div v-if="loading" class="text-center py-5 loading-section">
      <div class="loading-spinner-inner">
        <CSpinner color="primary" />
      </div>
    </div>

    <div v-else-if="!tickets.length" class="text-center py-5 empty-state-queue">
      <div class="empty-icon-wrapper mb-3">
        <CIcon icon="cil-color-border" size="3xl" />
      </div>
      <h4 class="fw-semibold">{{ $t('designer_queue.empty') }}</h4>
      <p class="text-body-secondary">{{ $t('designer_queue.empty_desc') }}</p>
    </div>

    <CRow v-else>
      <CCol v-for="(t, idx) in sortedTickets" :key="t.id" md="6" lg="4" class="mb-4 queue-col">
        <CCard
          class="queue-card h-100"
          :class="ticketMetrics(t).type === 'urgent' ? 'queue-card-urgent' : ''"
          :style="{ '--card-delay': idx * 0.08 + 's' }"
        >
          <CCardHeader class="queue-card-header" :class="ticketMetrics(t).type === 'urgent' ? 'queue-card-header-urgent' : ''">
            <div class="d-flex justify-content-between align-items-center w-100">
              <h4 class="card-title mb-0 queue-card-title fs-5">{{ t.title }}</h4>
              <CBadge :color="ticketMetrics(t).type === 'urgent' ? 'danger' : 'success'" class="queue-badge text-uppercase">
                <CIcon v-if="ticketMetrics(t).type === 'urgent'" icon="cil-warning" class="me-1" />
                {{ ticketMetrics(t).type === 'urgent' ? $t('tickets.urgent') : $t('tickets.normal') }}
              </CBadge>
            </div>
          </CCardHeader>

          <CCardBody class="d-flex flex-column">
            <p class="queue-desc flex-grow-1">
              {{ t.description?.slice(0, 120) }}{{ t.description?.length > 120 ? '...' : '' }}
            </p>

            <div class="queue-meta-row">
              <CIcon icon="cil-user" class="meta-icon" />
              <span>{{ t.industor?.name }}</span>
            </div>

            <div v-if="t.designer_price" class="queue-price-row" :class="t.urgent_price_applied ? 'price-urgent' : 'price-normal'">
              <div class="price-label">
                <CIcon icon="cil-money" class="me-1" /> {{ $t('designer_queue.designer_price') }}
              </div>
              <div class="price-value">{{ formatPrice(t.designer_price) }}</div>
              <div v-if="t.urgent_price_applied" class="price-bonus">
                <CIcon icon="cil-arrow-up" class="me-1" />{{ $t('designer_queue.urgent_bonus') }}
              </div>
            </div>

            <div v-if="t.reviewed_at" class="queue-meta-row approved-row">
              <CIcon icon="cil-check-circle" class="approved-icon" />
              {{ $t('designer_queue.approved') }} {{ formatDate(t.reviewed_at) }}
            </div>

            <div
              class="queue-countdown"
              :class="ticketMetrics(t).type === 'urgent' ? 'countdown-urgent' : 'countdown-normal'"
            >
              <div class="countdown-label">
                <CIcon :icon="ticketMetrics(t).type === 'urgent' ? 'cil-bell' : 'cil-clock'" class="me-1" />
                {{ $t('designer_queue.time_remaining') }}
              </div>
              <div class="countdown-digits">
                <span v-if="ticketMetrics(t).parts.days > 0" class="countdown-unit">{{ ticketMetrics(t).parts.days }}<span class="unit-label">d</span></span>
                <span class="countdown-unit">{{ pad(ticketMetrics(t).parts.hours) }}<span class="unit-label">h</span></span>
                <span class="countdown-sep">:</span>
                <span class="countdown-unit">{{ pad(ticketMetrics(t).parts.minutes) }}<span class="unit-label">m</span></span>
                <span class="countdown-sep">:</span>
                <span class="countdown-unit seconds-unit">{{ pad(ticketMetrics(t).parts.seconds) }}<span class="unit-label">s</span></span>
              </div>
              <div v-if="ticketMetrics(t).remaining === 0" class="deadline-passed">
                <CIcon icon="cil-clock-history" class="me-1" /> {{ $t('designer_queue.deadline_passed') }}
              </div>
            </div>

            <div class="queue-progress-section">
              <div class="progress-header">
                <span>{{ $t('designer_queue.time_used') }}</span>
                <span class="progress-pct">{{ (100 - ticketMetrics(t).percentage).toFixed(0) }}%</span>
              </div>
              <CProgress height="6px" class="queue-progress">
                <CProgressBar
                  :color="ticketMetrics(t).type === 'urgent' ? 'danger' : 'success'"
                  class="queue-progress-bar"
                  :value="100 - ticketMetrics(t).percentage"
                />
              </CProgress>
            </div>

            <div class="queue-actions mt-auto">
              <CButton
                :color="ticketMetrics(t).type === 'urgent' ? 'danger' : 'primary'"
                class="btn-accept"
                :class="ticketMetrics(t).type === 'urgent' ? 'btn-accept-urgent' : 'btn-accept-normal'"
                :disabled="accepting === t.id"
                @click="accept(t.id)"
              >
                <CSpinner v-if="accepting === t.id" size="sm" class="me-1" />
                {{ ticketMetrics(t).type === 'urgent' ? $t('designer_queue.accept_urgent') : $t('designer_queue.accept') }}
              </CButton>
              <CButton color="secondary" variant="outline" class="btn-details" @click="openTicket(t.id)">
                {{ $t('designer_queue.details') }} <CIcon icon="cil-arrow-right" class="ms-1" />
              </CButton>
              <CButton v-if="isAdmin" color="danger" variant="ghost" size="sm" class="ms-1" @click.stop="cancelTicket(t.id)">
                <CIcon icon="cil-trash" class="me-1" />{{ $t('admin_products.delete') }}
              </CButton>
            </div>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>
  </div>
</template>

<style scoped>
.designer-queue-page {
  animation: fade-up 0.5s ease-out;
}

.queue-top-header {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.6rem;
  padding: 0.6rem 1rem;
  margin-bottom: 1.2rem;
  border-radius: 12px;
  background: var(--glass-bg);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid var(--glass-border);
  font-size: 0.82rem;
  flex-wrap: wrap;
}
.policy-link {
  color: var(--cui-body-color);
  text-decoration: none;
  cursor: pointer;
  font-weight: 500;
  transition: color 0.2s ease;
}
.policy-link:hover {
  color: var(--cui-primary, #b81300);
}
.policy-sep {
  color: var(--cui-border-color, rgba(0,0,0,0.1));
  font-size: 0.7rem;
}

.queue-header-icon {
  color: var(--cui-primary, #b81300);
}

.btn-refresh {
  border-radius: 50px;
  font-weight: 500;
  font-size: 0.82rem;
  transition: all 0.25s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.btn-refresh:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
}

.animated-alert {
  animation: slide-down 0.35s ease-out;
}

.loading-section {
  .loading-spinner-inner {
    display: inline-flex;
    padding: 1.2rem;
    border-radius: 20px;
    background: var(--glass-bg);
    backdrop-filter: blur(12px);
    border: 1px solid var(--glass-border);
  }
}

.empty-state-queue {
  animation: fade-up 0.6s ease-out;
}
.empty-icon-wrapper {
  display: inline-flex;
  padding: 1.2rem;
  border-radius: 20px;
  background: rgba(184, 19, 0, 0.06);
  color: var(--cui-primary, #b81300);
}

.queue-col {
  animation: fade-up 0.5s ease-out both;
  animation-delay: var(--card-delay, 0s);
}

.queue-card {
  border: none;
  border-radius: 16px;
  background: var(--glass-bg);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid var(--glass-border);
  transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
  overflow: hidden;
  position: relative;
}
.queue-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 24px 64px rgba(0, 0, 0, 0.1);
}
.queue-card-urgent {
  border: 2px solid var(--cui-danger, #e55353);
  box-shadow: 0 0 0 1px rgba(229, 83, 83, 0.1), 0 4px 20px rgba(229, 83, 83, 0.08);
}
.queue-card-urgent:hover {
  box-shadow: 0 24px 64px rgba(229, 83, 83, 0.12);
}

.queue-card-header {
  background: transparent;
  border-bottom: 1px solid var(--glass-border);
  padding: 0.9rem 1.1rem;
  transition: background 0.3s ease;
}
.queue-card-header-urgent {
  background: linear-gradient(135deg, rgba(229, 83, 83, 0.08), rgba(229, 83, 83, 0.02));
  border-bottom-color: rgba(229, 83, 83, 0.15);
}

.queue-card-title {
  font-size: 0.95rem;
  font-weight: 700;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 180px;
  transition: color 0.2s ease;
}
.queue-card:hover .queue-card-title {
  color: var(--cui-primary, #b81300);
}
.queue-card-urgent:hover .queue-card-title {
  color: var(--cui-danger, #e55353);
}

.queue-badge {
  font-size: 0.68rem;
  font-weight: 600;
  padding: 0.25rem 0.6rem;
  border-radius: 50px;
  flex-shrink: 0;
}
.queue-card-urgent .queue-badge {
  animation: pulse-badge 2s ease-in-out infinite;
}

.queue-desc {
  font-size: 0.82rem;
  line-height: 1.55;
  color: var(--cui-body-secondary, #6b7785);
  margin-bottom: 0.75rem;
}

.queue-meta-row {
  display: flex;
  align-items: center;
  gap: 0.45rem;
  font-size: 0.82rem;
  color: var(--cui-body-secondary, #6b7785);
  margin-bottom: 0.5rem;
}
.meta-icon {
  opacity: 0.6;
  width: 1rem;
}

.approved-row {
  font-size: 0.8rem;
}
.approved-icon {
  color: var(--cui-success, #2eb85c);
}

.queue-price-row {
  position: relative;
  display: flex;
  flex-direction: column;
  gap: 2px;
  padding: 0.65rem 0.75rem;
  border-radius: 10px;
  margin-bottom: 0.65rem;
  transition: all 0.3s ease;
}
.price-normal {
  background: linear-gradient(135deg, rgba(46, 184, 92, 0.06), rgba(46, 184, 92, 0.02));
  border: 1px solid rgba(46, 184, 92, 0.1);
}
.price-urgent {
  background: linear-gradient(135deg, rgba(229, 83, 83, 0.08), rgba(229, 83, 83, 0.02));
  border: 1px solid rgba(229, 83, 83, 0.12);
}
.price-label {
  font-size: 0.7rem;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: var(--cui-body-secondary, #6b7785);
  font-weight: 600;
}
.price-value {
  font-size: 1.15rem;
  font-weight: 800;
  background: linear-gradient(135deg, var(--cui-primary, #b81300), var(--cui-info, #39f));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  line-height: 1.2;
}
.price-bonus {
  position: absolute;
  top: 0.5rem;
  right: 0.65rem;
  font-size: 0.68rem;
  font-weight: 600;
  color: var(--cui-warning, #f9b115);
}

.queue-countdown {
  border-radius: 10px;
  padding: 0.7rem 0.6rem;
  margin-bottom: 0.65rem;
  text-align: center;
  transition: all 0.3s ease;
}
.countdown-normal {
  background: var(--cui-light, rgba(0, 0, 0, 0.03));
}
.countdown-urgent {
  background: linear-gradient(135deg, rgba(229, 83, 83, 0.08), rgba(229, 83, 83, 0.02));
  border: 1px solid rgba(229, 83, 83, 0.1);
  animation: countdown-pulse 2s ease-in-out infinite;
}

.countdown-label {
  font-size: 0.72rem;
  color: var(--cui-body-secondary, #6b7785);
  margin-bottom: 0.4rem;
  display: flex;
  align-items: center;
  justify-content: center;
}

.countdown-digits {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 0.15rem;
  font-family: 'SF Mono', 'Fira Code', 'Consolas', monospace;
}

.countdown-unit {
  display: inline-flex;
  align-items: baseline;
  gap: 1px;
  padding: 0.3rem 0.45rem;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 700;
  background: var(--cui-dark, #212631);
  color: #fff;
  min-width: 36px;
  justify-content: center;
}
.countdown-urgent .countdown-unit {
  background: var(--cui-danger, #e55353);
  color: #fff;
}
.unit-label {
  font-size: 0.55rem;
  font-weight: 600;
  opacity: 0.6;
  margin-left: 1px;
}
.seconds-unit {
  transition: transform 0.1s ease;
}
.countdown-urgent .seconds-unit {
  animation: seconds-flash 1s step-end infinite;
}

.countdown-sep {
  font-weight: 700;
  color: var(--cui-body-secondary, #6b7785);
  font-size: 1rem;
  margin: 0 0.1rem;
}

.deadline-passed {
  margin-top: 0.35rem;
  font-size: 0.8rem;
  font-weight: 700;
  color: var(--cui-danger, #e55353);
  display: flex;
  align-items: center;
  justify-content: center;
  animation: pulse-deadline 1.5s ease-in-out infinite;
}

.queue-progress-section {
  margin-bottom: 0.75rem;
}
.progress-header {
  display: flex;
  justify-content: space-between;
  font-size: 0.72rem;
  color: var(--cui-body-secondary, #6b7785);
  margin-bottom: 0.3rem;
}
.progress-pct {
  font-weight: 600;
}
.queue-progress {
  border-radius: 100px;
  overflow: hidden;
  background: var(--cui-light, rgba(0, 0, 0, 0.04));
}
.queue-progress .progress-bar {
  background-image: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.15), transparent);
  background-size: 200% 100%;
  animation: shimmer 2s linear infinite;
}

.queue-actions {
  display: flex;
  gap: 0.5rem;
}

.btn-accept {
  flex: 1;
  border-radius: 10px;
  font-weight: 600;
  font-size: 0.85rem;
  padding: 0.5rem 1rem;
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.btn-accept-normal {
  box-shadow: 0 4px 16px rgba(184, 19, 0, 0.2);
}
.btn-accept-normal:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(184, 19, 0, 0.3);
}
.btn-accept-urgent {
  box-shadow: 0 4px 16px rgba(229, 83, 83, 0.25);
  animation: pulse-glow-btn 2s ease-in-out infinite;
}
.btn-accept-urgent:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 28px rgba(229, 83, 83, 0.4);
}

.btn-details {
  border-radius: 10px;
  font-weight: 500;
  font-size: 0.82rem;
  transition: all 0.25s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.btn-details:hover {
  transform: scale(1.03);
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
}

@keyframes fade-up {
  from { opacity: 0; transform: translateY(24px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes slide-down {
  from { opacity: 0; transform: translateY(-12px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes pulse-badge {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.06); }
}

@keyframes countdown-pulse {
  0%, 100% { border-color: rgba(229, 83, 83, 0.1); }
  50% { border-color: rgba(229, 83, 83, 0.25); }
}

@keyframes seconds-flash {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

@keyframes pulse-deadline {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

@keyframes shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

@keyframes pulse-glow-btn {
  0%, 100% { box-shadow: 0 4px 16px rgba(229, 83, 83, 0.25); }
  50% { box-shadow: 0 4px 28px rgba(229, 83, 83, 0.5); }
}
</style>
