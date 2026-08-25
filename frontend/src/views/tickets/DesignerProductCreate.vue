<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/api'
import { useAuthStore } from '@/stores/auth'
import { formatPrice } from '@/utils/price'

const router = useRouter()
const auth = useAuthStore()
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
  star_rating: 0,
  sold_count: 0,
})
const submitting = ref(false)
const error = ref('')
const success = ref('')
const tagInput = ref('')
const images = ref([])
const imagePreviews = ref([])
const designFiles = ref([])
const designFilePreviews = ref([])

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

onMounted(async () => {
  await fetchMaterials()
})

const commissionPct = 0.15

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
  if (tag && !form.value.tags.includes(tag)) {
    form.value.tags.push(tag)
  }
  tagInput.value = ''
}

function removeTag(index) {
  form.value.tags.splice(index, 1)
}

function onTagKeydown(e) {
  if (e.key === 'Enter') {
    e.preventDefault()
    addTag()
  }
}

function onImagesSelected(e) {
  const files = Array.from(e.target.files)
  for (const f of files) {
    images.value.push(f)
    imagePreviews.value.push(URL.createObjectURL(f))
  }
  e.target.value = ''
}

function removeImage(index) {
  images.value.splice(index, 1)
  URL.revokeObjectURL(imagePreviews.value[index])
  imagePreviews.value.splice(index, 1)
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
  fd.append('star_rating', form.value.star_rating || 0)
  fd.append('sold_count', form.value.sold_count || 0)
  form.value.tags.forEach(t => fd.append('tags[]', t))

  for (const img of images.value) {
    fd.append('images[]', img)
  }

  for (const f of designFiles.value) {
    fd.append('design_files[]', f)
  }

  try {
    const { data } = await api.post('/api/designer/products', fd, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    success.value = 'Product submitted for review. A tester will review it shortly.'
    setTimeout(() => router.push('/designer/products'), 1200)
  } catch (e) {
    error.value = e.response?.data?.message || 'Failed to create product.'
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div>
    <CButton color="secondary" variant="ghost" size="sm" class="mb-2" @click="router.push('/products')">
      <CIcon icon="cil-arrow-left" class="me-1" /> {{ $t('designer_product.back') }}
    </CButton>
    <h3 class="mb-4">{{ $t('designer_product.title') }}</h3>

    <CRow>
      <CCol :md="8">
        <CCard class="shadow-sm">
          <CCardBody>
            <CAlert v-if="error" color="danger" class="mb-3">{{ error }}</CAlert>
            <CAlert v-if="success" color="success" class="mb-3">{{ success }}</CAlert>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">{{ $t('designer_product.product_name') }}</CFormLabel>
              <CFormInput v-model="form.name" :placeholder="$t('designer_product.product_name_placeholder')" @input="onNameInput" />
            </div>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">{{ $t('designer_product.price', { currency: activeCurrency }) }}</CFormLabel>
              <CFormInput v-model.number="primaryPrice" type="text" inputmode="decimal" :placeholder="$t('designer_product.price_placeholder')" />
              <small v-if="primaryPrice > 0" class="text-body-secondary">
                ≈ {{ convertedPrice }} {{ otherCurrency }}
              </small>
            </div>

            <div class="mb-3 p-3 rounded" style="background: #f8f9fa;">
              <div class="d-flex justify-content-between mb-1">
                <span class="text-body-secondary">{{ $t('designer_product.price_label') }}</span>
                <strong>{{ formatPrice(form.price_egp) }} EGP<span v-if="form.price_egp > 0 || form.price_usd > 0"> / </span>{{ formatPrice(form.price_usd) }} USD</strong>
              </div>
              <div class="d-flex justify-content-between mb-1">
                <span class="text-body-secondary">{{ $t('designer_product.commission') }}</span>
                <span class="text-danger">- {{ formatPrice(commissionEGP) }} EGP<span v-if="form.price_egp > 0 || form.price_usd > 0"> / </span>{{ formatPrice(commissionUSD) }} USD</span>
              </div>
              <hr class="my-1" />
              <div class="d-flex justify-content-between">
                <span class="fw-semibold">{{ $t('designer_product.designer_price') }}</span>
                <strong class="text-success">{{ formatPrice(designerPriceEGP) }} EGP<span v-if="form.price_egp > 0 || form.price_usd > 0"> / </span>{{ formatPrice(designerPriceUSD) }} USD</strong>
              </div>
            </div>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">{{ $t('designer_product.description') }}</CFormLabel>
              <CFormTextarea v-model="form.description" rows="5" :placeholder="$t('designer_product.description_placeholder')" />
            </div>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">{{ $t('designer_product.images') }}</CFormLabel>
              <CFormInput type="file" accept="image/jpeg,image/png,image/webp,image/gif" multiple @change="onImagesSelected" />
              <div v-if="imagePreviews.length" class="d-flex gap-2 mt-2">
                <div v-for="(preview, i) in imagePreviews" :key="i" class="position-relative" style="width: 120px; height: 120px;">
                  <img :src="preview" class="rounded border w-100 h-100" style="object-fit: cover;" />
                  <span role="button" class="position-absolute top-0 end-0 badge bg-danger rounded-circle" style="cursor: pointer; transform: translate(25%, -25%);" @click="removeImage(i)">&times;</span>
                </div>
              </div>
            </div>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">{{ $t('designer_product.design_file') }}</CFormLabel>
              <div class="d-flex gap-2 align-items-center">
                <CFormInput type="file" multiple accept=".pdf,.zip,.ai,.eps,.svg,.dxf,.psd,image/png,image/jpeg" @change="onDesignFileSelected" />
              </div>
              <div v-if="designFilePreviews.length" class="d-flex gap-2 mt-2 flex-wrap">
                <div v-for="(preview, i) in designFilePreviews" :key="i" class="position-relative d-inline-flex align-items-center gap-1 rounded border px-2 py-1" style="height: 36px;">
                  <CIcon icon="cil-file" class="text-body-secondary" />
                  <span class="small">{{ designFiles[i]?.name }}</span>
                  <span role="button" class="badge bg-danger rounded-circle" style="cursor: pointer; width: 18px; height: 18px; line-height: 1; padding: 0;" @click="removeDesignFile(i)">&times;</span>
                </div>
              </div>
              <small class="text-body-secondary">{{ $t('designer_product.design_file_help') }}</small>
            </div>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">{{ $t('designer_product.material') }}</CFormLabel>
              <CFormSelect v-model="form.material" @change="onMaterialChange">
                  <option value="">{{ $t('designer_product.select_material') }}</option>
                  <option v-for="m in materials" :key="m.id" :value="m.slug">{{ m.name }}</option>
              </CFormSelect>
          </div>

          <div class="mb-3">
              <CFormLabel class="fw-semibold">{{ $t('designer_product.method') }}</CFormLabel>
              <CFormSelect v-model="form.manufacturing_method" :disabled="!form.material">
                <option value="">{{ $t('designer_product.select_method') }}</option>
                <option v-for="method in availableManufacturingMethods" :key="method.id" :value="method.slug">{{ method.name }}</option>
                <option value="other">{{ $t('product_type.other') }}</option>
              </CFormSelect>
              <CFormInput v-if="form.manufacturing_method === 'other'" v-model="form.manufacturing_method_other" class="mt-2" :placeholder="$t('designer_product.method_other_placeholder')" />
          </div>

          <CRow>
            <CCol :sm="6" class="mb-3">
              <CFormLabel class="fw-semibold">Star Rating (0-5)</CFormLabel>
              <CFormInput v-model.number="form.star_rating" type="number" min="0" max="5" step="0.1" placeholder="0" />
            </CCol>
            <CCol :sm="6" class="mb-3">
              <CFormLabel class="fw-semibold">Sold Count</CFormLabel>
              <CFormInput v-model.number="form.sold_count" type="number" min="0" placeholder="0" />
            </CCol>
          </CRow>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">{{ $t('designer_product.tags') }}</CFormLabel>
              <div class="d-flex gap-2 mb-2">
                <CFormInput v-model="tagInput" :placeholder="$t('designer_product.tag_placeholder')" @keydown="onTagKeydown" />
                <CButton color="secondary" variant="outline" @click="addTag" :disabled="!tagInput.trim()">{{ $t('designer_product.add_tag') }}</CButton>
              </div>
              <div v-if="form.tags.length" class="d-flex flex-wrap gap-1">
                <span v-for="(tag, i) in form.tags" :key="i"
                  class="badge d-inline-flex align-items-center gap-1 px-3 py-2"
                  style="background: #e9ecef; color: #333; font-size: 0.85rem;">
                  {{ tag }}
                  <span role="button" class="ms-1" style="cursor: pointer; line-height: 1;" @click="removeTag(i)">&times;</span>
                </span>
              </div>
              <small v-else class="text-body-secondary">{{ $t('designer_product.tags_help') }}</small>
            </div>

            <div class="d-flex gap-2">
              <CButton color="primary" :disabled="submitting || !form.name || !form.slug" @click="submit">
                <CSpinner v-if="submitting" size="sm" class="me-1" /> {{ $t('designer_product.create') }}
              </CButton>
              <CButton color="secondary" variant="outline" @click="router.push('/products')">{{ $t('designer_product.cancel') }}</CButton>
            </div>
          </CCardBody>
        </CCard>
      </CCol>

      <CCol :md="4">
        <CCard class="shadow-sm bg-body-tertiary">
          <CCardBody>
            <h4 class="fw-bold fs-6"><CIcon icon="cil-info" class="me-1" /> {{ $t('designer_product.sidebar_title') }}</h4>
            <p class="small text-body-secondary mb-0">{{ $t('designer_product.sidebar_desc') }}</p>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>
  </div>
</template>
