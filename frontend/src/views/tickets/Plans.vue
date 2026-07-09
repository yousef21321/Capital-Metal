<script setup>
import { ref, onMounted } from 'vue'
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
    <h3 class="mb-1">{{ $t('plans.title') }}</h3>
    <p class="text-body-secondary mb-4">{{ $t('plans.desc') }}</p>

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
  </div>
</template>
