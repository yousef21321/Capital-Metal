<script setup>
import { ref } from 'vue'
import api from '@/api'
import AppHeader from '@/components/AppHeader.vue'
import AppFooter from '@/components/AppFooter.vue'

const form = ref({
  name: '',
  email: '',
  phone: '',
  subject: '',
  message: '',
})
const submitting = ref(false)
const success = ref('')
const error = ref('')

async function submitContact() {
  error.value = ''
  success.value = ''
  submitting.value = true
  try {
    const { data } = await api.post('/api/contact', form.value)
    success.value = 'تم إرسال رسالتك بنجاح. سنتواصل معك قريباً! / Your message has been sent. We will get back to you soon!'
    form.value = { name: '', email: '', phone: '', subject: '', message: '' }
  } catch (e) {
    error.value = e.response?.data?.message || 'حدث خطأ. حاول مرة أخرى. / An error occurred. Please try again.'
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="d-flex flex-column min-vh-100">
    <AppHeader />
    <div class="body flex-grow-1">
      <CContainer>
        <CRow class="justify-content-center py-5">
          <CCol :md="10" :lg="8">
            <h1 class="mb-1 text-center">اتصل بنا</h1>
            <h2 class="text-body-secondary mb-4 fs-5 text-center">Contact Us</h2>

            <CRow :gutter="{ md: 24 }">
              <!-- Contact Info -->
              <CCol :md="5">
                <CCard class="shadow-sm mb-4">
                  <CCardBody>
                    <h2 class="fs-5 mb-3">معلومات الاتصال</h2>

                    <div class="mb-3">
                      <h3 class="fs-6 fw-semibold mb-1">
                        <CIcon icon="cil-envelope" class="me-1" /> البريد الإلكتروني / Email
                      </h3>
                      <p class="mb-0 text-body-secondary">flfldesign.official@gmail.com</p>
                    </div>

                    <div class="mb-3">
                      <h3 class="fs-6 fw-semibold mb-1">
                        <CIcon icon="cil-phone" class="me-1" /> الهاتف / Phone
                      </h3>
                      <p class="mb-0 text-body-secondary" dir="ltr">01109055371</p>
                    </div>

                    <div class="mb-3">
                      <h3 class="fs-6 fw-semibold mb-1">
                        <CIcon icon="cil-location-pin" class="me-1" /> العنوان / Address
                      </h3>
                      <p class="mb-0 text-body-secondary" dir="rtl">
                        ٦ شارع العبسي، منشاة البكري، القاهرة الجديدة
                      </p>
                      <p class="text-body-secondary small" dir="ltr">
                        6 Elabnasy St., Manshyat ElBakry, New Cairo
                      </p>
                    </div>

                    <div>
                      <h3 class="fs-6 fw-semibold mb-1">
                        <CIcon icon="cil-clock" class="me-1" /> ساعات العمل / Working Hours
                      </h3>
                      <p class="mb-0 text-body-secondary" dir="rtl">السبت - الخميس: ١٠ ص - ٩ م</p>
                      <p class="text-body-secondary" dir="ltr">Saturday - Thursday: 10 AM - 9 PM</p>
                    </div>
                  </CCardBody>
                </CCard>
              </CCol>

              <!-- Contact Form -->
              <CCol :md="7">
                <CCard class="shadow-sm mb-4">
                  <CCardBody>
                    <h2 class="fs-5 mb-3">أرسل لنا رسالة / Send us a Message</h2>

                    <CAlert v-if="success" color="success">{{ success }}</CAlert>
                    <CAlert v-if="error" color="danger">{{ error }}</CAlert>

                    <CForm @submit.prevent="submitContact">
                      <CRow :gutter="{ xs: 16 }">
                        <CCol :sm="6" class="mb-3">
                          <CFormLabel>الاسم / Name <span class="text-danger">*</span></CFormLabel>
                          <CFormInput v-model="form.name" required placeholder="اسمك الكامل" />
                        </CCol>
                        <CCol :sm="6" class="mb-3">
                          <CFormLabel>البريد الإلكتروني / Email <span class="text-danger">*</span></CFormLabel>
                          <CFormInput v-model="form.email" type="email" required placeholder="بريدك الإلكتروني" />
                        </CCol>
                        <CCol :sm="6" class="mb-3">
                          <CFormLabel>رقم الهاتف / Phone</CFormLabel>
                          <CFormInput v-model="form.phone" placeholder="رقم هاتفك" />
                        </CCol>
                        <CCol :sm="6" class="mb-3">
                          <CFormLabel>الموضوع / Subject <span class="text-danger">*</span></CFormLabel>
                          <CFormInput v-model="form.subject" required placeholder="عنوان الرسالة" />
                        </CCol>
                        <CCol :sm="12" class="mb-3">
                          <CFormLabel>الرسالة / Message <span class="text-danger">*</span></CFormLabel>
                          <CFormTextarea v-model="form.message" rows="5" required placeholder="اكتب رسالتك هنا..." />
                        </CCol>
                      </CRow>
                      <CButton type="submit" color="primary" :disabled="submitting" class="w-100">
                        <CSpinner v-if="submitting" size="sm" class="me-2" />
                        إرسال / Send
                      </CButton>
                    </CForm>
                  </CCardBody>
                </CCard>
              </CCol>
            </CRow>
          </CCol>
        </CRow>
      </CContainer>
    </div>
    <AppFooter />
  </div>
</template>
