<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/api'
import { useAuthStore } from '@/stores/auth'
import { useToastStore } from '@/stores/toast'
import { formatPrice } from '@/utils/price'

const auth = useAuthStore()
const toast = useToastStore()
const plans = ref([])
const subscription = ref(null)
const loading = ref(true)
const subscribing = ref(null)
const error = ref('')

const isIndustor = () => auth.userRole === 'industor'
const isAdmin = computed(() => auth.userRole === 'admin')

const planModal = ref(false)
const editingPlan = ref(false)
const savingPlan = ref(false)
const planForm = ref({ name: '', price: 0, currency: 'EGP', duration_days: 30, ticket_limit: 1, can_publish_to_store: false, discount_percent: null })

function emptyPlan() {
  return { name: '', price: 0, currency: 'EGP', duration_days: 30, ticket_limit: 1, can_publish_to_store: false, discount_percent: null }
}

function openCreatePlan() {
  planForm.value = emptyPlan()
  editingPlan.value = false
  planModal.value = true
}

function openEditPlan(plan) {
  planForm.value = { ...plan }
  editingPlan.value = true
  planModal.value = true
}

async function savePlan() {
  savingPlan.value = true
  try {
    if (editingPlan.value) {
      await api.put(`/api/plans/${planForm.value.id}`, planForm.value)
      toast.success('Plan updated.')
    } else {
      await api.post('/api/plans', planForm.value)
      toast.success('Plan created.')
    }
    planModal.value = false
    await load()
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to save plan.')
  } finally {
    savingPlan.value = false
  }
}

async function deletePlan(plan) {
  if (!confirm(`Delete plan "${plan.name}"?`)) return
  try {
    await api.delete(`/api/plans/${plan.id}`)
    toast.success('Plan deleted.')
    await load()
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to delete plan.')
  }
}

async function load() {
  loading.value = true
  try {
    const [plansRes, subRes] = await Promise.all([
      api.get('/api/plans'),
      api.get('/api/subscriptions/me').catch(() => null),
    ])
    plans.value = plansRes.data
    subscription.value = subRes?.data ?? null
  } catch (e) {
    error.value = 'Failed to load plans.'
  } finally {
    loading.value = false
  }
}

async function subscribe(planId) {
  subscribing.value = planId
  error.value = ''
  try {
    const { data } = await api.post('/api/subscriptions', { plan_id: planId })
    const subId = data.id || data.subscription?.id

    const payRes = await api.post('/api/paymob/intent', {
      subscription_id: subId,
    }).catch((e) => e.response)

    if (payRes?.data?.payment_url) {
      window.location.href = payRes.data.payment_url
      return
    }

    if (payRes?.data?.paid) {
      toast.success('Subscription paid and approved!')
    } else {
      toast.error(payRes?.data?.message || 'Subscription payment failed.')
    }

    await load()
  } catch (e) {
    error.value = e.response?.data?.message || 'Subscription failed.'
  } finally {
    subscribing.value = null
  }
}

const money = (p) => formatPrice(p.price)

const approvalBadge = (status) => {
  const map = { pending: { color: 'warning', key: 'pending_approval' }, approved: { color: 'success', key: 'approved' }, rejected: { color: 'danger', key: 'rejected' } }
  return map[status] || { color: 'secondary', key: status }
}

onMounted(load)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">{{ $t('plans.title') }}</h3>
        <p class="text-body-secondary mb-0">{{ $t('plans.desc') }}</p>
      </div>
      <CButton v-if="isAdmin" color="primary" @click="openCreatePlan">
        <CIcon icon="cil-plus" class="me-1" /> Add Plan
      </CButton>
    </div>

    <CAlert v-if="error" color="danger" class="mb-3">{{ error }}</CAlert>

    <CCard v-if="subscription?.subscription" class="mb-4 shadow-sm" :class="subscription.approval_status === 'approved' ? 'border-success' : 'border-warning'">
      <CCardBody class="d-flex flex-wrap justify-content-between align-items-center">
        <div>
          <span class="text-body-secondary small">{{ $t('plans.current_plan') }}</span>
          <h5 class="mb-0">{{ subscription.subscription.plan?.name }}</h5>
        </div>
        <div class="d-flex align-items-center gap-3 flex-wrap">
          <CBadge :color="approvalBadge(subscription.approval_status).color">{{ $t('plans.' + approvalBadge(subscription.approval_status).key) }}</CBadge>
          <template v-if="subscription.approval_status === 'approved'">
            <div class="text-center">
              <div class="fs-4 fw-bold text-primary">{{ subscription.tickets_remaining }}</div>
              <small class="text-body-secondary">{{ $t('plans.tickets_left') }}</small>
            </div>
            <div class="text-center">
              <div class="fs-4 fw-bold">{{ subscription.can_publish_to_store ? $t('plans.yes') : $t('plans.no') }}</div>
              <small class="text-body-secondary">{{ $t('plans.store_publishing') }}</small>
            </div>
          </template>
        </div>
      </CCardBody>
    </CCard>

    <div v-if="loading" class="text-center py-5"><CSpinner /></div>

    <!-- Admin table view -->
    <CCard v-else-if="isAdmin" class="shadow-sm">
      <CTable hover responsive align="middle">
        <CTableHead>
          <CTableRow>
            <CTableHeaderCell>Name</CTableHeaderCell>
            <CTableHeaderCell>Price</CTableHeaderCell>
            <CTableHeaderCell>Duration</CTableHeaderCell>
            <CTableHeaderCell>Tickets</CTableHeaderCell>
            <CTableHeaderCell>Private Designs</CTableHeaderCell>
            <CTableHeaderCell>Discount</CTableHeaderCell>
            <CTableHeaderCell class="text-end">Actions</CTableHeaderCell>
          </CTableRow>
        </CTableHead>
        <CTableBody>
          <CTableRow v-for="plan in plans" :key="plan.id">
            <CTableDataCell class="fw-semibold">{{ plan.name }}</CTableDataCell>
            <CTableDataCell>{{ money(plan) }}</CTableDataCell>
            <CTableDataCell>{{ plan.duration_days || 30 }} days</CTableDataCell>
            <CTableDataCell>{{ plan.ticket_limit }}</CTableDataCell>
            <CTableDataCell>
              <CIcon :icon="plan.can_publish_to_store ? 'cil-check' : 'cil-x'" :color="plan.can_publish_to_store ? 'success' : 'danger'" />
            </CTableDataCell>
            <CTableDataCell>
              <CBadge v-if="plan.discount_percent" color="danger">{{ plan.discount_percent }}%</CBadge>
              <span v-else class="text-body-secondary">-</span>
            </CTableDataCell>
            <CTableDataCell class="text-end">
              <CButton color="warning" variant="ghost" size="sm" class="me-1" @click="openEditPlan(plan)">
                <CIcon icon="cil-pencil" class="me-1" />Edit
              </CButton>
              <CButton color="danger" variant="ghost" size="sm" @click="deletePlan(plan)">
                <CIcon icon="cil-trash" class="me-1" />Delete
              </CButton>
            </CTableDataCell>
          </CTableRow>
        </CTableBody>
      </CTable>
    </CCard>

    <!-- Industor card view -->
    <CRow v-else>
      <CCol v-for="plan in plans" :key="plan.id" md="6" lg="4" class="mb-4">
        <CCard class="h-100 shadow-sm">
          <CCardHeader class="bg-body text-center">
            <h5 class="mb-0">{{ plan.name }}</h5>
          </CCardHeader>
          <CCardBody class="text-center d-flex flex-column">
            <div class="fs-2 fw-bold text-primary mb-2">{{ money(plan) }}</div>
            <CListGroup class="text-start mb-3">
              <CListGroupItem><CIcon icon="cil-tag" class="me-2 text-success" /> {{ plan.ticket_limit }} {{ $t('plans.tickets') }}</CListGroupItem>
              <CListGroupItem><CIcon icon="cil-clock" class="me-2 text-warning" /> {{ plan.duration_days || 30 }} {{ $t('plans.days') }}</CListGroupItem>
              <CListGroupItem>
                <CIcon :icon="plan.can_publish_to_store ? 'cil-check' : 'cil-x'" :class="plan.can_publish_to_store ? 'me-2 text-success' : 'me-2 text-danger'" />
                {{ $t('plans.store_publishing') }}
              </CListGroupItem>
              <CListGroupItem v-if="plan.discount_percent">
                <CIcon icon="cil-tags" class="me-2 text-danger" />
                <span class="text-danger fw-semibold">{{ plan.discount_percent }}% discount</span>
              </CListGroupItem>
            </CListGroup>
            <CButton
              v-if="isIndustor()"
              color="primary"
              class="w-100 mt-auto"
              :disabled="subscribing === plan.id || subscription?.subscription?.plan_id === plan.id"
              @click="subscribe(plan.id)"
            >
              <CSpinner v-if="subscribing === plan.id" size="sm" class="me-1" />
              {{ subscription?.subscription?.plan_id === plan.id ? $t('plans.current_plan') : $t('plans.subscribe') }}
            </CButton>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>

    <!-- Create/Edit Plan Modal -->
    <CModal :visible="planModal" @close="planModal = false" backdrop="static">
      <CModalHeader>
        <CModalTitle>{{ editingPlan ? 'Edit Plan' : 'Add Plan' }}</CModalTitle>
      </CModalHeader>
      <CModalBody>
        <div class="mb-3">
          <CFormLabel class="fw-semibold">Name</CFormLabel>
          <CFormInput v-model="planForm.name" placeholder="Plan name" />
        </div>
        <div class="mb-3">
          <CFormLabel class="fw-semibold">Price</CFormLabel>
          <CFormInput v-model.number="planForm.price" type="number" min="0" step="0.01" />
        </div>
        <div class="mb-3">
          <CFormLabel class="fw-semibold">Currency</CFormLabel>
          <CFormInput v-model="planForm.currency" placeholder="EGP" maxlength="3" />
        </div>
        <div class="mb-3">
          <CFormLabel class="fw-semibold">Duration (days)</CFormLabel>
          <CFormInput v-model.number="planForm.duration_days" type="number" min="1" />
        </div>
        <div class="mb-3">
          <CFormLabel class="fw-semibold">Ticket Limit</CFormLabel>
          <CFormInput v-model.number="planForm.ticket_limit" type="number" min="1" />
        </div>
        <div class="mb-3">
          <CFormCheck v-model="planForm.can_publish_to_store" label="Can publish to store" />
        </div>
        <div class="mb-3">
          <CFormLabel class="fw-semibold">Discount (%)</CFormLabel>
          <CFormInput v-model.number="planForm.discount_percent" type="number" min="0" max="100" step="0.5" placeholder="0" />
          <small class="text-body-secondary">Percentage discount applied to each ticket's expected price</small>
        </div>
      </CModalBody>
      <CModalFooter>
        <CButton color="secondary" variant="outline" @click="planModal = false">Cancel</CButton>
        <CButton color="primary" :disabled="savingPlan || !planForm.name" @click="savePlan">
          <CSpinner v-if="savingPlan" size="sm" class="me-1" /> {{ editingPlan ? 'Update' : 'Create' }}
        </CButton>
      </CModalFooter>
    </CModal>
  </div>
</template>
