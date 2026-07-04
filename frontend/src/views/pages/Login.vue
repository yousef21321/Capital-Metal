<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()
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
    router.push('/dashboard')
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="wrapper min-vh-100 d-flex flex-row align-items-center">
    <CContainer>
      <CRow class="justify-content-center">
        <CCol :md="8">
          <CCardGroup>
            <CCard class="p-4">
              <CCardBody>
                <CForm @submit.prevent="handleLogin">
                  <h1>Login</h1>
                  <p class="text-body-secondary">Sign In to FLFL Design</p>
                  <CAlert v-if="error" color="danger" class="py-2">{{ error }}</CAlert>
                  <CInputGroup class="mb-3">
                    <CInputGroupText><CIcon icon="cil-envelope" /></CInputGroupText>
                    <CFormInput v-model="email" type="email" placeholder="Email" autocomplete="email" required />
                  </CInputGroup>
                  <CInputGroup class="mb-4">
                    <CInputGroupText><CIcon icon="cil-lock-locked" /></CInputGroupText>
                    <CFormInput v-model="password" type="password" placeholder="Password" autocomplete="current-password" required />
                  </CInputGroup>
                  <CRow>
                    <CCol :xs="6">
                      <CButton type="submit" color="primary" class="px-4" :disabled="loading">
                        {{ loading ? 'Loading...' : 'Login' }}
                      </CButton>
                    </CCol>
                    <CCol :xs="6" class="text-end">
                      <CButton color="link" class="px-0" @click="router.push('/pages/register')">
                        Create Account
                      </CButton>
                    </CCol>
                  </CRow>
                </CForm>
              </CCardBody>
            </CCard>
            <CCard class="text-white bg-primary py-5" style="width: 44%">
              <CCardBody class="text-center d-flex flex-column justify-content-center">
                <h2>FLFL Design</h2>
                <p>Role-based platform for admin, user, tester, designer, and industor.</p>
                <CButton color="light" variant="outline" class="mt-3" @click="router.push('/pages/register')">
                  Register Now!
                </CButton>
              </CCardBody>
            </CCard>
          </CCardGroup>
        </CCol>
      </CRow>
    </CContainer>
  </div>
</template>
