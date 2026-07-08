<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/api'
import { useAuthStore } from '@/stores/auth'
import { formatDate } from './ticketHelpers'

const router = useRouter()
const auth = useAuthStore()
const tickets = ref([])
const loading = ref(true)
const error = ref('')
const claiming = ref(null)

async function fetchQueue() {
  loading.value = true
  error.value = ''
  try {
    const { data } = await api.get('/api/tickets/qa-queue')
    tickets.value = data.data || []
  } catch (e) {
    error.value = e.response?.data?.message || 'Failed to load QA queue.'
  } finally {
    loading.value = false
  }
}

async function claim(id) {
  claiming.value = id
  error.value = ''
  try {
    await api.post(`/api/tickets/${id}/qa/claim`)
    await fetchQueue()
    router.push(`/tickets/${id}`)
  } catch (e) {
    error.value = e.response?.data?.message || 'Could not claim ticket.'
  } finally {
    claiming.value = null
  }
}

const isAdmin = computed(() => auth.userRole === 'admin')

function openTicket(id) {
  router.push(`/tickets/${id}`)
}

async function cancelTicket(id) {
  if (!confirm('Delete this ticket? This cannot be undone.')) return
  try {
    await api.post(`/api/tickets/${id}/cancel`)
    await fetchQueue()
  } catch (e) {
    error.value = e.response?.data?.message || 'Failed to delete ticket.'
  }
}

onMounted(fetchQueue)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">{{ $t('qa_queue.title') }}</h3>
        <p class="text-body-secondary mb-0">{{ $t('qa_queue.desc') }}</p>
      </div>
      <CButton color="secondary" variant="outline" size="sm" @click="fetchQueue">
        <CIcon icon="cil-reload" class="me-1" /> {{ $t('qa_queue.refresh') }}
      </CButton>
    </div>

    <CAlert v-if="error" color="danger" class="mb-3">{{ error }}</CAlert>

    <div v-if="loading" class="text-center py-5"><CSpinner /></div>

    <div v-else-if="!tickets.length" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-check-circle" size="3xl" class="mb-3" />
      <h4>{{ $t('qa_queue.empty') }}</h4>
      <p>{{ $t('qa_queue.empty_desc') }}</p>
    </div>

    <CCard v-else class="shadow-sm">
      <CTable hover responsive>
        <CTableHead>
          <CTableRow>
            <CTableHeaderCell>{{ $t('qa_queue.ticket') }}</CTableHeaderCell>
            <CTableHeaderCell>{{ $t('qa_queue.designer') }}</CTableHeaderCell>
            <CTableHeaderCell>{{ $t('qa_queue.industor') }}</CTableHeaderCell>
            <CTableHeaderCell>{{ $t('qa_queue.uploaded') }}</CTableHeaderCell>
            <CTableHeaderCell class="text-end">{{ $t('qa_queue.action') }}</CTableHeaderCell>
          </CTableRow>
        </CTableHead>
        <CTableBody>
          <CTableRow v-for="t in tickets" :key="t.id">
            <CTableDataCell class="fw-semibold">{{ t.title }}</CTableDataCell>
            <CTableDataCell>{{ t.designer?.name || '-' }}</CTableDataCell>
            <CTableDataCell>{{ t.industor?.name || '-' }}</CTableDataCell>
            <CTableDataCell class="small text-body-secondary">{{ formatDate(t.uploaded_at) }}</CTableDataCell>
            <CTableDataCell class="text-end">
              <CButton color="success" size="sm" :disabled="claiming === t.id" @click="claim(t.id)">
                <CSpinner v-if="claiming === t.id" size="sm" class="me-1" /> {{ $t('qa_queue.review') }}
              </CButton>
              <CButton v-if="isAdmin" color="danger" variant="ghost" size="sm" class="ms-1" @click="cancelTicket(t.id)">
                <CIcon icon="cil-trash" class="me-1" />{{ $t('admin_products.delete') }}
              </CButton>
            </CTableDataCell>
          </CTableRow>
        </CTableBody>
      </CTable>
    </CCard>
  </div>
</template>
