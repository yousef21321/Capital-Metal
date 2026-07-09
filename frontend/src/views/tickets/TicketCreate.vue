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
      <CIcon icon="cil-arrow-left" class="me-1" /> {{ $t('ticket_create.back') }}
    </CButton>
    <h3 class="mb-4">{{ $t('ticket_create.title') }}</h3>

    <CRow>
      <CCol :md="8">
        <CCard class="shadow-sm">
          <CCardBody>
            <CAlert v-if="error" color="danger" class="mb-3">{{ error }}</CAlert>

            <CAlert v-if="!loadingStatus && !hasSubscription" color="info" class="mb-3">
              <CIcon icon="cil-info" class="me-1" /> {{ $t('ticket_create.no_subscription') }}
              <strong>{{ $t('ticket_create.single_purchase') }}</strong> {{ $t('ticket_create.after_review') }}
            </CAlert>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">{{ $t('ticket_create.project_title') }}</CFormLabel>
              <CFormInput v-model="form.title" :placeholder="$t('ticket_create.project_title_placeholder')" />
            </div>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">{{ $t('ticket_create.project_description') }}</CFormLabel>
              <CFormTextarea v-model="form.description" rows="8" :placeholder="$t('ticket_create.project_description_placeholder')" />
              <div class="form-text">{{ $t('ticket_create.project_description_help') }}</div>
            </div>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">{{ $t('ticket_create.expected_deadline') }}</CFormLabel>
              <CFormInput v-model="expectedDeadlineLocal" type="datetime-local" />
              <div class="form-text">{{ $t('ticket_create.expected_deadline_help') }}</div>
            </div>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">{{ $t('ticket_create.expected_price') }} ({{ auth.userCurrency }})</CFormLabel>
              <CFormInput v-model.number="form.expected_price" type="number" min="0" step="0.01" :placeholder="$t('ticket_create.expected_price_placeholder')" />
              <div class="form-text">{{ $t('ticket_create.expected_price_help') }}</div>
            </div>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">{{ $t('ticket_create.attachments') }}</CFormLabel>
              <CFormInput type="file" multiple accept=".pdf,.png,.jpg,.jpeg,.zip" @change="onFilesChange" />
              <div class="form-text">{{ $t('ticket_create.attachments_help') }}</div>
            </div>

            <div v-if="hasSubscription" class="mb-3">
              <CFormCheck v-model="form.single_purchase" :label="$t('ticket_create.single_purchase_checkbox')" />
            </div>

            <div class="d-flex gap-2">
              <CButton color="primary" :disabled="submitting || !form.title || !form.description || !form.expected_deadline || !form.expected_price" @click="submit">
                <CSpinner v-if="submitting" size="sm" class="me-1" />
                {{ (!hasSubscription || form.single_purchase) ? $t('ticket_create.create_single') : $t('ticket_create.create') }}
              </CButton>
              <CButton color="secondary" variant="outline" @click="router.push('/tickets')">{{ $t('ticket_create.cancel') }}</CButton>
            </div>
          </CCardBody>
        </CCard>
      </CCol>

      <CCol :md="4">
        <CCard class="shadow-sm bg-body-tertiary">
          <CCardBody>
            <h6 class="fw-bold"><CIcon icon="cil-info" class="me-1" /> {{ $t('ticket_create.how_it_works') }}</h6>
            <ol class="small text-body-secondary mb-0 ps-3">
              <li>{{ $t('ticket_create.step1') }}</li>
              <li>{{ $t('ticket_create.step2') }}</li>
              <li>{{ $t('ticket_create.step3') }}</li>
              <li v-if="!hasSubscription || form.single_purchase">{{ $t('ticket_create.step4') }}</li>
              <li>{{ $t('ticket_create.step5') }}</li>
            </ol>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>
  </div>
</template>
