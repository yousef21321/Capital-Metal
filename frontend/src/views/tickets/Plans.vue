<script setup>
import { ref, onMounted } from 'vue'
import api from '@/api'
import { useAuthStore } from '@/stores/auth'
import { useToastStore } from '@/stores/toast'

const auth = useAuthStore()
const toast = useToastStore()
const plans = ref([])
const subscription = ref(null)
const loading = ref(true)
const subscribing = ref(null)
const error = ref('')

const isIndustor = () => auth.userRole === 'industor'

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

const money = (p) => `${parseFloat(p.price || 0).toFixed(2)} ${p.currency || 'EGP'}`

const approvalBadge = (status) => {
  const map = { pending: { color: 'warning', text: 'Pending Approval' }, approved: { color: 'success', text: 'Approved' }, rejected: { color: 'danger', text: 'Rejected' } }
  return map[status] || { color: 'secondary', text: status }
}

onMounted(load)
</script>

<template>
  <div>
    <h3 class="mb-1">Subscription Plans</h3>
    <p class="text-body-secondary mb-4">Choose a plan to get tickets for design requests. Admin approval required.</p>

    <CAlert v-if="error" color="danger" class="mb-3">{{ error }}</CAlert>

    <CCard v-if="subscription?.subscription" class="mb-4 shadow-sm" :class="subscription.approval_status === 'approved' ? 'border-success' : 'border-warning'">
      <CCardBody class="d-flex flex-wrap justify-content-between align-items-center">
        <div>
          <span class="text-body-secondary small">Current Plan</span>
          <h5 class="mb-0">{{ subscription.subscription.plan?.name }}</h5>
        </div>
        <div class="d-flex align-items-center gap-3 flex-wrap">
          <CBadge :color="approvalBadge(subscription.approval_status).color">{{ approvalBadge(subscription.approval_status).text }}</CBadge>
          <template v-if="subscription.approval_status === 'approved'">
            <div class="text-center">
              <div class="fs-4 fw-bold text-primary">{{ subscription.tickets_remaining }}</div>
              <small class="text-body-secondary">Tickets Left</small>
            </div>
            <div class="text-center">
              <div class="fs-4 fw-bold">{{ subscription.can_publish_to_store ? 'Yes' : 'No' }}</div>
              <small class="text-body-secondary">Store Publishing</small>
            </div>
          </template>
        </div>
      </CCardBody>
    </CCard>

    <div v-if="loading" class="text-center py-5"><CSpinner /></div>

    <CRow v-else>
      <CCol v-for="plan in plans" :key="plan.id" md="6" lg="4" class="mb-4">
        <CCard class="h-100 shadow-sm">
          <CCardHeader class="bg-body text-center">
            <h5 class="mb-0">{{ plan.name }}</h5>
          </CCardHeader>
          <CCardBody class="text-center d-flex flex-column">
            <div class="fs-2 fw-bold text-primary mb-2">{{ money(plan) }}</div>
            <CListGroup class="text-start mb-3">
              <CListGroupItem><CIcon icon="cil-tag" class="me-2 text-success" /> {{ plan.ticket_limit }} tickets</CListGroupItem>
              <CListGroupItem><CIcon icon="cil-clock" class="me-2 text-warning" /> {{ plan.duration_days || 30 }} days</CListGroupItem>
              <CListGroupItem>
                <CIcon :icon="plan.can_publish_to_store ? 'cil-check' : 'cil-x'" :class="plan.can_publish_to_store ? 'me-2 text-success' : 'me-2 text-danger'" />
                Store publishing
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
              {{ subscription?.subscription?.plan_id === plan.id ? 'Current Plan' : 'Subscribe' }}
            </CButton>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>
  </div>
</template>
