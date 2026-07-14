<script setup>
import { ref } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const authStore = useAuthStore()
const success = ref('')

async function updateCurrency(currency) {
  try {
    await authStore.updateCurrency(currency)
    success.value = t('profile.currency_updated')
  } catch (e) {
    success.value = ''
  }
}
</script>

<template>
  <CCard class="mb-4">
    <CCardHeader class="fw-semibold">
      <CIcon icon="cil-user" class="me-2" />{{ $t('account.profile') }}
    </CCardHeader>
    <CCardBody>
      <CAlert v-if="success" color="success" dismissible @close="success = ''">{{ success }}</CAlert>

      <div class="mb-3">
        <CFormLabel class="fw-semibold">{{ $t('profile.name') }}</CFormLabel>
        <p class="form-control-plaintext">{{ authStore.userName || '—' }}</p>
      </div>
      <div class="mb-3">
        <CFormLabel class="fw-semibold">{{ $t('profile.email') }}</CFormLabel>
        <p class="form-control-plaintext">{{ authStore.userEmail || '—' }}</p>
      </div>
      <div class="mb-3">
        <CFormLabel class="fw-semibold">{{ $t('profile.role') }}</CFormLabel>
        <p class="form-control-plaintext">
          <CBadge color="primary" class="text-uppercase">{{ authStore.userRole || '—' }}</CBadge>
        </p>
      </div>
      <div class="mb-3">
        <CFormLabel class="fw-semibold">{{ $t('register.currency') }}</CFormLabel>
        <div class="d-flex gap-2">
          <CButton
            :color="authStore.userCurrency === 'EGP' ? 'primary' : 'outline-primary'"
            @click="updateCurrency('EGP')"
          >
            EGP {{ $t('profile.egyptian_pound') }}
          </CButton>
          <CButton
            :color="authStore.userCurrency === 'USD' ? 'primary' : 'outline-primary'"
            @click="updateCurrency('USD')"
          >
            USD {{ $t('profile.us_dollar') }}
          </CButton>
        </div>
      </div>
    </CCardBody>
  </CCard>
</template>
