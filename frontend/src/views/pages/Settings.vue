<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore, detectCurrency } from '@/stores/auth'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const authStore = useAuthStore()

const autoDetect = ref(false)
const selectedCurrency = ref(authStore.userCurrency || 'EGP')
const saving = ref(false)
const success = ref('')
const error = ref('')

onMounted(() => {
  selectedCurrency.value = authStore.userCurrency || 'EGP'
})

async function toggleAutoDetect() {
  autoDetect.value = !autoDetect.value
  if (autoDetect.value) {
    saving.value = true
    error.value = ''
    success.value = ''
    try {
      const currency = await detectCurrency()
      selectedCurrency.value = currency
      await authStore.updateCurrency(currency)
      success.value = t('settings.auto_detected', { currency })
    } catch {
      error.value = t('settings.update_failed')
    } finally {
      saving.value = false
    }
  }
}

async function setCurrency(currency) {
  selectedCurrency.value = currency
  autoDetect.value = false
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

      <div class="mb-4">
        <CFormSwitch
          :label="t('settings.auto_detect_label')"
          id="autoDetectSwitch"
          :model-value="autoDetect"
          @update:model-value="toggleAutoDetect"
          :disabled="saving"
        />
        <small class="text-body-secondary d-block mt-1">{{ $t('settings.auto_detect_help') }}</small>
      </div>

      <div class="mb-3">
        <CFormLabel class="fw-semibold">{{ $t('settings.select_currency') }}</CFormLabel>
        <div class="d-flex gap-2 flex-wrap">
          <CButton
            :color="selectedCurrency === 'EGP' && !autoDetect ? 'primary' : 'outline-primary'"
            @click="setCurrency('EGP')"
            :disabled="autoDetect || saving"
          >
            EGP - {{ $t('settings.egyptian_pound') }}
          </CButton>
          <CButton
            :color="selectedCurrency === 'USD' && !autoDetect ? 'primary' : 'outline-primary'"
            @click="setCurrency('USD')"
            :disabled="autoDetect || saving"
          >
            USD - {{ $t('settings.us_dollar') }}
          </CButton>
        </div>
        <small v-if="autoDetect" class="text-info d-block mt-2">
          <CIcon icon="cil-globe-alt" class="me-1" />{{ $t('settings.auto_detect_active') }}
        </small>
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
