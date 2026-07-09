<script setup>
import { ref, onMounted } from 'vue'
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

async function fetchQueue() {
  loading.value = true
  error.value = ''
  try {
    const { data } = await api.get('/api/tickets/pending-negotiations')
    tickets.value = data.data || []
  } catch (e) {
    error.value = e.response?.data?.message || 'Failed to load review queue.'
  } finally {
    loading.value = false
  }
}

function openTicket(id) {
  router.push(`/tickets/${id}`)
}

onMounted(fetchQueue)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">{{ $t('review_queue.title') }}</h3>
        <p class="text-body-secondary mb-0">{{ $t('review_queue.desc') }}</p>
      </div>
      <CButton color="secondary" variant="outline" size="sm" @click="fetchQueue">
        <CIcon icon="cil-reload" class="me-1" /> {{ $t('review_queue.refresh') }}
      </CButton>
    </div>

    <CAlert v-if="error" color="danger" class="mb-3">{{ error }}</CAlert>

    <div v-if="loading" class="text-center py-5"><CSpinner /></div>

    <div v-else-if="!tickets.length" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-check-circle" size="3xl" class="mb-3" />
      <h4>{{ $t('review_queue.empty') }}</h4>
      <p>{{ $t('review_queue.empty_desc') }}</p>
    </div>

    <CCard v-else class="shadow-sm">
      <CTable hover responsive>
        <CTableHead>
          <CTableRow>
            <CTableHeaderCell>{{ $t('review_queue.ticket') }}</CTableHeaderCell>
            <CTableHeaderCell>{{ $t('review_queue.industor') }}</CTableHeaderCell>
            <CTableHeaderCell>{{ $t('review_queue.industor_proposal') }}</CTableHeaderCell>
            <CTableHeaderCell>{{ $t('review_queue.counter') }}</CTableHeaderCell>
            <CTableHeaderCell>{{ $t('review_queue.created') }}</CTableHeaderCell>
            <CTableHeaderCell class="text-end">{{ $t('review_queue.action') }}</CTableHeaderCell>
          </CTableRow>
        </CTableHead>
        <CTableBody>
          <CTableRow v-for="t in tickets" :key="t.id" style="cursor: pointer" @click="openTicket(t.id)">
            <CTableDataCell class="fw-semibold">{{ t.title }}</CTableDataCell>
            <CTableDataCell>{{ t.industor?.name || '-' }}</CTableDataCell>
            <CTableDataCell class="small">
              <div v-if="t.industor_expected_deadline || t.industor_expected_price">
                <CIcon icon="cil-clock" class="me-1" />{{ formatDate(t.industor_expected_deadline) }}
                <CBadge color="primary" class="ms-1">{{ formatPrice(t.industor_expected_price, 0) }}</CBadge>
              </div>
              <span v-else class="text-body-secondary">-</span>
            </CTableDataCell>
            <CTableDataCell class="small">
              <div v-if="t.industor_counter_deadline || t.industor_counter_price" class="text-info">
                <CIcon icon="cil-arrow-thick-right" class="me-1" />{{ formatDate(t.industor_counter_deadline) }}
                <CBadge color="info" class="ms-1">{{ formatPrice(t.industor_counter_price, 0) }}</CBadge>
              </div>
              <span v-else-if="t.tester_suggested_deadline || t.tester_suggested_price" class="text-warning">
                <CIcon icon="cil-arrow-thick-left" class="me-1" />{{ formatDate(t.tester_suggested_deadline) }}
                <CBadge color="warning" class="ms-1">{{ formatPrice(t.tester_suggested_price, 0) }}</CBadge>
              </span>
              <span v-else class="text-body-secondary">-</span>
            </CTableDataCell>
            <CTableDataCell class="small text-body-secondary">{{ formatDate(t.created_at) }}</CTableDataCell>
            <CTableDataCell class="text-end">
              <CButton color="primary" size="sm" @click.stop="openTicket(t.id)">
                {{ t.status === 'waiting_tester_review' ? $t('review_queue.respond') : $t('review_queue.review') }}
              </CButton>
            </CTableDataCell>
          </CTableRow>
        </CTableBody>
      </CTable>
    </CCard>
  </div>
</template>
