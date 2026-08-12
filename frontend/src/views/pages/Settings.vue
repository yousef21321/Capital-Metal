<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const authStore = useAuthStore()

const selectedCurrency = ref(authStore.userCurrency || 'EGP')
const saving = ref(false)
const success = ref('')
const error = ref('')

onMounted(() => {
  selectedCurrency.value = authStore.userCurrency || 'EGP'
})

async function setCurrency(currency) {
  selectedCurrency.value = currency
  saving.value = true
  error.value = ''
  success.value = ''
  try {
    await authStore.updateCurrency(currency)
    success.value = t('settings.currency_updated')
  } catch (e) {
    error.value = e.response?.data?.message || t('settings.update_failed')
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <CCard class="mb-4">
    <CCardHeader class="fw-semibold">
      <CIcon icon="cil-settings" class="me-2" />{{ $t('account.settings') }}
    </CCardHeader>
    <CCardBody>
      <CAlert v-if="success" color="success" dismissible @close="success = ''">{{ success }}</CAlert>
      <CAlert v-if="error" color="danger" dismissible @close="error = ''">{{ error }}</CAlert>

      <h5 class="fw-semibold mb-3">
        <CIcon icon="cil-dollar" class="me-2" />{{ $t('settings.currency') }}
      </h5>

      <div class="mb-3">
        <CFormLabel class="fw-semibold">{{ $t('settings.select_currency') }}</CFormLabel>
        <div class="d-flex gap-2 flex-wrap">
          <CButton
            :color="selectedCurrency === 'EGP' ? 'primary' : 'outline-primary'"
            @click="setCurrency('EGP')"
            :disabled="saving"
          >
            EGP - {{ $t('settings.egyptian_pound') }}
          </CButton>
          <CButton
            :color="selectedCurrency === 'USD' ? 'primary' : 'outline-primary'"
            @click="setCurrency('USD')"
            :disabled="saving"
          >
            USD - {{ $t('settings.us_dollar') }}
          </CButton>
        </div>
      </div>

      <div class="mt-4 pt-3 border-top">
        <h5 class="fw-semibold mb-2">
          <CIcon icon="cil-info" class="me-2" />{{ $t('settings.current') }}
        </h5>
        <p class="mb-1">
          <strong>{{ $t('settings.display_currency') }}:</strong>
          <CBadge :color="authStore.userCurrency === 'EGP' ? 'primary' : 'success'" class="ms-2">
            {{ authStore.userCurrency }}
          </CBadge>
        </p>
        <p v-if="authStore.exchangeRate" class="mb-0 text-body-secondary small">
          1 USD = {{ authStore.exchangeRate }} EGP
        </p>
      </div>
    </CCardBody>
  </CCard>
</template>
