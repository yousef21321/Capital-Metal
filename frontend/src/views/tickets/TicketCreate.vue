<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/api'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const auth = useAuthStore()
const form = ref({ title: '', description: '', single_purchase: false, expected_deadline: '', expected_price: '', files: [] })
const submitting = ref(false)
const error = ref('')
const hasSubscription = ref(false)
const loadingStatus = ref(true)

const expectedDeadlineLocal = computed({
  get: () => form.value.expected_deadline,
  set: (v) => { form.value.expected_deadline = v },
})

async function checkSubscription() {
  loadingStatus.value = true
  try {
    const res = await api.get('/api/subscriptions/me')
    hasSubscription.value = res?.data?.approval_status === 'approved' && (res?.data?.tickets_remaining > 0)
  } catch {
    hasSubscription.value = false
  } finally {
    loadingStatus.value = false
  }
}

function onFilesChange(e) {
  form.value.files = Array.from(e.target.files || [])
}

async function submit() {
  submitting.value = true
  error.value = ''
  try {
    const payload = {
      title: form.value.title,
      description: form.value.description,
      expected_deadline: new Date(form.value.expected_deadline).toISOString(),
      expected_price: parseFloat(form.value.expected_price),
    }
    if (!hasSubscription.value) {
      payload.single_purchase = true
    } else if (form.value.single_purchase) {
      payload.single_purchase = true
    }
    const { data } = await api.post('/api/tickets', payload)

    const uploadErrors = []
    for (const file of form.value.files) {
      try {
        const fd = new FormData()
        fd.append('file', file)
        await api.post(`/api/tickets/${data.id}/attachments`, fd, {
          headers: { 'Content-Type': 'multipart/form-data' },
        })
      } catch {
        uploadErrors.push(file.name)
      }
    }
    if (uploadErrors.length) {
      error.value = `Ticket created, but some attachments failed: ${uploadErrors.join(', ')}`
    }
    router.push(`/tickets/${data.id}`)
  } catch (e) {
    error.value = e.response?.data?.message || 'Failed to create ticket.'
  } finally {
    submitting.value = false
  }
}

onMounted(checkSubscription)
</script>

<template>
  <div>
    <CButton color="secondary" variant="ghost" size="sm" class="mb-2" @click="router.push('/tickets')">
      <CIcon icon="cil-arrow-left" class="me-1" /> Back to Tickets
    </CButton>
    <h3 class="mb-4">New Ticket</h3>

    <CRow>
      <CCol :md="8">
        <CCard class="shadow-sm">
          <CCardBody>
            <CAlert v-if="error" color="danger" class="mb-3">{{ error }}</CAlert>

            <CAlert v-if="!loadingStatus && !hasSubscription" color="info" class="mb-3">
              <CIcon icon="cil-info" class="me-1" /> You don't have an active subscription. This ticket will be created as a
              <strong>single-purchase</strong> ticket — you'll pay the price set by the tester after review.
            </CAlert>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">Project Title</CFormLabel>
              <CFormInput v-model="form.title" placeholder="e.g. Logo design for new product" />
            </div>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">Project Description</CFormLabel>
              <CFormTextarea v-model="form.description" rows="8" placeholder="Describe the digital product you need: dimensions, style, references, file format, usage rights..." />
              <div class="form-text">Be as detailed as possible - the tester will review this before approval.</div>
            </div>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">Expected Delivery Deadline</CFormLabel>
              <CFormInput v-model="expectedDeadlineLocal" type="datetime-local" />
              <div class="form-text">Propose a delivery time. The tester will review it and may accept it or negotiate a new deadline.</div>
            </div>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">Expected Price ({{ auth.userCurrency }})</CFormLabel>
              <CFormInput v-model.number="form.expected_price" type="number" min="0" step="0.01" placeholder="e.g. 1000" />
              <div class="form-text">Propose a price. The tester will review it and may accept or counter with a different price.</div>
            </div>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">Project Attachments (optional)</CFormLabel>
              <CFormInput type="file" multiple accept=".pdf,.png,.jpg,.jpeg,.zip" @change="onFilesChange" />
              <div class="form-text">Reference files, briefs, or mockups. You can also add more later from the ticket page.</div>
            </div>

            <div v-if="hasSubscription" class="mb-3">
              <CFormCheck v-model="form.single_purchase" label="Create as single-purchase ticket (pay per ticket instead of using subscription)" />
            </div>

            <div class="d-flex gap-2">
              <CButton color="primary" :disabled="submitting || !form.title || !form.description || !form.expected_deadline || !form.expected_price" @click="submit">
                <CSpinner v-if="submitting" size="sm" class="me-1" />
                {{ (!hasSubscription || form.single_purchase) ? 'Create Single-Purchase Ticket' : 'Create Ticket' }}
              </CButton>
              <CButton color="secondary" variant="outline" @click="router.push('/tickets')">Cancel</CButton>
            </div>
          </CCardBody>
        </CCard>
      </CCol>

      <CCol :md="4">
        <CCard class="shadow-sm bg-body-tertiary">
          <CCardBody>
            <h6 class="fw-bold"><CIcon icon="cil-info" class="me-1" /> How it works</h6>
            <ol class="small text-body-secondary mb-0 ps-3">
              <li>You propose an expected delivery deadline with your ticket.</li>
              <li>The tester reviews it and approves the deadline or negotiates a new one with you.</li>
              <li>Once the deadline is agreed, the tester sets the price.</li>
              <li v-if="!hasSubscription || form.single_purchase">After approval, you pay the set price.</li>
              <li>Designers can then accept it, upload the deliverable, and QA reviews the final design.</li>
            </ol>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>
  </div>
</template>
