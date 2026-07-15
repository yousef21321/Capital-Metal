<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '@/api'
import { useAuthStore } from '@/stores/auth'
import { statusMeta, formatDate } from './ticketHelpers'
import { formatPrice } from '@/utils/price'
import Countdown from '@/components/Countdown.vue'
import { useToastStore } from '@/stores/toast'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const toast = useToastStore()

const ticket = ref(null)
const loading = ref(true)
const submitting = ref(false)
const error = ref('')
const success = ref('')

const role = () => auth.userRole

const form = ref({
  modification_desc: '',
  mod_response: '',
  deadline: '',
  penalty: '',
  penalty_reason: '',
  edit_title: '',
  edit_description: '',
  title: '',
  description: '',
  price: 0,
  rejection_reason: '',
  selectedFiles: [],
  uploadNotes: '',
  suggest_deadline: '',
  suggest_price: '',
  suggest_reason: '',
  counter_deadline: '',
  counter_price: '',
  counter_reason: '',
  cancel_reason: '',
  req_file: null,
})
const deliverablePreviews = ref([])

const deadlineLocal = computed({
  get: () => {
    if (!form.value.deadline) return ''
    const d = new Date(form.value.deadline)
    const off = d.getTimezoneOffset()
    return new Date(d.getTime() - off * 60000).toISOString().slice(0, 16)
  },
  set: (v) => { form.value.deadline = v },
})

const reviewDeadlineLocal = computed({
  get: () => {
    if (!form.value.review_deadline) return ''
    const d = new Date(form.value.review_deadline)
    const off = d.getTimezoneOffset()
    return new Date(d.getTime() - off * 60000).toISOString().slice(0, 16)
  },
  set: (v) => { form.value.review_deadline = v },
})

const suggestDeadlineLocal = computed({
  get: () => form.value.suggest_deadline,
  set: (v) => { form.value.suggest_deadline = v },
})

async function fetchTicket() {
  loading.value = true
  error.value = ''
  try {
    const { data } = await api.get(`/api/tickets/${route.params.id}`)
    ticket.value = data
    form.value.title = data.title
    form.value.description = data.description
  } catch (e) {
    error.value = e.response?.data?.message || 'Failed to load ticket.'
  } finally {
    loading.value = false
  }
}

async function action(endpoint, payload = {}) {
  submitting.value = true
  error.value = ''
  success.value = ''
  try {
    await api.post(`/api/tickets/${route.params.id}/${endpoint}`, payload)
    success.value = 'Action completed.'
    await fetchTicket()
  } catch (e) {
    error.value = e.response?.data?.message || 'Action failed.'
  } finally {
    submitting.value = false
  }
}

function onFileChange(e) {
  const files = Array.from(e.target.files || [])
  for (const f of files) {
    form.value.selectedFiles.push(f)
    deliverablePreviews.value.push(URL.createObjectURL(f))
  }
  e.target.value = ''
}

function removeDeliverable(i) {
  URL.revokeObjectURL(deliverablePreviews.value[i])
  deliverablePreviews.value.splice(i, 1)
  form.value.selectedFiles.splice(i, 1)
}

async function uploadDeliverable() {
  if (!form.value.selectedFiles.length) return
  submitting.value = true
  error.value = ''
  success.value = ''
  const fd = new FormData()
  for (const f of form.value.selectedFiles) {
    fd.append('files[]', f)
  }
  if (form.value.uploadNotes) {
    fd.append('notes', form.value.uploadNotes)
  }
  try {
    await api.post(`/api/tickets/${route.params.id}/upload`, fd, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    success.value = 'Uploaded successfully. Awaiting QA.'
    form.value.selectedFiles = []
    form.value.uploadNotes = ''
    await fetchTicket()
  } catch (e) {
    error.value = e.response?.data?.message || 'Upload failed.'
  } finally {
    submitting.value = false
  }
}

async function saveEdit() {
  submitting.value = true
  error.value = ''
  success.value = ''
  try {
    await api.put(`/api/tickets/${route.params.id}`, {
      title: ticket.value.title,
      description: ticket.value.description,
    })
    success.value = 'Ticket updated.'
    await fetchTicket()
  } catch (e) {
    error.value = e.response?.data?.message || 'Update failed.'
  } finally {
    submitting.value = false
  }
}

async function setPrice() {
  submitting.value = true
  error.value = ''
  success.value = ''
  try {
    await api.put(`/api/tickets/${route.params.id}/price`, { original_price: form.value.set_price })
    success.value = 'Price updated. Designer price recalculated at 70%.'
    form.value.set_price = ''
    await fetchTicket()
  } catch (e) {
    error.value = e.response?.data?.message || 'Failed to update price.'
  } finally {
    submitting.value = false
  }
}

async function cancelNegotiation() {
  submitting.value = true
  error.value = ''
  success.value = ''
  try {
    await api.delete(`/api/tickets/${route.params.id}/cancel-negotiation`, { data: { reason: form.value.cancel_reason || null } })
    success.value = 'Negotiation cancelled.'
    await fetchTicket()
  } catch (e) {
    error.value = e.response?.data?.message || 'Failed to cancel negotiation.'
  } finally {
    submitting.value = false
  }
}

function onReqFileChange(e) {
  form.value.req_file = e.target.files?.[0] || null
}

async function uploadRequirement() {
  if (!form.value.req_file) return
  submitting.value = true
  error.value = ''
  success.value = ''
  const fd = new FormData()
  fd.append('file', form.value.req_file)
  try {
    await api.post(`/api/tickets/${route.params.id}/attachments`, fd, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    success.value = 'Project file attached.'
    form.value.req_file = null
    await fetchTicket()
  } catch (e) {
    error.value = e.response?.data?.message || 'Upload failed.'
  } finally {
    submitting.value = false
  }
}

async function payTicket() {
  submitting.value = true
  error.value = ''
  success.value = ''
  try {
    const res = await api.post('/api/paymob/intent', { ticket_id: ticket.value.id })
    if (res.data?.payment_url) {
      window.location.href = res.data.payment_url
      return
    }
    if (res.data?.paid) {
      success.value = 'Payment confirmed! Ticket is now available to designers.'
      await fetchTicket()
    } else {
      error.value = res.data?.message || 'Payment failed.'
    }
  } catch (e) {
    error.value = e.response?.data?.message || 'Payment could not be started.'
  } finally {
    submitting.value = false
  }
}

async function publishToStore() {
  submitting.value = true
  error.value = ''
  success.value = ''
  try {
    await api.post(`/api/tickets/${route.params.id}/publish`, {
      title: form.value.title,
      description: form.value.description,
      price: form.value.price,
    })
    success.value = 'Published to store.'
    await fetchTicket()
  } catch (e) {
    error.value = e.response?.data?.message || 'Publish failed.'
  } finally {
    submitting.value = false
  }
}

async function downloadAttachment(att) {
  try {
    const res = await api.get(`/api/tickets/${ticket.value.id}/attachments/${att.id}/download`, {
      responseType: 'blob',
    })
    const url = window.URL.createObjectURL(res.data)
    const a = document.createElement('a')
    a.href = url
    a.download = att.file_name
    a.click()
    window.URL.revokeObjectURL(url)
  } catch (e) {
    error.value = 'Download failed.'
  }
}

async function deleteProjectFile(att) {
  if (!confirm('Delete this file?')) return
  try {
    await api.delete(`/api/tickets/${ticket.value.id}/attachments/${att.id}`)
    ticket.value.attachments = ticket.value.attachments.filter((a) => a.id !== att.id)
  } catch (e) {
    error.value = e.response?.data?.message || 'Delete failed.'
  }
}

const showQaActions = computed(() => role() === 'tester' && ticket.value?.status === 'awaiting_qa' && (!ticket.value.tester_id || ticket.value.tester_id === auth.user?.id))

const projectFiles = computed(() => (ticket.value?.attachments || []).filter((a) => a.kind === 'requirement'))
const deliverableFiles = computed(() => (ticket.value?.attachments || []).filter((a) => a.kind !== 'requirement'))

const canTesterPropose = computed(() => role() === 'tester' && ['pending_tester_review', 'waiting_tester_review'].includes(ticket.value?.status))
const canIndustorRespond = computed(() => role() === 'industor' && ticket.value?.status === 'waiting_industor_approval' && ticket.value?.industor_id === auth.user?.id)
const inNegotiation = computed(() => ['pending_tester_review', 'waiting_industor_approval', 'waiting_tester_review'].includes(ticket.value?.status))

const planDiscountPercent = computed(() => {
  return ticket.value?.subscription?.plan?.discount_percent || 0
})

function discounted(price) {
  const pct = planDiscountPercent.value
  if (!pct || !price) return price
  return price - (price * pct / 100)
}

const canIndustorCancel = computed(() => {
  if (role() !== 'industor' || ticket.value?.industor_id !== auth.user?.id) return false
  if (!ticket.value?.deadline || !ticket.value?.created_at) return true
  const total = new Date(ticket.value.deadline) - new Date(ticket.value.created_at)
  const elapsed = Date.now() - new Date(ticket.value.created_at)
  return total > 0 && (elapsed / total) <= 0.10
})

onMounted(fetchTicket)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <CButton color="secondary" variant="ghost" size="sm" class="mb-1" @click="router.push('/tickets')">
          <CIcon icon="cil-arrow-left" class="me-1" /> Back
        </CButton>
        <h3 class="mb-0">{{ ticket?.title || 'Ticket' }}</h3>
      </div>
      <CBadge v-if="ticket" :color="statusMeta(ticket.status).color" class="fs-6">
        {{ statusMeta(ticket.status).label }}
      </CBadge>
    </div>

    <div v-if="loading" class="text-center py-5"><CSpinner /></div>

    <template v-else-if="ticket">
      <CAlert v-if="error" color="danger" dismissible class="mb-3">{{ error }}</CAlert>
      <CAlert v-if="success" color="success" dismissible class="mb-3">{{ success }}</CAlert>

      <CRow :gutter="{ md: 24 }">
        <CCol :md="8">
          <!-- Actions (full width, at top) -->
          <CCard class="mb-4 shadow-sm">
            <CCardHeader class="bg-body"><h4 class="mb-0 fs-5">Actions</h4></CCardHeader>
            <CCardBody>
              <!-- Designer actions -->
              <template v-if="role() === 'designer' && ticket.designer_id === auth.user?.id">
                <div v-if="ticket.status === 'accepted'" class="mb-3">
                  <label class="form-label small fw-semibold">Deadline (set by reviewer)</label>
                  <CFormInput :model-value="ticket.deadline ? formatDate(ticket.deadline) : '-'" readonly class="mb-2" />
                  <label class="form-label small fw-semibold">Upload deliverables</label>
                  <CFormInput type="file" multiple accept=".pdf,.png,.jpg,.jpeg" class="mb-2" @change="onFileChange" />
                  <div v-if="deliverablePreviews.length" class="d-flex gap-2 mb-2 flex-wrap">
                    <div v-for="(preview, i) in deliverablePreviews" :key="i" class="position-relative d-inline-flex align-items-center gap-1 rounded border px-2 py-1" style="height: 36px;">
                      <CIcon icon="cil-file" class="text-body-secondary" />
                      <span class="small">{{ form.selectedFiles[i]?.name }}</span>
                      <span role="button" class="badge bg-danger rounded-circle" style="cursor: pointer; width: 18px; height: 18px; line-height: 1; padding: 0;" @click="removeDeliverable(i)">&times;</span>
                    </div>
                  </div>
                  <CFormTextarea v-model="form.uploadNotes" rows="2" placeholder="Add notes (optional)" class="mb-2" />
                  <CButton color="primary" class="w-100" :disabled="submitting || !form.selectedFiles.length" @click="uploadDeliverable">
                    <CSpinner v-if="submitting" size="sm" class="me-1" /> Send
                  </CButton>
                </div>

                <div v-if="['in_progress','rejected_qa'].includes(ticket.status)" class="mt-3 border-top pt-3">
                  <label class="form-label small fw-semibold">Upload deliverables</label>
                  <CFormInput type="file" multiple accept=".pdf,.png,.jpg,.jpeg" class="mb-2" @change="onFileChange" />
                  <div v-if="deliverablePreviews.length" class="d-flex gap-2 mb-2 flex-wrap">
                    <div v-for="(preview, i) in deliverablePreviews" :key="i" class="position-relative d-inline-flex align-items-center gap-1 rounded border px-2 py-1" style="height: 36px;">
                      <CIcon icon="cil-file" class="text-body-secondary" />
                      <span class="small">{{ form.selectedFiles[i]?.name }}</span>
                      <span role="button" class="badge bg-danger rounded-circle" style="cursor: pointer; width: 18px; height: 18px; line-height: 1; padding: 0;" @click="removeDeliverable(i)">&times;</span>
                    </div>
                  </div>
                  <CFormTextarea v-model="form.uploadNotes" rows="2" placeholder="Add notes (optional)" class="mb-2" />
                  <CButton color="primary" class="w-100" :disabled="submitting || !form.selectedFiles.length" @click="uploadDeliverable">
                    <CSpinner v-if="submitting" size="sm" class="me-1" /> Send
                  </CButton>
                  <div v-if="ticket.status === 'rejected_qa'" class="alert alert-warning small mt-2 mb-0">
                    <CIcon icon="cil-warning" /> Previous submission was rejected. Revise and re-upload.
                    <span v-if="ticket.penalty" class="d-block mt-1">
                      <strong>Penalty (خصم):</strong> {{ ticket.penalty }}
                      <span v-if="ticket.penalty_reason"> - {{ ticket.penalty_reason }}</span>
                    </span>
                  </div>
                </div>
              </template>

              <!-- Tester: send suggestion or counter -->
              <template v-if="canTesterPropose">
                <div class="mb-3">
                  <h5 class="small fw-semibold text-uppercase text-body-secondary">
                    {{ ticket.status === 'pending_tester_review' ? 'Send Proposal' : 'Counter Industor' }}
                  </h5>
                  <div v-if="ticket.status === 'waiting_tester_review'" class="small text-body-secondary mb-2">
                    Industor counter: <strong class="text-info">{{ formatDate(ticket.industor_counter_deadline) }}</strong>
                    <CBadge color="info" class="ms-1">{{ formatPrice(ticket.industor_counter_price, 0) }}</CBadge>
                  </div>
                  <div v-if="ticket.status === 'pending_tester_review'" class="small text-body-secondary mb-2">
                    Industor expected: <strong>{{ formatDate(ticket.industor_expected_deadline) }}</strong>
                    <CBadge color="primary" class="ms-1">{{ formatPrice(ticket.industor_expected_price, 0) }}</CBadge>
                  </div>
                  <CButton
                    v-if="ticket.status === 'pending_tester_review'"
                    color="success" class="w-100 mb-3"
                    :disabled="submitting"
                    @click="action('accept-initial')"
                  >
                    <CSpinner v-if="submitting" size="sm" class="me-1" /> Accept Industor's Proposal
                  </CButton>
                  <CRow class="g-2">
                    <CCol :sm="6">
                      <CFormLabel class="small">Suggested Deadline</CFormLabel>
                      <CFormInput v-model="suggestDeadlineLocal" type="datetime-local" />
                    </CCol>
                    <CCol :sm="6">
                      <CFormLabel class="small">Suggested Price ({{ auth.userCurrency }})</CFormLabel>
                      <CFormInput v-model.number="form.suggest_price" type="number" min="0" step="0.01" />
                      <div v-if="planDiscountPercent && form.suggest_price" class="small mt-1">
                        <span class="text-decoration-line-through text-body-secondary">{{ form.suggest_price }}</span>
                        <span class="ms-1 fw-bold text-danger">{{ discounted(parseFloat(form.suggest_price)).toFixed(2) }}</span>
                        <CBadge color="danger" class="ms-1">-{{ planDiscountPercent }}%</CBadge>
                      </div>
                    </CCol>
                  </CRow>
                  <CFormLabel class="small mt-2">Reason (optional)</CFormLabel>
                  <CFormTextarea v-model="form.suggest_reason" rows="2" placeholder="Why this proposal..." class="mb-2" />
                  <CButton
                    color="warning" class="w-100 mb-2"
                    :disabled="submitting || !form.suggest_deadline || !form.suggest_price"
                    @click="action('suggest', { suggested_deadline: new Date(form.suggest_deadline).toISOString(), suggested_price: discounted(parseFloat(form.suggest_price)), reason: form.suggest_reason || null })"
                  >
                    <CSpinner v-if="submitting" size="sm" class="me-1" /> Send Proposal
                  </CButton>

                  <template v-if="ticket.status === 'waiting_tester_review'">
                    <CButton color="success" class="w-100 mb-2" :disabled="submitting" @click="action('accept-counter')">
                      <CSpinner v-if="submitting" size="sm" class="me-1" /> Accept Industor's Counter
                    </CButton>
                  </template>

                  <hr class="my-2" />
                  <CFormLabel class="small">Cancel negotiation</CFormLabel>
                  <CFormTextarea v-model="form.cancel_reason" rows="1" placeholder="Reason (optional)" class="mb-2" />
                  <CButton color="danger" variant="outline" class="w-100" :disabled="submitting" @click="cancelNegotiation">
                    Cancel Negotiation
                  </CButton>
                </div>
              </template>

              <!-- Designer: accept available ticket -->
              <CButton
                v-if="role() === 'designer' && ticket.status === 'approved_by_tester' && !ticket.designer_id"
                color="primary" class="w-100" :disabled="submitting"
                @click="action('accept')"
              >Accept This Ticket</CButton>

              <!-- Industor actions -->
              <template v-if="role() === 'industor' && ticket.industor_id === auth.user?.id">
                <!-- Edit ticket: only during pending_tester_review -->
                <div v-if="ticket.status === 'pending_tester_review'" class="mb-3">
                  <h5 class="small fw-semibold text-uppercase text-body-secondary">Edit Ticket</h5>
                  <CFormInput v-model="ticket.title" placeholder="Title" class="mb-2" />
                  <CFormTextarea v-model="ticket.description" rows="3" placeholder="Description" class="mb-2" />
                  <CButton color="primary" class="w-100 mb-3" :disabled="submitting" @click="saveEdit">Save Changes</CButton>
                </div>

                <!-- Project files: available in active statuses -->
                <div v-if="['pending_tester_review', 'waiting_industor_approval', 'waiting_tester_review', 'accepted', 'in_progress', 'rejected_qa', 'awaiting_qa'].includes(ticket.status)" class="mb-3">
                  <h5 class="small fw-semibold text-uppercase text-body-secondary border-top pt-3">Project Files</h5>
                  <CFormInput type="file" accept=".pdf,.png,.jpg,.jpeg,.zip" class="mb-2" @change="onReqFileChange" />
                  <CButton color="info" variant="outline" class="w-100" :disabled="submitting || !form.req_file" @click="uploadRequirement">
                    <CSpinner v-if="submitting" size="sm" class="me-1" /> Upload File
                  </CButton>

                  <CListGroup v-if="projectFiles.length" class="mt-2">
                    <CListGroupItem v-for="att in projectFiles" :key="att.id" class="d-flex justify-content-between align-items-center small py-1">
                      <span>
                        <CIcon icon="cil-file" class="me-1" />
                        {{ att.file_name }}
                      </span>
                      <div>
                        <CButton color="primary" variant="ghost" size="sm" @click="downloadAttachment(att)">
                          <CIcon icon="cil-cloud-download" />
                        </CButton>
                        <CButton color="danger" variant="ghost" size="sm" @click="deleteProjectFile(att)">
                          <CIcon icon="cil-trash" class="me-1" /> Delete
                        </CButton>
                      </div>
                    </CListGroupItem>
                  </CListGroup>

                  <hr class="my-3" />
                  <CFormLabel class="small">Cancel negotiation</CFormLabel>
                  <CFormTextarea v-model="form.cancel_reason" rows="1" placeholder="Reason (optional)" class="mb-2" />
                  <CButton color="danger" variant="outline" class="w-100" :disabled="submitting" @click="cancelNegotiation">
                    Cancel Negotiation
                  </CButton>
                </div>

                <div v-if="canIndustorRespond" class="mb-3">
                  <h5 class="small fw-semibold text-uppercase text-body-secondary">Tester Proposal</h5>
                  <div class="small mb-2">
                    <div class="text-body-secondary">Your expected</div>
                    <strong>{{ formatDate(ticket.industor_expected_deadline) }}</strong>
                    <CBadge color="primary" class="ms-1">{{ formatPrice(ticket.industor_expected_price, 0) }}</CBadge>
                  </div>
                  <div class="small mb-3">
                    <div class="text-body-secondary">Tester suggests</div>
                    <strong class="text-warning">{{ formatDate(ticket.tester_suggested_deadline) }}</strong>
                    <CBadge color="warning" class="ms-1">{{ formatPrice(ticket.tester_suggested_price, 0) }}</CBadge>
                  </div>
                  <CButton color="success" class="w-100 mb-3" :disabled="submitting" @click="action('accept-suggestion')">
                    <CSpinner v-if="submitting" size="sm" class="me-1" /> Accept Tester's Proposal
                  </CButton>

                  <h5 class="small fw-semibold text-uppercase text-body-secondary border-top pt-3">Counter with your proposal</h5>
                  <CRow class="g-2">
                    <CCol :sm="6">
                      <CFormLabel class="small">Counter Deadline</CFormLabel>
                      <CFormInput v-model="form.counter_deadline" type="datetime-local" />
                    </CCol>
                    <CCol :sm="6">
                      <CFormLabel class="small">Counter Price ({{ auth.userCurrency }})</CFormLabel>
                      <CFormInput v-model.number="form.counter_price" type="number" min="0" step="0.01" />
                      <div v-if="planDiscountPercent && form.counter_price" class="small mt-1">
                        <span class="text-decoration-line-through text-body-secondary">{{ form.counter_price }}</span>
                        <span class="ms-1 fw-bold text-danger">{{ discounted(parseFloat(form.counter_price)).toFixed(2) }}</span>
                        <CBadge color="danger" class="ms-1">-{{ planDiscountPercent }}%</CBadge>
                      </div>
                    </CCol>
                  </CRow>
                  <CFormLabel class="small mt-2">Reason (optional)</CFormLabel>
                  <CFormTextarea v-model="form.counter_reason" rows="2" placeholder="Why this counter..." class="mb-2" />
                  <CButton
                    color="warning" class="w-100 mb-2"
                    :disabled="submitting || !form.counter_deadline || !form.counter_price"
                    @click="action('counter-suggestion', { counter_deadline: new Date(form.counter_deadline).toISOString(), counter_price: discounted(parseFloat(form.counter_price)), reason: form.counter_reason || null })"
                  >
                    <CSpinner v-if="submitting" size="sm" class="me-1" /> Send Counter
                  </CButton>

                  <hr class="my-2" />
                  <CFormLabel class="small">Cancel negotiation</CFormLabel>
                  <CFormTextarea v-model="form.cancel_reason" rows="1" placeholder="Reason (optional)" class="mb-2" />
                  <CButton color="danger" variant="outline" class="w-100" :disabled="submitting" @click="cancelNegotiation">
                    Cancel Negotiation
                  </CButton>
                </div>

                <div v-if="ticket.status === 'pending_payment'" class="mb-3">
                  <h5 class="small fw-semibold text-uppercase text-body-secondary">Payment Required</h5>
                  <div class="alert alert-warning small mb-2">
                    Your ticket was approved by the tester. Price: <strong>{{ formatPrice(ticket.price) }}</strong>
                    <span v-if="ticket.is_single_purchase" class="d-block mt-1">Single-purchase ticket — pay to make it available to designers.</span>
                  </div>
                  <CButton color="success" class="w-100" :disabled="submitting" @click="payTicket">
                    <CSpinner v-if="submitting" size="sm" class="me-1" />
                    Pay {{ formatPrice(ticket.price) }}
                  </CButton>
                </div>

                <div v-if="ticket.status === 'modification_requested'" class="mb-3">
                  <h5 class="small fw-semibold text-uppercase text-body-secondary">Modification Request</h5>
                  <CFormTextarea v-model="form.mod_response" rows="2" placeholder="Response (optional)" />
                  <div class="d-flex gap-2 mt-2">
                    <CButton color="success" class="flex-grow-1" :disabled="submitting" @click="action('modification/approve')">Approve</CButton>
                    <CButton color="danger" variant="outline" class="flex-grow-1" :disabled="submitting" @click="action('modification/reject', { industor_response: form.mod_response })">Reject</CButton>
                  </div>
                </div>

                <div v-if="ticket.status === 'completed' && ticket.can_publish_to_store" class="mt-3 border-top pt-3">
                  <h5 class="small fw-semibold text-uppercase text-body-secondary">Publish to Store</h5>
                  <CFormInput v-model="form.title" placeholder="Listing title" class="mb-2" />
                  <CFormInput v-model.number="form.price" type="number" min="0" placeholder="Price" class="mb-2" />
                  <CButton color="info" class="w-100" :disabled="submitting" @click="publishToStore">
                    <CIcon icon="cil-share" class="me-1" /> Publish
                  </CButton>
                </div>
                <div v-else-if="ticket.status === 'completed' && !ticket.can_publish_to_store" class="text-body-secondary small mt-3">
                  Your plan does not allow publishing to the store.
                </div>

                <CButton
                  v-if="['pending_payment','approved_by_tester','accepted','modification_requested','in_progress'].includes(ticket.status) && canIndustorCancel"
                  color="danger" variant="outline" class="w-100 mt-3" :disabled="submitting"
                  @click="action('cancel')"
                >Cancel Ticket</CButton>
              </template>

              <!-- Tester QA actions -->
              <template v-if="showQaActions">
                <CButton v-if="!ticket.tester_id" color="primary" class="w-100 mb-3" :disabled="submitting" @click="action('qa/claim')">Claim for Review</CButton>

                <div v-if="ticket.tester_id === auth.user?.id" class="mt-3 border-top pt-3">
                  <label class="form-label small fw-semibold">Rejection reason (if rejecting)</label>
                  <CFormTextarea v-model="form.rejection_reason" rows="2" placeholder="What needs fixing..." />
                  <CRow class="mt-2 g-2">
                    <CCol :sm="6">
                      <CFormLabel class="small">Penalty / خصم ({{ auth.userCurrency }})</CFormLabel>
                      <CFormInput v-model="form.penalty" type="number" min="0" step="0.01" placeholder="0" />
                    </CCol>
                    <CCol :sm="6">
                      <CFormLabel class="small">Penalty reason</CFormLabel>
                      <CFormInput v-model="form.penalty_reason" placeholder="e.g. late delivery" />
                    </CCol>
                  </CRow>
                  <div class="d-flex gap-2 mt-2">
                    <CButton color="success" class="flex-grow-1" :disabled="submitting" @click="action('qa/approve')">Approve</CButton>
                    <CButton color="danger" variant="outline" class="flex-grow-1" :disabled="submitting || !form.rejection_reason" @click="action('qa/reject', { rejection_reason: form.rejection_reason, penalty: form.penalty || null, penalty_reason: form.penalty_reason || null })">Reject</CButton>
                  </div>
                </div>
              </template>

              <div v-if="ticket.is_published_to_store" class="alert alert-info small mt-3 mb-0">
                <CIcon icon="cil-check-circle" /> Published to store.
              </div>
            </CCardBody>
          </CCard>

          <CCard class="mb-4 shadow-sm">
            <CCardHeader class="bg-body"><h4 class="mb-0 fs-5">Project Details</h4></CCardHeader>
            <CCardBody>
              <p class="text-body">{{ ticket.description }}</p>
              <hr />
              <CRow class="small">
                <CCol :sm="6" class="mb-2">
                  <span class="text-body-secondary d-block">Industor</span>
                  <strong>{{ ticket.industor?.name || '-' }}</strong>
                </CCol>
                <CCol :sm="6" class="mb-2">
                  <span class="text-body-secondary d-block">Designer</span>
                  <strong>{{ ticket.designer?.name || '-' }}</strong>
                </CCol>
                <CCol :sm="6" class="mb-2">
                  <span class="text-body-secondary d-block">Tester</span>
                  <strong>{{ ticket.tester?.name || '-' }}</strong>
                </CCol>
                <CCol :sm="6" class="mb-2">
                  <span class="text-body-secondary d-block">Created</span>
                  <strong>{{ formatDate(ticket.created_at) }}</strong>
                </CCol>
                <CCol v-if="ticket.industor_price !== null && ticket.industor_price !== undefined && role() !== 'designer'" :sm="6" class="mb-2">
                  <span class="text-body-secondary d-block">Industor Price</span>
                  <strong>{{ formatPrice(ticket.industor_price) }}</strong>
                </CCol>
                <CCol v-if="ticket.designer_price !== null && ticket.designer_price !== undefined && role() !== 'industor'" :sm="6" class="mb-2">
                  <span class="text-body-secondary d-block">Designer Price
                    <CBadge v-if="ticket.urgent_price_applied" color="warning" class="ms-1">+10%</CBadge>
                  </span>
                  <strong class="text-success">{{ formatPrice(ticket.designer_price) }}</strong>
                </CCol>
                <CCol v-if="ticket.review_notes" :sm="6" class="mb-2">
                  <span class="text-body-secondary d-block">Reviewer</span>
                  <strong>{{ ticket.reviewer?.name || '-' }}</strong>
                </CCol>
                <CCol v-if="ticket.is_late" :sm="6" class="mb-2">
                  <span class="text-body-secondary d-block">Late Flag</span>
                  <strong class="text-danger">Submitted late</strong>
                </CCol>
              </CRow>
              <div v-if="ticket.price_history?.length" class="mt-3">
                <h5 class="small text-uppercase text-body-secondary">Price History</h5>
                <CListGroup flush>
                  <CListGroupItem v-for="ph in ticket.price_history" :key="ph.id" class="d-flex justify-content-between small px-0">
                    <span>
                      <CBadge :color="ph.change_reason === 'urgent_increase' ? 'warning' : 'secondary'" class="me-1">{{ ph.change_reason }}</CBadge>
                      <span v-if="ph.industor_price != null" class="me-2">Industor: {{ formatPrice(ph.industor_price) }}</span>
                      <span v-if="ph.designer_price != null">Designer: {{ formatPrice(ph.designer_price) }}</span>
                    </span>
                    <span class="text-body-secondary">{{ formatDate(ph.created_at) }}</span>
                  </CListGroupItem>
                </CListGroup>
              </div>
              <div v-if="ticket.review_notes" class="alert alert-info mt-3 mb-0 small">
                <strong>Review notes:</strong> {{ ticket.review_notes }}
              </div>
              <div v-if="ticket.penalty" class="alert alert-warning mt-3 mb-0 small">
                <strong>Penalty (خصم):</strong> {{ formatPrice(ticket.penalty) }}
                <span v-if="ticket.penalty_reason"> - {{ ticket.penalty_reason }}</span>
                <div v-if="ticket.price" class="mt-1">
                  <strong>Net earnings:</strong> {{ formatPrice(ticket.designer_earnings || (parseFloat(ticket.price) - parseFloat(ticket.penalty))) }}
                </div>
              </div>
              <div v-if="ticket.rejection_reason" class="alert alert-danger mt-3 mb-0">
                <strong>Rejection reason:</strong> {{ ticket.rejection_reason }}
              </div>
            </CCardBody>
          </CCard>

          <!-- Price & Deadline Negotiation -->
          <CCard
            v-if="ticket.industor_expected_deadline || ticket.deadline_negotiations?.length"
            class="mb-4 shadow-sm border-info"
          >
            <CCardHeader class="bg-body d-flex justify-content-between align-items-center">
              <h4 class="mb-0 fs-5"><CIcon icon="cil-handshake" class="me-1" /> Price & Deadline Negotiation</h4>
              <CBadge v-if="ticket.final_deadline" color="success">Agreed</CBadge>
              <CBadge v-else-if="ticket.status === 'waiting_industor_approval'" color="warning">Awaiting Industor</CBadge>
              <CBadge v-else-if="ticket.status === 'waiting_tester_review'" color="warning">Awaiting Tester</CBadge>
              <CBadge v-else color="info">In Negotiation</CBadge>
            </CCardHeader>
            <CCardBody>
              <CRow class="small mb-3">
                <CCol :sm="6" class="mb-2">
                  <span class="text-body-secondary d-block">Industor Expected</span>
                  <strong>{{ formatDate(ticket.industor_expected_deadline) }}</strong>
                  <CBadge color="primary" class="ms-1">{{ formatPrice(ticket.industor_expected_price, 0) }}</CBadge>
                </CCol>
                <CCol v-if="ticket.tester_suggested_deadline" :sm="6" class="mb-2">
                  <span class="text-body-secondary d-block">Tester Suggested</span>
                  <strong class="text-warning">{{ formatDate(ticket.tester_suggested_deadline) }}</strong>
                  <CBadge color="warning" class="ms-1">{{ formatPrice(ticket.tester_suggested_price, 0) }}</CBadge>
                </CCol>
                <CCol v-if="ticket.industor_counter_deadline" :sm="6" class="mb-2">
                  <span class="text-body-secondary d-block">Industor Counter</span>
                  <strong class="text-info">{{ formatDate(ticket.industor_counter_deadline) }}</strong>
                  <CBadge color="info" class="ms-1">{{ formatPrice(ticket.industor_counter_price, 0) }}</CBadge>
                </CCol>
                <CCol v-if="ticket.final_deadline" :sm="6" class="mb-2">
                  <span class="text-body-secondary d-block">Final Agreed</span>
                  <strong class="text-success">{{ formatDate(ticket.final_deadline) }}</strong>
                  <CBadge color="success" class="ms-1">{{ formatPrice(ticket.final_price, 0) }}</CBadge>
                </CCol>
              </CRow>

              <div v-if="ticket.deadline_negotiations?.length">
                <h5 class="small text-uppercase text-body-secondary">Negotiation History (Round {{ ticket.current_negotiation_round }})</h5>
                <div class="d-flex flex-column gap-2">
                  <div
                    v-for="n in ticket.deadline_negotiations"
                    :key="n.id"
                    class="d-flex align-items-start gap-2 small"
                  >
                    <CBadge :color="n.proposed_by === 'industor' ? 'primary' : 'warning'" class="text-capitalize">
                      {{ n.proposed_by }}
                    </CBadge>
                    <div>
                      <span>{{ formatDate(n.proposed_deadline) }}</span>
                      <CBadge color="secondary" class="ms-1">{{ formatPrice(n.proposed_price, 0) }}</CBadge>
                      <CBadge
                        :color="n.status === 'accepted' ? 'success' : (n.status === 'rejected' ? 'danger' : 'secondary')"
                        class="ms-1 text-capitalize"
                      >{{ n.status }}</CBadge>
                      <span v-if="n.reason" class="d-block text-body-secondary">{{ n.reason }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </CCardBody>
          </CCard>

          <!-- Modification requests -->
          <CCard v-if="ticket.modification_requests?.length" class="mb-4 shadow-sm border-warning">
            <CCardHeader class="bg-body"><h4 class="mb-0 fs-5"><CIcon icon="cil-comment-square" class="me-1" /> Modification Requests</h4></CCardHeader>
            <CCardBody>
              <div v-for="m in ticket.modification_requests" :key="m.id" class="border-bottom pb-2 mb-2 last:border-0">
                <div class="d-flex justify-content-between">
                  <strong>{{ m.designer?.name }}</strong>
                  <CBadge :color="m.status === 'pending' ? 'warning' : (m.status === 'approved' ? 'success' : 'danger')">{{ m.status }}</CBadge>
                </div>
                <p class="mb-1 small">{{ m.description }}</p>
                <p v-if="m.industor_response" class="mb-0 small text-body-secondary">Response: {{ m.industor_response }}</p>
              </div>
            </CCardBody>
          </CCard>

          <!-- Countdown -->
          <CCard v-if="ticket.deadline" class="mb-4 shadow-sm border-warning">
            <CCardBody class="d-flex justify-content-between align-items-center">
              <div>
                <span class="text-body-secondary d-block small">Delivery Deadline</span>
                <strong>{{ formatDate(ticket.deadline) }}</strong>
              </div>
              <Countdown :deadline="ticket.deadline" :active="!['completed','cancelled','awaiting_qa','rejected_by_industor','rejected_by_tester'].includes(ticket.status)" />
            </CCardBody>
          </CCard>

          <!-- Attachments -->
          <CCard class="mb-4 shadow-sm">
            <CCardHeader class="bg-body"><h4 class="mb-0 fs-5">Deliverables</h4></CCardHeader>
            <CCardBody>
              <div v-if="!deliverableFiles.length" class="text-body-secondary small">No files uploaded yet.</div>
              <CListGroup v-else>
                <CListGroupItem v-for="att in deliverableFiles" :key="att.id" class="d-flex justify-content-between align-items-center">
                  <span>
                    <CIcon icon="cil-file" class="me-2 text-body-secondary" />
                    {{ att.file_name }}
                    <span class="text-body-secondary ms-2 small">{{ (att.file_size / 1024).toFixed(0) }} KB</span>
                  </span>
                  <CButton color="primary" variant="ghost" size="sm" @click="downloadAttachment(att)">
                    <CIcon icon="cil-cloud-download" /> Download
                  </CButton>
                </CListGroupItem>
              </CListGroup>
            </CCardBody>
          </CCard>

          <!-- History -->
          <CCard class="shadow-sm">
            <CCardHeader class="bg-body"><h4 class="mb-0 fs-5">Status History</h4></CCardHeader>
            <CCardBody>
              <div class="d-flex flex-column gap-2">
                <div v-for="h in ticket.histories" :key="h.id" class="d-flex align-items-start gap-3">
                  <CBadge :color="statusMeta(h.to_status).color">{{ statusMeta(h.to_status).label }}</CBadge>
                  <div class="small">
                    <div>{{ h.note || `Status changed to ${h.to_status}` }}</div>
                    <span class="text-body-secondary">{{ formatDate(h.created_at) }} - {{ h.changed_by?.name }}</span>
                  </div>
                </div>
              </div>
            </CCardBody>
          </CCard>
        </CCol>

        <!-- Right sidebar -->
        <CCol :md="4" class="align-self-start">

        </CCol>
      </CRow>
    </template>
  </div>
</template>

<style scoped>
/* ── Page container ── */
:deep(.container-fluid), :deep(.container) {
  max-width: 1320px;
}

/* ── All cards ── */
:deep(.card) {
  border: none;
  border-radius: 20px;
  box-shadow: 0 1px 2px rgba(0,0,0,.03), 0 4px 20px rgba(0,0,0,.04);
  transition: box-shadow .25s ease, transform .2s ease;
}
:deep(.card:hover) {
  box-shadow: 0 1px 2px rgba(0,0,0,.03), 0 10px 30px rgba(0,0,0,.06);
}
:deep(.card-header) {
  border-bottom: none;
  padding: 1.1rem 1.35rem;
  font-weight: 600;
  background: transparent;
  border-radius: 20px 20px 0 0 !important;
}
:deep(.card-body) {
  padding: 1.35rem;
}
:deep(.card.border-info) {
  border-left: 4px solid #0dcaf0 !important;
}
:deep(.card.border-warning) {
  border-left: 4px solid #ffc107 !important;
}
:deep(.card.border-success) {
  border-left: 4px solid #198754 !important;
}
:deep(.card.border-danger) {
  border-left: 4px solid #dc3545 !important;
}

/* ── Badges ── */
:deep(.badge) {
  font-weight: 500;
  padding: .35em .8em;
  border-radius: 100px;
  font-size: .75rem;
}

/* ── List group ── */
:deep(.list-group-item) {
  border: none;
  border-radius: 12px;
  margin-bottom: 4px;
  background: #f8fafc;
  transition: background .15s ease, transform .15s ease;
}
:deep(.list-group-item:hover) {
  background: #f1f5f9;
  transform: translateX(4px);
}

/* ── Alerts ── */
:deep(.alert) {
  border: none;
  border-radius: 14px;
  padding: .85rem 1.1rem;
}

/* ── Buttons ── */
:deep(.btn) {
  border-radius: 12px;
  font-weight: 600;
  padding: .55rem 1.1rem;
  transition: all .2s ease;
  letter-spacing: .2px;
}
:deep(.btn:hover) {
  transform: translateY(-2px);
}
:deep(.btn:active) {
  transform: translateY(0);
}
:deep(.btn-ghost), :deep(.btn.btn-ghost), :deep([class*="variant-ghost"]) {
  border-radius: 8px;
}

/* ── Form controls ── */
:deep(.form-control),
:deep(.form-select) {
  border-radius: 12px;
  border: 1.5px solid #e2e8f0;
  padding: .55rem .85rem;
  transition: border-color .2s ease, box-shadow .2s ease;
}
:deep(.form-control:focus),
:deep(.form-select:focus) {
  border-color: #667eea;
  box-shadow: 0 0 0 4px rgba(102,126,234,.12);
}
:deep(.form-label) {
  font-weight: 600;
  color: #374151;
  margin-bottom: .35rem;
  font-size: .82rem;
}

/* ── Headings inside cards ── */
:deep(.card-header h4) {
  font-weight: 700;
  letter-spacing: -.2px;
  display: flex;
  align-items: center;
  gap: 6px;
}

/* ── Countdown ── */
:deep(.countdown) {
  font-variant-numeric: tabular-nums;
  letter-spacing: 1px;
}

/* ── Gradient buttons (global) ── */
:deep(.btn-primary) {
  background: linear-gradient(135deg, #667eea, #764ba2);
  border: none;
  box-shadow: 0 4px 14px rgba(102,126,234,.3);
}
:deep(.btn-success) {
  background: linear-gradient(135deg, #11998e, #38ef7d);
  border: none;
  box-shadow: 0 4px 14px rgba(17,153,142,.25);
}
:deep(.btn-warning) {
  background: linear-gradient(135deg, #f093fb, #f5576c);
  border: none;
  color: #fff;
  box-shadow: 0 4px 14px rgba(245,87,108,.25);
}
:deep(.btn-danger) {
  background: linear-gradient(135deg, #eb3349, #f45c43);
  border: none;
  box-shadow: 0 4px 14px rgba(235,51,73,.25);
}
:deep(.btn-info) {
  background: linear-gradient(135deg, #4facfe, #00f2fe);
  border: none;
  color: #fff;
  box-shadow: 0 4px 14px rgba(79,172,254,.25);
}
:deep(.btn-outline-danger) {
  background: transparent;
  border: 1.5px solid #eb3349;
  color: #eb3349;
  box-shadow: none;
}
:deep(.btn-outline-danger:hover) {
  background: linear-gradient(135deg, #eb3349, #f45c43);
  color: #fff;
  border-color: transparent;
  box-shadow: 0 4px 14px rgba(235,51,73,.25);
}
:deep(.btn:hover) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0,0,0,.15) !important;
}

/* ── Small labels / section titles ── */
:deep(.small.text-body-secondary) {
  font-weight: 600;
  letter-spacing: .5px;
  font-size: .7rem;
  text-transform: uppercase;
}

/* ── Horizontal rule ── */
:deep(hr) {
  opacity: .35;
  margin: 1rem 0;
}

/* ── Price badges inside negotiation ── */
:deep(.card .badge + .badge) {
  margin-left: 4px;
}

/* ── File list items ── */
:deep(.list-group-item .btn-ghost),
:deep(.list-group-item [class*="variant-ghost"]) {
  opacity: .7;
  transition: opacity .2s ease;
}
:deep(.list-group-item:hover .btn-ghost),
:deep(.list-group-item:hover [class*="variant-ghost"]) {
  opacity: 1;
}
</style>
