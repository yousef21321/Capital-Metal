<script setup>
import { ref, onMounted } from 'vue'
import api from '@/api'
import { thumbImageUrl } from '@/utils/image'

const products = ref([])
const tickets = ref([])
const loading = ref(false)
const actionLoading = ref(null)
const downloading = ref(null)
const expandedImages = ref(null)
const convertingTicket = ref(null)
const convertForm = ref({
  name: '',
  slug: '',
  description: '',
  price_egp: 0,
  price_usd: 0,
})

async function fetchProducts() {
  loading.value = true
  try {
    const { data } = await api.get('/api/tester/products/pending')
    products.value = data.products
    tickets.value = data.tickets
  } finally {
    loading.value = false
  }
}

async function approve(id) {
  actionLoading.value = id
  try {
    await api.post(`/api/tester/products/${id}/approve`)
    products.value = products.value.filter(p => p.id !== id)
  } finally {
    actionLoading.value = null
  }
}

async function returnWithFeedback(id) {
  const p = products.value.find(x => x.id === id)
  if (!p) return
  const priceEGP = prompt('Suggested price (EGP):', p.tester_suggested_price_egp || '')
  if (priceEGP === null) return
  const priceUSD = prompt('Suggested price (USD):', p.tester_suggested_price_usd || '')
  if (priceUSD === null) return
  const comment = prompt('Feedback / comment:', p.tester_comment || '')
  if (comment === null) return
  actionLoading.value = id
  try {
    await api.post(`/api/tester/products/${id}/return`, {
      suggested_price_egp: priceEGP || null,
      suggested_price_usd: priceUSD || null,
      comment: comment || null,
    })
    products.value = products.value.filter(p => p.id !== id)
  } finally {
    actionLoading.value = null
  }
}

async function downloadDesignFile(product) {
  downloading.value = product.id
  try {
    const { data } = await api.get(`/api/tester/products/${product.id}/download`, {
      responseType: 'blob',
    })
    const url = window.URL.createObjectURL(data)
    const a = document.createElement('a')
    a.href = url
    a.download = product.name + '_design'
    document.body.appendChild(a)
    a.click()
    a.remove()
    window.URL.revokeObjectURL(url)
  } catch (e) {
    alert(e.response?.data?.message || 'Download failed')
  } finally {
    downloading.value = null
  }
}

async function downloadDigitalFile(product, file) {
  downloading.value = file.id
  try {
    const { data } = await api.get(`/api/tester/products/${product.id}/files/${file.id}/download`, {
      responseType: 'blob',
    })
    const url = window.URL.createObjectURL(data)
    const a = document.createElement('a')
    a.href = url
    a.download = product.name + '_' + (file.file_url.split('/').pop() || 'file')
    document.body.appendChild(a)
    a.click()
    a.remove()
    window.URL.revokeObjectURL(url)
  } catch (e) {
    alert(e.response?.data?.message || 'Download failed')
  } finally {
    downloading.value = null
  }
}

async function downloadAllFiles(product) {
  const key = 'all-' + product.id
  downloading.value = key
  try {
    const { data } = await api.get(`/api/tester/products/${product.id}/download-all`, {
      responseType: 'blob',
    })
    const url = window.URL.createObjectURL(data)
    const a = document.createElement('a')
    a.href = url
    a.download = product.name + '_design_files.zip'
    document.body.appendChild(a)
    a.click()
    a.remove()
    window.URL.revokeObjectURL(url)
  } catch (e) {
    alert(e.response?.data?.message || 'Download failed')
  } finally {
    downloading.value = null
  }
}

function startConvert(ticket) {
  convertingTicket.value = ticket
  convertForm.value = {
    name: ticket.title || '',
    slug: (ticket.title || '').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, ''),
    description: ticket.description || '',
    price_egp: 0,
    price_usd: 0,
  }
}

function cancelConvert() {
  convertingTicket.value = null
}

function autoSlug() {
  convertForm.value.slug = convertForm.value.name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
}

async function convertTicket() {
  if (!convertingTicket.value) return
  actionLoading.value = 'convert-' + convertingTicket.value.id
  try {
    const { data } = await api.post(`/api/tester/tickets/${convertingTicket.value.id}/convert-to-product`, {
      name: convertForm.value.name,
      slug: convertForm.value.slug,
      description: convertForm.value.description || null,
      price_egp: convertForm.value.price_egp || null,
      price_usd: convertForm.value.price_usd || null,
    })
    products.value.unshift(data)
    tickets.value = tickets.value.filter(t => t.id !== convertingTicket.value.id)
    convertingTicket.value = null
  } catch (e) {
    alert(e.response?.data?.message || 'Conversion failed')
  } finally {
    actionLoading.value = null
  }
}

function toggleImages(id) {
  expandedImages.value = expandedImages.value === id ? null : id
}

function fileName(path) {
  if (!path) return ''
  return path.split('/').pop()
}

function isImage(mime) {
  return mime && mime.startsWith('image/')
}

async function downloadTicketAttachment(att) {
  try {
    const res = await api.get(`/api/tickets/${att.ticket_id}/attachments/${att.id}/download`, {
      responseType: 'blob',
    })
    const url = window.URL.createObjectURL(res.data)
    const a = document.createElement('a')
    a.href = url
    a.download = att.file_name
    document.body.appendChild(a)
    a.click()
    a.remove()
    window.URL.revokeObjectURL(url)
  } catch (e) {
    alert(e.response?.data?.message || 'Download failed')
  }
}

onMounted(fetchProducts)
</script>

<template>
  <div>
    <h3 class="mb-4">Product Review</h3>
    <CSpinner v-if="loading" />

    <template v-else>
      <!-- Tickets to convert -->
      <div v-if="tickets.length" class="mb-4">
        <h5 class="mb-3">Completed Tickets — Convert to Product</h5>
        <CRow :gutter="{ md: 24 }">
          <CCol v-for="t in tickets" :key="'ticket-' + t.id" :md="6" :lg="6" class="mb-4">
            <CCard class="shadow-sm h-100 border-info">
              <CCardBody>
                <div class="d-flex align-items-start gap-3 mb-3">
                  <div class="flex-grow-1 min-w-0">
                    <h4 class="mb-1 text-truncate fs-6">{{ t.title }}</h4>
                    <small class="text-body-secondary d-block">Industor: {{ t.industor?.name || 'N/A' }}</small>
                    <small class="text-body-secondary d-block">Designer: {{ t.designer?.name || 'N/A' }}</small>
                    <CBadge color="success" class="mt-1">Completed</CBadge>
                    <CBadge color="info" class="ms-1">Single Ticket</CBadge>
                  </div>
                </div>

                <div v-if="t.description" class="mb-3">
                  <small class="text-body-secondary d-block" style="white-space: pre-line;">{{ t.description }}</small>
                </div>

                <!-- Ticket Attachments -->
                <div v-if="t.attachments?.length" class="mb-3">
                  <small class="fw-semibold d-block mb-2">Deliverables ({{ t.attachments.length }})</small>
                  <div class="d-flex gap-2 flex-wrap">
                    <div
                      v-for="att in t.attachments"
                      :key="att.id"
                      class="position-relative rounded overflow-hidden border"
                      style="width: 110px; height: 110px; cursor: pointer;"
                    >
                      <img
                        v-if="isImage(att.mime_type)"
                        :src="'/storage/' + att.file_path"
                        class="w-100 h-100"
                        style="object-fit: cover;"
                        loading="lazy"
                      />
                      <div v-else class="w-100 h-100 d-flex flex-column align-items-center justify-content-center bg-light">
                        <CIcon icon="cil-file" class="text-primary mb-1" style="font-size: 1.8rem;" />
                        <span class="small text-truncate px-1" style="max-width: 90px; font-size: 0.65rem;">{{ att.file_name }}</span>
                      </div>
                      <button
                        class="position-absolute btn btn-sm btn-dark d-flex align-items-center justify-content-center"
                        style="bottom: 4px; right: 4px; width: 28px; height: 28px; border-radius: 8px; opacity: 0.85;"
                        @click.prevent="downloadTicketAttachment(att)"
                      >
                        <CIcon icon="cil-cloud-download" style="font-size: 0.75rem;" />
                      </button>
                    </div>
                  </div>
                </div>

                <!-- Conversion Form -->
                <div v-if="convertingTicket?.id === t.id" class="border-top pt-3 mt-2">
                  <h6 class="small fw-semibold mb-2">Product Details</h6>
                  <CFormInput v-model="convertForm.name" placeholder="Product name" class="mb-2" @input="autoSlug" />
                  <CFormInput v-model="convertForm.slug" placeholder="Product slug" class="mb-2" />
                  <CFormTextarea v-model="convertForm.description" rows="2" placeholder="Description (optional)" class="mb-2" />
                  <CRow class="g-2 mb-2">
                    <CCol :sm="6">
                      <CFormLabel class="small">Price EGP</CFormLabel>
                      <CFormInput v-model.number="convertForm.price_egp" type="number" min="0" step="0.01" />
                    </CCol>
                    <CCol :sm="6">
                      <CFormLabel class="small">Price USD</CFormLabel>
                      <CFormInput v-model.number="convertForm.price_usd" type="number" min="0" step="0.01" />
                    </CCol>
                  </CRow>
                  <div class="d-flex gap-2">
                    <CButton color="success" size="sm" class="flex-grow-1" :disabled="actionLoading === 'convert-' + t.id || !convertForm.name || !convertForm.slug" @click="convertTicket">
                      <CSpinner v-if="actionLoading === 'convert-' + t.id" size="sm" class="me-1" />
                      Create Product
                    </CButton>
                    <CButton color="secondary" variant="outline" size="sm" :disabled="actionLoading" @click="cancelConvert">
                      Cancel
                    </CButton>
                  </div>
                </div>

                <CButton v-else color="primary" size="sm" class="w-100 mt-2" @click="startConvert(t)">
                  Convert to Product
                </CButton>
              </CCardBody>
            </CCard>
          </CCol>
        </CRow>
      </div>

      <!-- Products pending review -->
      <div v-if="products.length">
        <h5 class="mb-3">Products Pending Review</h5>
        <CRow :gutter="{ md: 24 }">
          <CCol v-for="p in products" :key="'product-' + p.id" :md="6" :lg="6" class="mb-4">
            <CCard class="shadow-sm h-100">
              <CCardBody>
                <div class="d-flex align-items-start gap-3 mb-3">
                  <div v-if="p.images?.length" style="width: 80px; height: 80px; flex-shrink: 0;">
                    <img :src="thumbImageUrl(p.images[0])" class="rounded w-100 h-100" style="object-fit: cover;" loading="lazy" width="80" height="80" />
                  </div>
                  <div class="flex-grow-1 min-w-0">
                    <h4 class="mb-1 text-truncate fs-6">{{ p.name }}</h4>
                    <small class="text-body-secondary d-block">Designer: {{ p.designer?.name || 'N/A' }}</small>
                    <small v-if="p.ticket" class="text-body-secondary d-block">
                      Source: <CBadge color="info">From Ticket</CBadge> #{{ p.ticket.id }}
                    </small>
                    <small class="text-body-secondary d-block">Status: <CBadge :color="p.status === 'pending_tester_review' ? 'warning' : 'secondary'">{{ p.status }}</CBadge></small>
                    <div class="mt-1">
                      <small class="text-body-secondary">EGP: {{ p.price_egp || 0 }}</small>
                      <small class="text-body-secondary ms-2">USD: {{ p.price_usd || 0 }}</small>
                    </div>
                  </div>
                </div>

                <!-- Description -->
                <div v-if="p.description" class="mb-3">
                  <small class="text-body-secondary d-block" style="white-space: pre-line;">{{ p.description }}</small>
                </div>

                <!-- All Product Images -->
                <div v-if="p.images?.length" class="mb-3">
                  <div class="d-flex align-items-center justify-content-between mb-1">
                    <small class="fw-semibold">Product Images ({{ p.images.length }})</small>
                    <CButton v-if="p.images.length > 1" color="link" size="sm" class="p-0 text-decoration-none" @click="toggleImages(p.id)">
                      {{ expandedImages === p.id ? 'Collapse' : 'Show all' }}
                    </CButton>
                  </div>
                  <div class="d-flex gap-2 flex-wrap">
                    <div
                      v-for="img in (expandedImages === p.id ? p.images : p.images.slice(0, 2))"
                      :key="img.id"
                      style="width: 100px; height: 100px; flex-shrink: 0; cursor: pointer;"
                      @click="window.open('/storage/' + img.image_url, '_blank')"
                    >
                      <img :src="thumbImageUrl(img)" class="rounded border w-100 h-100" style="object-fit: cover;" loading="lazy" width="100" height="100" />
                    </div>
                  </div>
                </div>

                <!-- Design Files Download -->
                <div v-if="p.digital_files?.length" class="mb-3">
                  <div class="d-flex align-items-center justify-content-between mb-2">
                    <small class="fw-semibold">Design Files ({{ p.digital_files.length }})</small>
                    <CButton color="primary" size="sm" :disabled="downloading === 'all-' + p.id" @click="downloadAllFiles(p)">
                      <CSpinner v-if="downloading === 'all-' + p.id" size="sm" class="me-1" />
                      <CIcon icon="cil-cloud-download" class="me-1" />
                      Download All
                    </CButton>
                  </div>
                  <div v-for="f in p.digital_files" :key="f.id" class="d-flex align-items-center gap-2 p-2 mb-1 rounded" style="background: var(--cui-tertiary-bg, #f8f9fa);">
                    <CIcon icon="cil-file" class="text-primary flex-shrink-0" />
                    <div class="flex-grow-1 min-w-0">
                      <small class="d-block text-truncate">{{ f.file_url?.split('/').pop() || 'file' }}</small>
                    </div>
                  </div>
                </div>
                <div v-else-if="p.design_file_path" class="mb-3">
                  <div class="d-flex align-items-center gap-2 p-2 rounded" style="background: var(--cui-tertiary-bg, #f8f9fa);">
                    <CIcon icon="cil-file" class="text-primary" />
                    <div class="flex-grow-1 min-w-0">
                      <small class="fw-semibold d-block text-truncate">Design File</small>
                      <small class="text-body-secondary">{{ fileName(p.design_file_path) }}</small>
                    </div>
                    <CButton color="primary" size="sm" :disabled="downloading === p.id" @click="downloadDesignFile(p)">
                      <CSpinner v-if="downloading === p.id" size="sm" class="me-1" />
                      <CIcon icon="cil-cloud-download" class="me-1" />
                      Download
                    </CButton>
                  </div>
                </div>
                <div v-else class="mb-3">
                  <small class="text-body-secondary fst-italic">No design file uploaded.</small>
                </div>

                <!-- Tester Feedback (if returned before) -->
                <div v-if="p.tester_suggested_price_egp" class="mb-3 p-2 rounded" style="background: #fff3cd;">
                  <small class="fw-semibold">Previous Feedback:</small><br />
                  <small>Suggested: EGP {{ p.tester_suggested_price_egp }} | USD {{ p.tester_suggested_price_usd }}</small>
                  <small v-if="p.tester_comment" class="d-block mt-1"><em>"{{ p.tester_comment }}"</em></small>
                </div>

                <!-- Action Buttons -->
                <div class="d-flex gap-2">
                  <CButton color="success" size="sm" class="w-50" :disabled="actionLoading === p.id" @click="approve(p.id)">
                    <CSpinner v-if="actionLoading === p.id" size="sm" class="me-1" />
                    Approve & Publish
                  </CButton>
                  <CButton color="warning" size="sm" class="w-50" :disabled="actionLoading === p.id" @click="returnWithFeedback(p.id)">
                    Return w/ Feedback
                  </CButton>
                </div>
              </CCardBody>
            </CCard>
          </CCol>
        </CRow>
      </div>

      <CAlert v-if="!tickets.length && !products.length" color="info">No items pending review.</CAlert>
    </template>
  </div>
</template>
