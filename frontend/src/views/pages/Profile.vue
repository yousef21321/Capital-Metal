<script setup>
import { ref, computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const authStore = useAuthStore()

const name = ref(authStore.userName)
const avatarPreview = ref(null)
const avatarFile = ref(null)
const saving = ref(false)
const success = ref('')
const error = ref('')
const fileInput = ref(null)

const userInitial = computed(() => authStore.userName?.charAt(0)?.toUpperCase() || 'U')

function onAvatarPick(e) {
  const file = e.target.files?.[0]
  if (!file) return
  avatarFile.value = file
  avatarPreview.value = URL.createObjectURL(file)
}

function triggerFileInput() {
  fileInput.value?.click()
}

function removeAvatar() {
  avatarFile.value = null
  avatarPreview.value = null
  if (fileInput.value) fileInput.value.value = ''
}

const currentAvatar = computed(() => {
  if (avatarPreview.value) return avatarPreview.value
  if (authStore.user?.avatar) {
    return authStore.user.avatar.startsWith('http')
      ? authStore.user.avatar
      : `/storage/${authStore.user.avatar}`
  }
  return null
})

async function saveProfile() {
  saving.value = true
  error.value = ''
  success.value = ''
  try {
    const fd = new FormData()
    fd.append('name', name.value)
    if (avatarFile.value) fd.append('avatar', avatarFile.value)
    await authStore.updateProfile(fd)
    success.value = t('profile.saved')
  } catch (e) {
    error.value = e.response?.data?.message || e.message || 'Failed to save.'
  } finally {
    saving.value = false
  }
}

async function updateCurrency(currency) {
  try {
    await authStore.updateCurrency(currency)
    success.value = t('profile.currency_updated')
  } catch (e) {
    error.value = ''
  }
}
</script>

<template>
  <div class="profile-page">
    <div class="profile-card">
      <div class="profile-header">
        <div class="profile-avatar-section">
          <div class="avatar-wrapper" @click="triggerFileInput">
            <img v-if="currentAvatar" :src="currentAvatar" class="avatar-img" alt="avatar" />
            <div v-else class="avatar-initials">{{ userInitial }}</div>
            <div class="avatar-overlay">
              <CIcon icon="cil-camera" size="xl" />
            </div>
          </div>
          <input ref="fileInput" type="file" accept="image/*" class="d-none" @change="onAvatarPick" />
          <button v-if="avatarPreview" class="btn-remove-avatar" @click.stop="removeAvatar">
            <CIcon icon="cil-x" />
          </button>
        </div>
        <div class="profile-header-info">
          <h2 class="profile-name">{{ authStore.userName || '—' }}</h2>
          <p class="profile-email">{{ authStore.userEmail || '—' }}</p>
          <CBadge color="primary" class="text-uppercase role-badge">{{ authStore.userRole || '—' }}</CBadge>
        </div>
      </div>

      <div class="profile-body">
        <CAlert v-if="success" color="success" class="profile-alert" dismissible @close="success = ''">{{ success }}</CAlert>
        <CAlert v-if="error" color="danger" class="profile-alert" dismissible @close="error = ''">{{ error }}</CAlert>

        <div class="form-section">
          <h5 class="section-title"><CIcon icon="cil-user" class="me-2" />{{ $t('account.profile') }}</h5>

          <div class="mb-4">
            <label class="form-label fw-semibold">{{ $t('profile.name') }}</label>
            <CFormInput v-model="name" class="profile-input" />
          </div>

          <div class="mb-4">
            <label class="form-label fw-semibold">{{ $t('profile.email') }}</label>
            <p class="profile-value">{{ authStore.userEmail || '—' }}</p>
          </div>


          <div class="mb-4">
            <label class="form-label fw-semibold">{{ $t('profile.role') }}</label>
            <p class="profile-value">
              <CBadge color="primary" class="text-uppercase">{{ authStore.userRole || '—' }}</CBadge>
            </p>
          </div>
        </div>

        <div class="form-section">
          <h5 class="section-title"><CIcon icon="cil-money" class="me-2" />{{ $t('register.currency') }}</h5>
          <div class="currency-options">
            <button
              class="currency-btn"
              :class="{ active: authStore.userCurrency === 'EGP' }"
              @click="updateCurrency('EGP')"
            >
              <span class="currency-flag">🇪🇬</span>
              <span>EGP</span>
              <span class="currency-label">{{ $t('profile.egyptian_pound') }}</span>
            </button>
            <button
              class="currency-btn"
              :class="{ active: authStore.userCurrency === 'USD' }"
              @click="updateCurrency('USD')"
            >
              <span class="currency-flag">🇺🇸</span>
              <span>USD</span>
              <span class="currency-label">{{ $t('profile.us_dollar') }}</span>
            </button>
          </div>
        </div>

        <div class="profile-actions">
          <CButton color="primary" class="save-btn" :disabled="saving" @click="saveProfile">
            <CSpinner v-if="saving" size="sm" class="me-2" />
            <CIcon v-else icon="cil-check" class="me-2" />
            {{ saving ? 'Saving...' : $t('profile.save') }}
          </CButton>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.profile-page {
  max-width: 720px;
  margin: 0 auto;
  padding: 1.5rem;
}

.profile-card {
  background: var(--cui-body-bg, #fff);
  border-radius: 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.profile-header {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  padding: 2rem 2.5rem;
  background: linear-gradient(135deg, #EF4444 0%, #B5121B 100%);
  color: #fff;
}

.profile-avatar-section {
  position: relative;
  flex-shrink: 0;
}

.avatar-wrapper {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  overflow: hidden;
  border: 3px solid rgba(255, 255, 255, 0.3);
  cursor: pointer;
  position: relative;
  transition: transform 0.3s ease, border-color 0.3s ease;
}
.avatar-wrapper:hover {
  transform: scale(1.05);
  border-color: rgba(255, 255, 255, 0.6);
}

.avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-initials {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2.2rem;
  font-weight: 700;
  background: rgba(255, 255, 255, 0.15);
  color: #fff;
}

.avatar-overlay {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 0, 0, 0.4);
  opacity: 0;
  transition: opacity 0.3s ease;
}
.avatar-wrapper:hover .avatar-overlay {
  opacity: 1;
}

.btn-remove-avatar {
  position: absolute;
  top: -4px;
  right: -4px;
  width: 26px;
  height: 26px;
  border-radius: 50%;
  background: #dc3545;
  color: #fff;
  border: 2px solid #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.7rem;
  cursor: pointer;
  transition: transform 0.2s ease;
}
.btn-remove-avatar:hover {
  transform: scale(1.15);
}

.profile-header-info {
  flex: 1;
}

.profile-name {
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 0.25rem;
}

.profile-email {
  opacity: 0.8;
  margin-bottom: 0.5rem;
}

.role-badge {
  font-size: 0.7rem;
  padding: 0.3em 0.8em;
  border-radius: 20px;
}

.profile-body {
  padding: 2rem 2.5rem;
}

.form-section {
  margin-bottom: 1.5rem;
  padding-bottom: 1.5rem;
  border-bottom: 1px solid var(--cui-border-color, #e5e7eb);
}
.form-section:last-of-type {
  border-bottom: none;
}

.section-title {
  font-size: 0.95rem;
  font-weight: 700;
  margin-bottom: 1rem;
  color: var(--cui-body-color, #1a1e2a);
}

.profile-input {
  border-radius: 10px;
  padding: 0.6rem 1rem;
  border: 1px solid var(--cui-border-color, #e5e7eb);
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
}
.profile-input:focus {
  border-color: #EF4444;
  box-shadow: 0 0 0 3px rgba(56, 189, 248, 0.12);
}

.profile-value {
  margin: 0;
  padding: 0.6rem 0;
  color: var(--cui-body-color, #1a1e2a);
}

.currency-options {
  display: flex;
  gap: 0.75rem;
}

.currency-btn {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 0.6rem;
  padding: 0.8rem 1rem;
  border: 2px solid var(--cui-border-color, #e5e7eb);
  border-radius: 12px;
  background: var(--cui-body-bg, #fff);
  cursor: pointer;
  transition: all 0.25s ease;
}
.currency-btn:hover {
  border-color: #EF4444;
  transform: translateY(-1px);
}
.currency-btn.active {
  border-color: #EF4444;
  background: rgba(56, 189, 248, 0.06);
}

.currency-flag {
  font-size: 1.3rem;
}

.currency-label {
  font-size: 0.75rem;
  color: var(--cui-secondary-color, #6b7280);
  margin-left: auto;
}

.profile-actions {
  padding-top: 0.5rem;
}

.save-btn {
  border-radius: 12px;
  font-weight: 600;
  padding: 0.6rem 2rem;
  transition: all 0.3s ease;
  box-shadow: 0 4px 16px rgba(181, 18, 27, 0.2);
}
.save-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 24px rgba(181, 18, 27, 0.3);
}

.profile-alert {
  border-radius: 10px;
  margin-bottom: 1.2rem;
}

@media (max-width: 576px) {
  .profile-page { padding: 1rem; }
  .profile-header { flex-direction: column; text-align: center; padding: 1.5rem; }
  .profile-body { padding: 1.5rem; }
  .currency-options { flex-direction: column; }
}
</style>
