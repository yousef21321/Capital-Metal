<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()
const router = useRouter()

const name = ref('')
const email = ref('')
const password = ref('')
const confirmPassword = ref('')
const currency = ref('EGP')
const error = ref('')
const loading = ref(false)

async function handleRegister() {
  error.value = ''
  if (password.value !== confirmPassword.value) {
    error.value = 'Passwords do not match.'
    return
  }
  loading.value = true
  try {
    await authStore.register(name.value, email.value, password.value, confirmPassword.value, currency.value)
    router.push('/dashboard')
  } catch (e) {
    error.value = e.response?.data?.message || e.message
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="wrapper min-vh-100 d-flex flex-row align-items-center bg-body-tertiary">
    <CContainer>
      <CRow class="justify-content-center">
        <CCol :md="10" :lg="8" :xl="6">
          <CCard class="border-0 shadow-lg overflow-hidden">
            <CRow class="g-0">
              <CCol md="5" class="bg-primary d-none d-md-flex flex-column align-items-center justify-content-center p-4 text-white">
                <div class="text-center">
                  <div class="mb-3">
                    <CIcon icon="cil-star" size="3xl" />
                  </div>
                  <h3 class="fw-bold">FLFL Design</h3>
                  <p class="text-white-50 mb-4">منصة التصميم والتصنيع</p>
                  <hr class="w-50 mx-auto border-white-50" />
                  <p class="small text-white-50 mb-0">Already have an account?</p>
                  <CButton color="light" variant="outline" size="sm" class="mt-2" @click="router.push('/pages/login')">
                    Login
                  </CButton>
                </div>
              </CCol>
              <CCol md="7">
                <CCardBody class="p-4 p-lg-5">
                  <CForm @submit.prevent="handleRegister">
                    <div class="text-center text-md-start mb-4">
                      <h3 class="fw-bold mb-1">إنشاء حساب / Register</h3>
                      <p class="text-body-secondary small mb-0">أنشئ حسابك في FLFL Design لبدء التسوق</p>
                    </div>

                    <CAlert v-if="error" color="danger" class="py-2 small">{{ error }}</CAlert>

                    <div class="mb-3">
                      <label class="form-label small fw-semibold">الاسم الكامل / Full Name</label>
                      <CInputGroup>
                        <CInputGroupText><CIcon icon="cil-user" /></CInputGroupText>
                        <CFormInput v-model="name" placeholder="اسمك الكامل" autocomplete="name" required />
                      </CInputGroup>
                    </div>

                    <div class="mb-3">
                      <label class="form-label small fw-semibold">البريد الإلكتروني / Email</label>
                      <CInputGroup>
                        <CInputGroupText>@</CInputGroupText>
                        <CFormInput v-model="email" type="email" placeholder="بريدك الإلكتروني" autocomplete="email" required />
                      </CInputGroup>
                    </div>

                    <CRow :gutter="{ xs: 16 }">
                      <CCol :sm="6" class="mb-3">
                        <label class="form-label small fw-semibold">كلمة المرور / Password</label>
                        <CInputGroup>
                          <CInputGroupText><CIcon icon="cil-lock-locked" /></CInputGroupText>
                          <CFormInput v-model="password" type="password" placeholder="كلمة المرور" autocomplete="new-password" required />
                        </CInputGroup>
                      </CCol>
                      <CCol :sm="6" class="mb-3">
                        <label class="form-label small fw-semibold">تأكيد كلمة المرور / Confirm</label>
                        <CInputGroup>
                          <CInputGroupText><CIcon icon="cil-lock-locked" /></CInputGroupText>
                          <CFormInput v-model="confirmPassword" type="password" placeholder="تأكيد كلمة المرور" autocomplete="new-password" required />
                        </CInputGroup>
                      </CCol>
                    </CRow>

                    <div class="mb-4">
                      <label class="form-label small fw-semibold">عملة العرض / Display Currency</label>
                      <div class="d-flex gap-2">
                        <CFormCheck
                          id="currency-egp"
                          :button="{ color: currency === 'EGP' ? 'primary' : 'outline-secondary' }"
                          type="radio"
                          name="currency"
                          value="EGP"
                          v-model="currency"
                          label="EGP  جنيه مصري"
                        />
                        <CFormCheck
                          id="currency-usd"
                          :button="{ color: currency === 'USD' ? 'primary' : 'outline-secondary' }"
                          type="radio"
                          name="currency"
                          value="USD"
                          v-model="currency"
                          label="USD  دولار أمريكي"
                        />
                      </div>
                    </div>

                    <div class="d-grid">
                      <CButton type="submit" color="primary" size="lg" :disabled="loading">
                        <CSpinner v-if="loading" size="sm" class="me-2" />
                        <template v-else><CIcon icon="cil-user-plus" class="me-2" /></template>
                        {{ loading ? 'جارٍ إنشاء الحساب...' : 'إنشاء الحساب / Create Account' }}
                      </CButton>
                    </div>

                    <div class="text-center mt-3 d-md-none">
                      <span class="small text-body-secondary">لديك حساب بالفعل؟ / </span>
                      <CButton color="link" size="sm" class="p-0" @click="router.push('/pages/login')">
                        تسجيل الدخول / Login
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
