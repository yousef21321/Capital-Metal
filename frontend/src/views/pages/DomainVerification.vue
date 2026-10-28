<script setup>
import { ref } from 'vue'
import AppHeader from '@/components/AppHeader.vue'
import AppFooter from '@/components/AppFooter.vue'

const steps = ref([
  { number: 1, title: 'Select record type:', done: false },
  { number: 2, title: 'Sign in to your domain name provider (e.g. godaddy.com or namecheap.com)', done: false },
  { number: 3, title: 'Copy the TXT record below into the DNS configuration for capital-metal.com', done: false },
  { number: 4, title: 'Press verify below', done: false },
])
const currentStep = ref(1)
const selectedType = ref('TXT')
const recordValue = 'google-site-verification=cJWBPhGoTy8BujJhRkicdfMyXC6HzHUpaxPt2ppr4Zk'
const verifying = ref(false)
const verified = ref(false)
const error = ref('')

function copyRecord() {
  navigator.clipboard.writeText(recordValue)
}

async function verify() {
  verifying.value = true
  error.value = ''
  await new Promise((r) => setTimeout(r, 2000))
  verified.value = true
  verifying.value = false
}
</script>

<template>
  <div class="d-flex flex-column min-vh-100">
    <AppHeader />
    <div class="body flex-grow-1">
      <CContainer>
        <CRow class="justify-content-center py-5">
          <CCol :md="10" :lg="8" :xl="6">
            <CCard class="shadow-sm">
              <CCardBody class="p-4">
                <div class="text-center mb-4">
                  <CIcon icon="cil-shield-alt" size="xxl" class="text-primary mb-3" />
                  <h3 class="mb-1">Verify domain ownership via DNS record</h3>
                  <p class="text-body-secondary mb-0">
                    <strong>capital-metal.com</strong>
                  </p>
                </div>

                <CAlert v-if="verified" color="success" class="d-flex align-items-center">
                  <CIcon icon="cil-check-circle" size="xl" class="me-2 flex-shrink-0" />
                  <div>
                    <strong>Domain verified!</strong><br />
                    Your domain ownership has been confirmed successfully.
                  </div>
                </CAlert>

                <CAlert v-if="error" color="danger">{{ error }}</CAlert>

                <!-- Step 1: Select record type -->
                <div class="mb-4">
                  <div class="d-flex align-items-start mb-3">
                    <span class="badge bg-primary rounded-pill me-2 mt-1 flex-shrink-0">1</span>
                    <div class="flex-grow-1">
                      <p class="mb-2 fw-semibold">Select record type:</p>
                      <div class="d-flex gap-3">
                        <CFormCheck
                          v-for="type in ['TXT', 'CNAME']"
                          :key="type"
                          :id="'type-' + type"
                          :value="type"
                          v-model="selectedType"
                          :label="type"
                          inline
                        />
                      </div>
                      <a href="#" class="small">Learn more</a>
                    </div>
                  </div>

                  <!-- Step 2 -->
                  <div class="d-flex align-items-start mb-3">
                    <span class="badge bg-primary rounded-pill me-2 mt-1 flex-shrink-0">2</span>
                    <div class="flex-grow-1">
                      <p class="mb-0 fw-semibold">
                        Sign in to your domain name provider (e.g. godaddy.com or namecheap.com)
                      </p>
                    </div>
                  </div>

                  <!-- Step 3 -->
                  <div class="d-flex align-items-start mb-3">
                    <span class="badge bg-primary rounded-pill me-2 mt-1 flex-shrink-0">3</span>
                    <div class="flex-grow-1">
                      <p class="mb-2 fw-semibold">
                        Copy the TXT record below into the DNS configuration for capital-metal.com
                      </p>
                      <CInputGroup class="mb-2">
                        <CFormInput :value="recordValue" readonly />
                        <CButton color="secondary" variant="outline" @click="copyRecord">
                          <CIcon icon="cil-copy" />
                        </CButton>
                      </CInputGroup>
                    </div>
                  </div>

                  <!-- Step 4 -->
                  <div class="d-flex align-items-start mb-3">
                    <span class="badge bg-primary rounded-pill me-2 mt-1 flex-shrink-0">4</span>
                    <div class="flex-grow-1">
                      <p class="mb-2 fw-semibold">Press verify below</p>
                      <CButton
                        color="primary"
                        size="lg"
                        class="w-100"
                        :disabled="verifying || verified"
                        @click="verify"
                      >
                        <CSpinner v-if="verifying" size="sm" class="me-2" />
                        <CIcon v-else icon="cil-check" class="me-2" />
                        {{ verified ? 'Verified' : 'Verify' }}
                      </CButton>
                      <p class="small text-body-secondary mt-2 mb-0">
                        Note: DNS changes may take some time to apply. If Search Console doesn't find the record immediately, wait a day and then try to verify again.
                        <a href="#" class="ms-1">Learn more</a>
                      </p>
                    </div>
                  </div>
                </div>

                <hr class="my-4" />

                <div class="text-center">
                  <p class="text-body-secondary mb-0 small">
                    <CIcon icon="cil-warning" class="me-1" />
                    Can't verify via Domain name provider?
                  </p>
                  <p class="text-body-secondary small">For more verification methods, try a URL prefix property instead</p>
                </div>
              </CCardBody>
            </CCard>
          </CCol>
        </CRow>
      </CContainer>
    </div>
    <AppFooter />
  </div>
</template>
