<script setup>
import { ref, onMounted } from 'vue'
import api from '@/api'
import { useToastStore } from '@/stores/toast'

const toast = useToastStore()
const cards = ref([])
const loading = ref(true)
const saving = ref(false)
const showForm = ref(false)

const emptyForm = () => ({
  holder_name: '',
  card_number: '',
  expiry_month: '',
  expiry_year: '',
  cvv: '',
  is_default: false,
})
const form = ref(emptyForm())

async function load() {
  loading.value = true
  try {
    const { data } = await api.get('/api/saved-cards')
    cards.value = data
  } catch (e) {
    toast.error('Failed to load saved cards.')
  } finally {
    loading.value = false
  }
}

function toggleForm() {
  showForm.value = !showForm.value
  if (!showForm.value) form.value = emptyForm()
}

async function saveCard() {
  saving.value = true
  try {
    const { data } = await api.post('/api/saved-cards', form.value)
    cards.value.unshift(data)
    if (data.is_default) {
      cards.value.forEach((c) => { if (c.id !== data.id) c.is_default = false })
    }
    form.value = emptyForm()
    showForm.value = false
    toast.success('Card saved successfully.')
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to save card.')
  } finally {
    saving.value = false
  }
}

async function setDefault(card) {
  try {
    const { data } = await api.put(`/api/saved-cards/${card.id}/default`)
    cards.value.forEach((c) => { c.is_default = c.id === data.id })
    toast.success('Default card updated.')
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to set default card.')
  }
}

async function removeCard(card) {
  if (!confirm(`Remove card ${card.masked_pan || ''}?`)) return
  try {
    await api.delete(`/api/saved-cards/${card.id}`)
    cards.value = cards.value.filter((c) => c.id !== card.id)
    toast.success('Card removed.')
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to remove card.')
  }
}

onMounted(load)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">{{ $t('saved_cards.title') }}</h3>
        <p class="text-body-secondary mb-0">{{ $t('saved_cards.desc') }}</p>
      </div>
      <CButton color="primary" size="sm" @click="toggleForm">
        <CIcon icon="cil-plus" class="me-1" /> {{ showForm ? $t('saved_cards.cancel') : $t('saved_cards.add_card') }}
      </CButton>
    </div>

    <CCollapse :visible="showForm">
      <CCard class="mb-4 shadow-sm">
        <CCardHeader class="bg-body"><h4 class="mb-0 fs-5">{{ $t('saved_cards.add_new') }}</h4></CCardHeader>
        <CCardBody>
          <CRow>
            <CCol :sm="12" class="mb-2">
              <CFormLabel class="small">{{ $t('saved_cards.cardholder') }}</CFormLabel>
              <CFormInput v-model="form.holder_name" :placeholder="$t('saved_cards.cardholder_placeholder')" />
            </CCol>
            <CCol :sm="12" class="mb-2">
              <CFormLabel class="small">{{ $t('saved_cards.card_number') }}</CFormLabel>
              <CFormInput v-model="form.card_number" :placeholder="$t('saved_cards.card_number_placeholder')" maxlength="23" />
            </CCol>
            <CCol :sm="4" class="mb-2">
              <CFormLabel class="small">{{ $t('saved_cards.expiry_month') }}</CFormLabel>
              <CFormInput v-model="form.expiry_month" :placeholder="$t('saved_cards.expiry_month_placeholder')" maxlength="2" />
            </CCol>
            <CCol :sm="4" class="mb-2">
              <CFormLabel class="small">{{ $t('saved_cards.expiry_year') }}</CFormLabel>
              <CFormInput v-model="form.expiry_year" :placeholder="$t('saved_cards.expiry_year_placeholder')" maxlength="2" />
            </CCol>
            <CCol :sm="4" class="mb-2">
              <CFormLabel class="small">{{ $t('saved_cards.cvv') }}</CFormLabel>
              <CFormInput v-model="form.cvv" :placeholder="$t('saved_cards.cvv_placeholder')" maxlength="3" />
            </CCol>
            <CCol :sm="12" class="mb-3">
              <CFormCheck v-model="form.is_default" :label="$t('saved_cards.set_default')" />
            </CCol>
          </CRow>
          <div class="d-flex gap-2">
            <CButton color="primary" :disabled="saving || !form.holder_name || !form.card_number || !form.expiry_month || !form.expiry_year || !form.cvv" @click="saveCard">
              <CSpinner v-if="saving" size="sm" class="me-1" /> {{ $t('saved_cards.save') }}
            </CButton>
            <CButton color="secondary" variant="outline" @click="toggleForm">{{ $t('saved_cards.cancel') }}</CButton>
          </div>
        </CCardBody>
      </CCard>
    </CCollapse>

    <div v-if="loading" class="text-center py-5"><CSpinner /></div>

    <div v-else-if="!cards.length" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-credit-card" size="3xl" class="mb-3" />
      <h4>{{ $t('saved_cards.empty') }}</h4>
      <p class="mb-3">{{ $t('saved_cards.empty_desc') }}</p>
    </div>

    <CRow v-else>
      <CCol v-for="card in cards" :key="card.id" md="6" lg="4" class="mb-3">
        <CCard class="shadow-sm h-100" :class="card.is_default ? 'border-primary' : ''">
          <CCardBody>
            <div class="d-flex justify-content-between align-items-start">
              <CIcon icon="cil-credit-card" size="xl" class="text-primary" />
              <CBadge v-if="card.is_default" color="primary">{{ $t('saved_cards.default_badge') }}</CBadge>
            </div>
            <h4 class="mt-3 mb-1 fs-5">{{ card.masked_pan || '•••• •••• ••••' }}</h4>
            <div class="d-flex justify-content-between small text-body-secondary">
              <span>{{ card.holder_name }}</span>
              <span>{{ card.expiry_month }}/{{ card.expiry_year }}</span>
            </div>
          </CCardBody>
          <CCardFooter class="bg-body d-flex gap-2">
            <CButton v-if="!card.is_default" color="secondary" variant="outline" size="sm" @click="setDefault(card)">
              {{ $t('saved_cards.set_default_btn') }}
            </CButton>
            <CButton color="danger" variant="ghost" size="sm" class="ms-auto" @click="removeCard(card)">
              <CIcon icon="cil-trash" /> {{ $t('saved_cards.remove') }}
            </CButton>
          </CCardFooter>
        </CCard>
      </CCol>
    </CRow>
  </div>
</template>
