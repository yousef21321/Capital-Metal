<script setup>
import { ref, computed } from 'vue'
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
  tags: [],
})
const submitting = ref(false)
const error = ref('')
const success = ref('')
const priceApplied = ref(false)
const tagInput = ref('')
const images = ref([])
const imagePreviews = ref([])
const designFile = ref(null)
const designFileName = ref('')

const commission = computed(() => {
  if (!priceApplied.value || !form.value.price_egp) return 0
  return form.value.price_egp * 0.1
})

const netProfit = computed(() => {
  if (!priceApplied.value || !form.value.price_egp) return 0
  return form.value.price_egp - commission.value
})

function applyPrice() {
  if (form.value.price_egp > 0) {
    priceApplied.value = true
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
  const files = Array.from(e.target.files).slice(0, 2)
  images.value = files
  imagePreviews.value = files.map(f => URL.createObjectURL(f))
}

function removeImage(index) {
  images.value.splice(index, 1)
  URL.revokeObjectURL(imagePreviews.value[index])
  imagePreviews.value.splice(index, 1)
}

function onDesignFileSelected(e) {
  const file = e.target.files[0]
  if (file) {
    designFile.value = file
    designFileName.value = file.name
  }
}

function removeDesignFile() {
  designFile.value = null
  designFileName.value = ''
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
  if (form.value.material) fd.append('material', form.value.material)
  if (form.value.manufacturing_method) fd.append('manufacturing_method', form.value.manufacturing_method)
  form.value.tags.forEach(t => fd.append('tags[]', t))

  for (const img of images.value) {
    fd.append('images[]', img)
  }

  if (designFile.value) {
    fd.append('design_file', designFile.value)
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
      <CIcon icon="cil-arrow-left" class="me-1" /> Back to Products
    </CButton>
    <h3 class="mb-4">Create Digital Product</h3>

    <CRow>
      <CCol :md="8">
        <CCard class="shadow-sm">
          <CCardBody>
            <CAlert v-if="error" color="danger" class="mb-3">{{ error }}</CAlert>
            <CAlert v-if="success" color="success" class="mb-3">{{ success }}</CAlert>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">Product Name</CFormLabel>
              <CFormInput v-model="form.name" placeholder="e.g. Modern Logo Pack" @input="onNameInput" />
            </div>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">Slug</CFormLabel>
              <CFormInput v-model="form.slug" placeholder="auto-generated" />
            </div>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">Description</CFormLabel>
              <CFormTextarea v-model="form.description" rows="5" placeholder="Describe your digital product..." />
            </div>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">Product Images (up to 2)</CFormLabel>
              <CFormInput type="file" accept="image/jpeg,image/png,image/webp,image/gif" multiple @change="onImagesSelected" />
              <div v-if="imagePreviews.length" class="d-flex gap-2 mt-2">
                <div v-for="(preview, i) in imagePreviews" :key="i" class="position-relative" style="width: 120px; height: 120px;">
                  <img :src="preview" class="rounded border w-100 h-100" style="object-fit: cover;" />
                  <span role="button" class="position-absolute top-0 end-0 badge bg-danger rounded-circle" style="cursor: pointer; transform: translate(25%, -25%);" @click="removeImage(i)">&times;</span>
                </div>
              </div>
            </div>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">Design File (hidden until purchase)</CFormLabel>
              <div class="d-flex gap-2 align-items-center">
                <CFormInput type="file" accept=".pdf,.zip,.ai,.eps,.svg,.dxf,.psd,image/png,image/jpeg" @change="onDesignFileSelected" />
              </div>
              <div v-if="designFileName" class="d-flex align-items-center gap-2 mt-2">
                <CIcon icon="cil-file" class="text-body-secondary" />
                <span class="small">{{ designFileName }}</span>
                <span role="button" class="badge bg-danger" style="cursor: pointer;" @click="removeDesignFile">Remove</span>
              </div>
              <small class="text-body-secondary">Customers will receive this file after purchase.</small>
            </div>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">Price ({{ auth.userCurrency }})</CFormLabel>
              <div class="d-flex gap-2">
                <CFormInput v-model.number="form.price_egp" type="number" min="0" class="flex-grow-1" placeholder="0.00" />
                <CButton color="primary" variant="outline" @click="applyPrice" :disabled="!form.price_egp || form.price_egp <= 0">
                  Apply
                </CButton>
              </div>
              <div v-if="priceApplied && form.price_egp > 0" class="mt-2 p-3 rounded" style="background: #f8f9fa;">
                <div class="d-flex justify-content-between mb-1">
                  <span class="text-body-secondary">Price:</span>
                  <strong>{{ formatPrice(form.price_egp) }}</strong>
                </div>
                <div class="d-flex justify-content-between mb-1">
                  <span class="text-body-secondary">Commission (10%):</span>
                  <span class="text-danger">- {{ formatPrice(commission) }}</span>
                </div>
                <hr class="my-1" />
                <div class="d-flex justify-content-between">
                  <span class="fw-semibold">Net Profit:</span>
                  <strong class="text-success">{{ formatPrice(netProfit) }}</strong>
                </div>
              </div>
            </div>

            <CRow>
              <CCol :sm="6" class="mb-3">
                <CFormLabel class="fw-semibold">Price (USD)</CFormLabel>
                <CFormInput v-model.number="form.price_usd" type="number" min="0" placeholder="0.00" />
              </CCol>
              <CCol :sm="6" class="mb-3">
                <CFormLabel class="fw-semibold">Material</CFormLabel>
                <CFormSelect v-model="form.material">
                  <option value="">-- Select Material --</option>
                  <option value="cotton">Cotton</option>
                  <option value="polyester">Polyester</option>
                  <option value="silk">Silk</option>
                  <option value="wool">Wool</option>
                  <option value="linen">Linen</option>
                  <option value="denim">Denim</option>
                  <option value="leather">Leather</option>
                  <option value="spandex">Spandex</option>
                  <option value="nylon">Nylon</option>
                  <option value="rayon">Rayon</option>
                  <option value="velvet">Velvet</option>
                  <option value="lace">Lace</option>
                  <option value="other">Other</option>
                </CFormSelect>
              </CCol>
            </CRow>

            <div class="mb-3">
              <CFormLabel class="fw-semibold">Manufacturing Method</CFormLabel>
              <CFormSelect v-model="form.manufacturing_method">
                <option value="">-- Select Method --</option>
                <option value="knitted">Knitted</option>
                <option value="woven">Woven</option>
                <option value="embroidered">Embroidered</option>
                <option value="printed">Printed</option>
                <option value="embellished">Embellished</option>
                <option value="handmade">Handmade</option>
                <option value="machine_made">Machine Made</option>
                <option value="cut_and_sew">Cut & Sew</option>
                <option value="molded">Molded</option>
                <option value="other">Other</option>
              </CFormSelect>
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
              <CButton color="primary" :disabled="submitting || !form.name || !form.slug" @click="submit">
                <CSpinner v-if="submitting" size="sm" class="me-1" /> Create Product
              </CButton>
              <CButton color="secondary" variant="outline" @click="router.push('/products')">Cancel</CButton>
            </div>
          </CCardBody>
        </CCard>
      </CCol>

      <CCol :md="4">
        <CCard class="shadow-sm bg-body-tertiary">
          <CCardBody>
            <h6 class="fw-bold"><CIcon icon="cil-info" class="me-1" /> Digital Products</h6>
            <p class="small text-body-secondary mb-0">Products you create appear in the public store. Upload images to showcase your work. The design file stays hidden and is delivered to customers after purchase.</p>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>
  </div>
</template>
