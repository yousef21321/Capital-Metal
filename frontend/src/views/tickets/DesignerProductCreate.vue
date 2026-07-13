<script setup>
import { ref, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/api'
import { useAuthStore } from '@/stores/auth'

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
  material_other: '',
  manufacturing_method_other: '',
  tags: [],
})
const submitting = ref(false)
const error = ref('')
const success = ref('')
const tagInput = ref('')
const images = ref([])
const imagePreviews = ref([])
const designFiles = ref([])
const designFilePreviews = ref([])

const commissionPct = 0.15

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

let converting = false

watch(() => form.value.price_egp, (val) => {
  if (converting || !val || val <= 0) return
  converting = true
  const rate = auth.exchangeRate || 30
  if (rate > 0) {
    form.value.price_usd = parseFloat((val / rate).toFixed(4))
  }
  converting = false
})

watch(() => form.value.price_usd, (val) => {
  if (converting || !val || val <= 0) return
  converting = true
  const rate = auth.exchangeRate || 30
  if (rate > 0) {
    form.value.price_egp = parseFloat((val * rate).toFixed(4))
  }
  converting = false
})

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
  if (material === 'other') material = form.value.material_other || 'other'
  let method = form.value.manufacturing_method
  if (method === 'other') method = form.value.manufacturing_method_other || 'other'
  if (material) fd.append('material', material)
  if (method) fd.append('manufacturing_method', method)
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
    success.value = 'Product created successfully.'
    setTimeout(() => router.push('/products'), 1200)
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
              <CFormLabel class="fw-semibold">{{ $t('designer_product.price', { currency: 'EGP' }) }}</CFormLabel>
              <CFormInput v-model.number="form.price_egp" type="text" inputmode="decimal" :placeholder="$t('designer_product.price_placeholder')" />
              <small v-if="form.price_egp > 0" class="text-body-secondary">
                ≈ {{ (form.price_egp / (auth.exchangeRate || 30)).toFixed(2) }} USD
              </small>
            </div>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">{{ $t('designer_product.price_usd') }}</CFormLabel>
              <CFormInput v-model.number="form.price_usd" type="text" inputmode="decimal" :placeholder="$t('designer_product.price_usd_placeholder')" />
              <small v-if="form.price_usd > 0" class="text-body-secondary">
                ≈ {{ (form.price_usd * (auth.exchangeRate || 30)).toFixed(2) }} EGP
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
              <CFormSelect v-model="form.material">
                  <option value="">{{ $t('designer_product.select_material') }}</option>
                  <option value="cotton">{{ $t('product_type.cotton') }}</option>
                  <option value="polyester">{{ $t('product_type.polyester') }}</option>
                  <option value="silk">{{ $t('product_type.silk') }}</option>
                  <option value="wool">{{ $t('product_type.wool') }}</option>
                  <option value="linen">{{ $t('product_type.linen') }}</option>
                  <option value="denim">{{ $t('product_type.denim') }}</option>
                  <option value="leather">{{ $t('product_type.leather') }}</option>
                  <option value="spandex">{{ $t('product_type.spandex') }}</option>
                  <option value="nylon">{{ $t('product_type.nylon') }}</option>
                  <option value="rayon">{{ $t('product_type.rayon') }}</option>
                  <option value="velvet">{{ $t('product_type.velvet') }}</option>
                  <option value="lace">{{ $t('product_type.lace') }}</option>
                <option value="other">{{ $t('product_type.other') }}</option>
              </CFormSelect>
              <CFormInput v-if="form.material === 'other'" v-model="form.material_other" class="mt-2" :placeholder="$t('designer_product.material_other_placeholder')" />
          </div>

          <div class="mb-3">
              <CFormLabel class="fw-semibold">{{ $t('designer_product.method') }}</CFormLabel>
              <CFormSelect v-model="form.manufacturing_method">
                <option value="">{{ $t('designer_product.select_method') }}</option>
                <option value="knitted">{{ $t('product_type.knitted') }}</option>
                <option value="woven">{{ $t('product_type.woven') }}</option>
                <option value="embroidered">{{ $t('product_type.embroidered') }}</option>
                <option value="printed">{{ $t('product_type.printed') }}</option>
                <option value="embellished">{{ $t('product_type.embellished') }}</option>
                <option value="handmade">{{ $t('product_type.handmade') }}</option>
                <option value="machine_made">{{ $t('product_type.machine_made') }}</option>
                <option value="cut_and_sew">{{ $t('product_type.cut_sew') }}</option>
                <option value="molded">{{ $t('product_type.molded') }}</option>
                <option value="other">{{ $t('product_type.other') }}</option>
              </CFormSelect>
              <CFormInput v-if="form.manufacturing_method === 'other'" v-model="form.manufacturing_method_other" class="mt-2" :placeholder="$t('designer_product.method_other_placeholder')" />
          </div>

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
            <h6 class="fw-bold"><CIcon icon="cil-info" class="me-1" /> {{ $t('designer_product.sidebar_title') }}</h6>
            <p class="small text-body-secondary mb-0">{{ $t('designer_product.sidebar_desc') }}</p>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>
  </div>
</template>
