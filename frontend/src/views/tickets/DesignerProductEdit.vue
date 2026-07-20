<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '@/api'
import { useAuthStore } from '@/stores/auth'
import { formatPrice } from '@/utils/price'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()

const product = ref(null)
const loading = ref(true)
const submitting = ref(false)
const error = ref('')
const success = ref('')

const form = ref({
  name: '',
  slug: '',
  description: '',
  price_egp: 0,
  price_usd: 0,
  material: '',
  manufacturing_method: '',
  manufacturing_method_other: '',
  tags: [],
})
const tagInput = ref('')
const images = ref([])
const imagePreviews = ref([])
const existingImages = ref([])
const removedImageIds = ref([])
const designFiles = ref([])
const designFilePreviews = ref([])
const existingDesignFile = ref(null)

const commissionPct = 0.15

const materials = ref([])
const availableManufacturingMethods = ref([])

async function fetchMaterials() {
  try {
    const { data } = await api.get('/api/materials')
    materials.value = data
  } catch (_) {}
}

async function fetchManufacturingMethods(materialSlug) {
  if (!materialSlug) {
    availableManufacturingMethods.value = []
    return
  }
  try {
    const { data } = await api.get(`/api/materials/${materialSlug}/manufacturing-methods`)
    availableManufacturingMethods.value = data
  } catch (_) {
    availableManufacturingMethods.value = []
  }
}

async function onMaterialChange() {
  form.value.manufacturing_method = ''
  form.value.manufacturing_method_other = ''
  await fetchManufacturingMethods(form.value.material)
}

const activeCurrency = computed(() => auth.userCurrency || 'EGP')
const otherCurrency = computed(() => activeCurrency.value === 'EGP' ? 'USD' : 'EGP')

const primaryPrice = computed({
  get: () => activeCurrency.value === 'EGP' ? form.value.price_egp : form.value.price_usd,
  set: (val) => {
    const n = parseFloat(val) || 0
    if (activeCurrency.value === 'EGP') {
      form.value.price_egp = n
    } else {
      form.value.price_usd = n
    }
  },
})

const convertedPrice = computed(() => {
  const rate = auth.exchangeRate || 30
  if (activeCurrency.value === 'EGP') {
    return form.value.price_egp > 0 ? (form.value.price_egp / rate).toFixed(2) : 0
  }
  return form.value.price_usd > 0 ? (form.value.price_usd * rate).toFixed(2) : 0
})

const commissionEGP = computed(() => {
  if (!form.value.price_egp || form.value.price_egp <= 0) return 0
  return form.value.price_egp * commissionPct
})
const designerPriceEGP = computed(() => {
  if (!form.value.price_egp || form.value.price_egp <= 0) return 0
  return form.value.price_egp - commissionEGP.value
})
const commissionUSD = computed(() => {
  if (!form.value.price_usd || form.value.price_usd <= 0) return 0
  return form.value.price_usd * commissionPct
})
const designerPriceUSD = computed(() => {
  if (!form.value.price_usd || form.value.price_usd <= 0) return 0
  return form.value.price_usd - commissionUSD.value
})

function convertEgpToUsd() {
  const val = parseFloat(form.value.price_egp)
  if (!val || val <= 0) return
  const rate = auth.exchangeRate || 30
  if (rate > 0) {
    form.value.price_usd = parseFloat((val / rate).toFixed(2))
  }
}

function convertUsdToEgp() {
  const val = parseFloat(form.value.price_usd)
  if (!val || val <= 0) return
  const rate = auth.exchangeRate || 30
  if (rate > 0) {
    form.value.price_egp = parseFloat((val * rate).toFixed(2))
  }
}

function slugify(value) {
  return value.toLowerCase().trim().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '')
}
function onNameInput() {
  form.value.slug = slugify(form.value.name)
}

function addTag() {
  const tag = tagInput.value.trim()
  if (tag && !form.value.tags.includes(tag)) form.value.tags.push(tag)
  tagInput.value = ''
}
function removeTag(index) {
  form.value.tags.splice(index, 1)
}
function onTagKeydown(e) {
  if (e.key === 'Enter') { e.preventDefault(); addTag() }
}

function onImagesSelected(e) {
  const files = Array.from(e.target.files)
  for (const f of files) {
    images.value.push(f)
    imagePreviews.value.push(URL.createObjectURL(f))
  }
  e.target.value = ''
}
function removeNewImage(index) {
  images.value.splice(index, 1)
  URL.revokeObjectURL(imagePreviews.value[index])
  imagePreviews.value.splice(index, 1)
}
function removeExistingImage(imgId) {
  removedImageIds.value.push(imgId)
  existingImages.value = existingImages.value.filter(img => img.id !== imgId)
}

function onDesignFileSelected(e) {
  const files = Array.from(e.target.files || [])
  for (const f of files) {
    designFiles.value.push(f)
    designFilePreviews.value.push(URL.createObjectURL(f))
  }
  e.target.value = ''
}
function removeDesignFile(i) {
  URL.revokeObjectURL(designFilePreviews.value[i])
  designFilePreviews.value.splice(i, 1)
  designFiles.value.splice(i, 1)
}
function removeExistingDesignFile() {
  existingDesignFile.value = null
}

async function fetchProduct() {
  loading.value = true
  try {
    const { data } = await api.get(`/api/designer/products/${route.params.id}`)
    product.value = data
    form.value.name = data.name || ''
    form.value.slug = data.slug || ''
    form.value.description = data.description || ''
    form.value.price_egp = parseFloat(data.price_egp) || 0
    form.value.price_usd = parseFloat(data.price_usd) || 0
    form.value.material = data.material || ''
    form.value.manufacturing_method = data.manufacturing_method || ''
    form.value.tags = data.tags || []
    existingImages.value = data.images || []
    if (data.design_file_path) existingDesignFile.value = data.design_file_path
    if (data.material) await fetchManufacturingMethods(data.material)
  } catch (e) {
    error.value = 'Failed to load product.'
  } finally {
    loading.value = false
  }
}

async function submit() {
  submitting.value = true
  error.value = ''
  success.value = ''

  const fd = new FormData()
  fd.append('name', form.value.name)
  fd.append('slug', form.value.slug)
  if (form.value.description) fd.append('description', form.value.description)
  fd.append('price_egp', form.value.price_egp)
  fd.append('price_usd', form.value.price_usd)
  fd.append('platform_commission_egp', commissionEGP.value.toFixed(2))
  fd.append('platform_commission_usd', commissionUSD.value.toFixed(2))
  fd.append('designer_price_egp', designerPriceEGP.value.toFixed(2))
  fd.append('designer_price_usd', designerPriceUSD.value.toFixed(2))

  let material = form.value.material
  let method = form.value.manufacturing_method
  if (method === 'other') method = form.value.manufacturing_method_other || 'other'
  if (material) fd.append('material', material)
  if (method) fd.append('manufacturing_method', method)
  form.value.tags.forEach(t => fd.append('tags[]', t))

  for (const img of images.value) fd.append('images[]', img)

  if (designFiles.value.length) {
    for (const f of designFiles.value) fd.append('design_file', f)
  } else if (!existingDesignFile.value) {
    fd.append('design_file', '')
  }

  try {
    await api.post(`/api/designer/products/${route.params.id}`, fd, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    success.value = 'Product resubmitted for review.'
    setTimeout(() => router.push('/designer/products'), 1200)
  } catch (e) {
    error.value = e.response?.data?.message || 'Failed to update product.'
  } finally {
    submitting.value = false
  }
}

onMounted(async () => {
  await fetchMaterials()
  await fetchProduct()
})
</script>

<template>
  <div>
    <CButton color="secondary" variant="ghost" size="sm" class="mb-2" @click="router.push('/designer/products')">
      <CIcon icon="cil-arrow-left" class="me-1" /> Back to My Products
    </CButton>

    <div v-if="loading" class="text-center py-5">
      <CSpinner />
    </div>

    <template v-else-if="product">
      <h3 class="mb-4">Edit & Resubmit Product</h3>

      <CRow>
        <CCol :md="8">
          <CCard class="shadow-sm">
            <CCardBody>
              <CAlert v-if="error" color="danger" class="mb-3">{{ error }}</CAlert>
              <CAlert v-if="success" color="success" class="mb-3">{{ success }}</CAlert>

              <!-- Tester Feedback -->
              <CAlert v-if="product.tester_comment || product.tester_suggested_price_egp" color="warning" class="mb-4">
                <h4 class="fw-bold mb-2 fs-6">Tester Feedback</h4>
                <div v-if="product.tester_suggested_price_egp" class="mb-1">
                  Suggested price: <strong>{{ product.tester_suggested_price_egp }} EGP</strong>
                  <span v-if="product.tester_suggested_price_usd"> / <strong>{{ product.tester_suggested_price_usd }} USD</strong></span>
                </div>
                <div v-if="product.tester_comment" class="mb-0">
                  Comment: <em>"{{ product.tester_comment }}"</em>
                </div>
              </CAlert>

              <div class="mb-3">
                <CFormLabel class="fw-semibold">Product Name</CFormLabel>
                <CFormInput v-model="form.name" placeholder="e.g. Modern Logo Pack" @input="onNameInput" />
              </div>

              <div class="mb-3">
                <CFormLabel class="fw-semibold">Price ({{ activeCurrency }})</CFormLabel>
                <CFormInput v-model.number="primaryPrice" type="text" inputmode="decimal" placeholder="0.00" />
                <small v-if="primaryPrice > 0" class="text-body-secondary">
                  ≈ {{ convertedPrice }} {{ otherCurrency }}
                </small>
              </div>

              <div class="mb-3 p-3 rounded" style="background: #f8f9fa;">
                <div class="d-flex justify-content-between mb-1">
                  <span class="text-body-secondary">Price</span>
                  <strong>{{ formatPrice(form.price_egp) }} EGP<span v-if="form.price_egp > 0 || form.price_usd > 0"> / </span>{{ formatPrice(form.price_usd) }} USD</strong>
                </div>
                <div class="d-flex justify-content-between mb-1">
                  <span class="text-body-secondary">Platform Commission (15%)</span>
                  <span class="text-danger">- {{ formatPrice(commissionEGP) }} EGP<span v-if="form.price_egp > 0 || form.price_usd > 0"> / </span>{{ formatPrice(commissionUSD) }} USD</span>
                </div>
                <hr class="my-1" />
                <div class="d-flex justify-content-between">
                  <span class="fw-semibold">Designer Price</span>
                  <strong class="text-success">{{ formatPrice(designerPriceEGP) }} EGP<span v-if="form.price_egp > 0 || form.price_usd > 0"> / </span>{{ formatPrice(designerPriceUSD) }} USD</strong>
                </div>
              </div>

              <div class="mb-3">
                <CFormLabel class="fw-semibold">Description</CFormLabel>
                <CFormTextarea v-model="form.description" rows="5" placeholder="Describe your digital product..." />
              </div>

              <div class="mb-3">
                <CFormLabel class="fw-semibold">Product Images</CFormLabel>
                <div v-if="existingImages.length" class="d-flex gap-2 mb-2 flex-wrap">
                  <div v-for="img in existingImages" :key="img.id" class="position-relative" style="width: 100px; height: 100px;">
                    <img :src="'/storage/' + img.image_url" class="rounded border w-100 h-100" style="object-fit: cover;" />
                    <span role="button" class="position-absolute top-0 end-0 badge bg-danger rounded-circle" style="cursor: pointer; transform: translate(25%, -25%);" @click="removeExistingImage(img.id)">&times;</span>
                  </div>
                </div>
                <CFormInput type="file" accept="image/jpeg,image/png,image/webp,image/gif" multiple @change="onImagesSelected" />
                <div v-if="imagePreviews.length" class="d-flex gap-2 mt-2">
                  <div v-for="(preview, i) in imagePreviews" :key="i" class="position-relative" style="width: 100px; height: 100px;">
                    <img :src="preview" class="rounded border w-100 h-100" style="object-fit: cover;" />
                    <span role="button" class="position-absolute top-0 end-0 badge bg-danger rounded-circle" style="cursor: pointer; transform: translate(25%, -25%);" @click="removeNewImage(i)">&times;</span>
                  </div>
                </div>
              </div>

              <div class="mb-3">
                <CFormLabel class="fw-semibold">Design File (hidden until purchase)</CFormLabel>
                <div v-if="existingDesignFile" class="d-flex align-items-center gap-2 mb-2">
                  <CIcon icon="cil-file" class="text-body-secondary" />
                  <small>Current file uploaded</small>
                  <CButton color="danger" size="sm" variant="ghost" @click="removeExistingDesignFile">Remove</CButton>
                </div>
                <div class="d-flex gap-2 align-items-center">
                  <CFormInput type="file" accept=".pdf,.zip,.ai,.eps,.svg,.dxf,.psd,image/png,image/jpeg" @change="onDesignFileSelected" />
                </div>
                <div v-if="designFilePreviews.length" class="d-flex gap-2 mt-2 flex-wrap">
                  <div v-for="(preview, i) in designFilePreviews" :key="i" class="position-relative d-inline-flex align-items-center gap-1 rounded border px-2 py-1" style="height: 36px;">
                    <CIcon icon="cil-file" class="text-body-secondary" />
                    <span class="small">{{ designFiles[i]?.name }}</span>
                    <span role="button" class="badge bg-danger rounded-circle" style="cursor: pointer; width: 18px; height: 18px; line-height: 1; padding: 0;" @click="removeDesignFile(i)">&times;</span>
                  </div>
                </div>
                <small class="text-body-secondary">Customers will receive this file after purchase.</small>
              </div>

              <div class="mb-3">
                <CFormLabel class="fw-semibold">Material</CFormLabel>
                <CFormSelect v-model="form.material" @change="onMaterialChange">
                  <option value="">-- Select Material --</option>
                  <option v-for="m in materials" :key="m.id" :value="m.slug">{{ m.name }}</option>
                </CFormSelect>
              </div>

              <div class="mb-3">
                <CFormLabel class="fw-semibold">Manufacturing Method</CFormLabel>
                <CFormSelect v-model="form.manufacturing_method" :disabled="!form.material">
                  <option value="">-- Select Method --</option>
                  <option v-for="method in availableManufacturingMethods" :key="method.id" :value="method.slug">{{ method.name }}</option>
                  <option value="other">Other</option>
                </CFormSelect>
                <CFormInput v-if="form.manufacturing_method === 'other'" v-model="form.manufacturing_method_other" class="mt-2" placeholder="Enter custom method..." />
              </div>

              <div class="mb-3">
                <CFormLabel class="fw-semibold">Tags</CFormLabel>
                <div class="d-flex gap-2 mb-2">
                  <CFormInput v-model="tagInput" placeholder="Add a tag..." @keydown="onTagKeydown" />
                  <CButton color="secondary" variant="outline" @click="addTag" :disabled="!tagInput.trim()">Add</CButton>
                </div>
                <div v-if="form.tags.length" class="d-flex flex-wrap gap-1">
                  <span v-for="(tag, i) in form.tags" :key="i"
                    class="badge d-inline-flex align-items-center gap-1 px-3 py-2"
                    style="background: #e9ecef; color: #333; font-size: 0.85rem;">
                    {{ tag }}
                    <span role="button" class="ms-1" style="cursor: pointer; line-height: 1;" @click="removeTag(i)">&times;</span>
                  </span>
                </div>
                <small v-else class="text-body-secondary">Add tags so users can find your product by search.</small>
              </div>

              <div class="d-flex gap-2">
                <CButton color="warning" :disabled="submitting || !form.name || !form.slug" @click="submit">
                  <CSpinner v-if="submitting" size="sm" class="me-1" /> Resubmit for Review
                </CButton>
                <CButton color="secondary" variant="outline" @click="router.push('/designer/products')">Cancel</CButton>
              </div>
            </CCardBody>
          </CCard>
        </CCol>

        <CCol :md="4">
          <CCard class="shadow-sm bg-body-tertiary">
            <CCardBody>
              <h4 class="fw-bold fs-6"><CIcon icon="cil-info" class="me-1" /> Editing Tips</h4>
              <p class="small text-body-secondary mb-0">Review the tester's feedback carefully. Once resubmitted, a tester will review your product again.</p>
            </CCardBody>
          </CCard>
        </CCol>
      </CRow>
    </template>

    <CAlert v-else color="danger">Product not found.</CAlert>
  </div>
</template>
