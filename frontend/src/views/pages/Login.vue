<script setup>
import { computed, ref } from 'vue'
import { useRouter, RouterLink } from 'vue-router'
import { useColorModes } from '@coreui/vue'
import { useAuthStore } from '@/stores/auth'
import logoLight from '@/assets/images/logo.png'
import logoDark from '@/assets/images/logodark.png'

const authStore = useAuthStore()
const { colorMode } = useColorModes('coreui-free-vue-admin-template-theme')
const logoSrc = computed(() => colorMode.value === 'dark' ? logoDark : logoLight)
const router = useRouter()

const email = ref('')
const password = ref('')
const error = ref('')
const loading = ref(false)

async function handleLogin() {
  error.value = ''
  loading.value = true
  try {
    await authStore.login(email.value, password.value)
    router.push('/products')
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="auth-page login-page">
    <div class="auth-bg-shapes">
      <div class="shape shape-1"></div>
      <div class="shape shape-2"></div>
      <div class="shape shape-3"></div>
    </div>

    <CContainer>
      <CRow class="justify-content-center align-items-center min-vh-100">
        <CCol :md="10" :lg="8" :xl="7">
          <CCard class="auth-card border-0 overflow-hidden">
            <CRow class="g-0">
              <CCol md="5" class="auth-brand-panel d-none d-md-flex flex-column align-items-center justify-content-center">
                <div class="auth-brand-content">
                  <RouterLink to="/">
                    <img :src="logoSrc" alt="FLFL Design" class="auth-logo mb-3" />
                  </RouterLink>
                  <h3 class="auth-brand-title">FLFL Design</h3>
                  <p class="auth-brand-desc">{{ $t('register.platform_desc') }}</p>
                  <div class="auth-brand-divider"></div>
                  <p class="auth-brand-question">{{ $t('login.no_account') }}</p>
                  <CButton color="light" variant="outline" class="auth-brand-btn" @click="router.push('/pages/register')">
                    {{ $t('login.register') }}
                  </CButton>
                </div>
              </CCol>
              <CCol md="7">
                <CCardBody class="auth-form-body p-4 p-lg-5">
                  <div class="text-center d-md-none mb-4">
                    <RouterLink to="/">
                      <img :src="logoSrc" alt="FLFL Design" class="auth-logo-sm mb-2" />
                    </RouterLink>
                  </div>
                  <div class="auth-form-header">
                    <h3 class="fw-bold mb-1 auth-form-title">{{ $t('login.title') }}</h3>
                    <p class="mb-0" style="color: rgba(255,255,255,0.5);">{{ $t('login.subtitle') }}</p>
                  </div>

                  <CAlert v-if="error" color="danger" class="py-2 auth-alert">{{ error }}</CAlert>

                  <CForm @submit.prevent="handleLogin" class="auth-form">
                    <div class="mb-4">
                      <label class="form-label small fw-semibold" style="color: rgba(255,255,255,0.7);">{{ $t('login.email') }}</label>
                      <CInputGroup class="auth-input-group">
                        <CInputGroupText><CIcon icon="cil-envelope" /></CInputGroupText>
                        <CFormInput v-model="email" type="email" :placeholder="$t('login.email_placeholder')" autocomplete="email" required />
                      </CInputGroup>
                    </div>
                    <div class="mb-4">
                      <label class="form-label small fw-semibold" style="color: rgba(255,255,255,0.7);">{{ $t('login.password') }}</label>
                      <CInputGroup class="auth-input-group">
                        <CInputGroupText><CIcon icon="cil-lock-locked" /></CInputGroupText>
                        <CFormInput v-model="password" type="password" :placeholder="$t('login.password_placeholder')" autocomplete="current-password" required />
                      </CInputGroup>
                    </div>
                    <div class="d-grid mb-3">
                      <CButton type="submit" color="primary" size="lg" class="auth-submit-btn" :disabled="loading">
                        <CSpinner v-if="loading" size="sm" class="me-2" />
                        <template v-else><CIcon icon="cil-account-login" class="me-2" /></template>
                        {{ loading ? 'Signing in...' : $t('login.sign_in') }}
                      </CButton>
                    </div>
                    <div class="text-center">
                      <CButton color="link" class="auth-link p-0" @click="router.push('/pages/register')">
                        {{ $t('login.register') }}
                      </CButton>
                    </div>
                  </CForm>
                </CCardBody>
              </CCol>
            </CRow>
          </CCard>
        </CCol>
      </CRow>
    </CContainer>
  </div>
</template>

<style scoped>
.auth-page {
  position: relative;
  min-height: 100vh;
  display: flex;
  align-items: center;
  overflow: hidden;
  background: var(--cui-tertiary-bg);
}

.auth-bg-shapes {
  position: absolute;
  inset: 0;
  overflow: hidden;
  pointer-events: none;
  z-index: 0;
}
.auth-bg-shapes .shape {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  opacity: 0.1;
  animation: float-shape 8s ease-in-out infinite;
}
.auth-bg-shapes .shape-1 {
  width: 400px; height: 400px;
  background: var(--cui-primary, #b81300);
  top: -120px; right: -80px;
  animation-delay: 0s;
}
.auth-bg-shapes .shape-2 {
  width: 320px; height: 320px;
  background: var(--cui-info, #39f);
  bottom: -100px; left: -60px;
  animation-delay: -3s;
}
.auth-bg-shapes .shape-3 {
  width: 240px; height: 240px;
  background: var(--cui-success, #2eb85c);
  top: 50%; left: 50%;
  animation-delay: -6s;
}

@keyframes float-shape {
  0%, 100% { transform: translate(0, 0) scale(1); }
  33% { transform: translate(30px, -30px) scale(1.05); }
  66% { transform: translate(-20px, 20px) scale(0.95); }
}

.auth-card {
  border-radius: 20px;
  background: #1a1e2a;
  box-shadow: 0 24px 80px rgba(0, 0, 0, 0.25);
  animation: fade-up 0.6s ease-out;
  position: relative;
  z-index: 1;
}

.auth-brand-panel {
  background: linear-gradient(135deg, #fff8f0, #fff0e0);
  padding: 2rem;
  position: relative;
  overflow: hidden;
}
.auth-brand-panel::before {
  content: '';
  position: absolute;
  inset: 0;
  background: radial-gradient(ellipse at 30% 20%, rgba(184, 19, 0, 0.04) 0%, transparent 60%);
}
.auth-brand-panel::after {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(184, 19, 0, 0.1), transparent);
}

.auth-brand-content {
  text-align: center;
  color: #b81300;
  position: relative;
  z-index: 1;
  animation: fade-up 0.6s ease-out 0.15s both;
}

.auth-logo {
  height: 48px;
  width: auto;
  filter: drop-shadow(0 2px 8px rgba(184, 19, 0, 0.15));
}

.auth-brand-title {
  font-weight: 800;
  font-size: 1.5rem;
  margin-bottom: 0.4rem;
  color: #b81300;
}

.auth-brand-desc {
  font-size: 0.82rem;
  opacity: 0.7;
  line-height: 1.5;
  margin-bottom: 1rem;
  color: #6b5a4a;
}

.auth-brand-divider {
  width: 60px;
  height: 2px;
  background: rgba(184, 19, 0, 0.2);
  border-radius: 2px;
  margin: 0 auto 1rem;
}

.auth-brand-question {
  font-size: 0.82rem;
  opacity: 0.7;
  margin-bottom: 0.6rem;
  color: #6b5a4a;
}

.auth-brand-btn {
  border-radius: 50px;
  font-weight: 600;
  font-size: 0.85rem;
  padding: 0.4rem 1.6rem;
  border: 2px solid #b81300;
  color: #b81300;
  transition: all 0.25s cubic-bezier(0.34, 1.56, 0.64, 1);
  background: transparent;
}
.auth-brand-btn:hover {
  background: #b81300;
  color: #fff;
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(184, 19, 0, 0.25);
}

.auth-form-body {
  animation: fade-up 0.6s ease-out 0.25s both;
  background: #1a1e2a;
  color: rgba(255,255,255,0.85);
}

.auth-logo-sm {
  height: 36px;
  width: auto;
}

.auth-form-title {
  background: linear-gradient(135deg, #ff8c42, #ff6b35);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  color: #ff8c42;
}

.auth-alert {
  animation: slide-down 0.3s ease-out;
}

.auth-form {
  margin-top: 1.2rem;
}

.auth-input-group {
  border-radius: 10px;
  overflow: hidden;
  border: 1px solid rgba(255,255,255,0.08);
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
  background: rgba(255,255,255,0.04);
}
.auth-input-group:focus-within {
  border-color: #ff8c42;
  box-shadow: 0 0 0 3px rgba(255, 140, 66, 0.12);
}
.auth-input-group .input-group-text {
  background: transparent;
  border: none;
  color: rgba(255,255,255,0.4);
}
.auth-input-group .form-control {
  border: none;
  background: transparent;
  color: rgba(255,255,255,0.85);
}
.auth-input-group .form-control::placeholder {
  color: rgba(255,255,255,0.3);
}
.auth-input-group .form-control:focus {
  box-shadow: none;
}

.auth-submit-btn {
  border-radius: 12px;
  font-weight: 600;
  padding: 0.65rem 1rem;
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  box-shadow: 0 4px 20px rgba(184, 19, 0, 0.25);
  border: none;
}
.auth-submit-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 30px rgba(184, 19, 0, 0.4);
}
.auth-submit-btn:active {
  transform: translateY(0);
}

.auth-link {
  text-decoration: none;
  font-weight: 500;
  color: #ff8c42;
  transition: all 0.2s ease;
}
.auth-link:hover {
  color: #ff6b35;
  text-decoration: underline;
}

@keyframes fade-up {
  from { opacity: 0; transform: translateY(24px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes slide-down {
  from { opacity: 0; transform: translateY(-12px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>