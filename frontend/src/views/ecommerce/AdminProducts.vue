<script setup>
import { ref, onMounted, computed } from 'vue'
import api from '@/api'
import { useToastStore } from '@/stores/toast'

const toast = useToastStore()
const products = ref([])
const loading = ref(true)
const search = ref('')
const currentPage = ref(1)
const lastPage = ref(1)

const modalVisible = ref(false)
const editing = ref(false)
const saving = ref(false)
const form = ref(emptyForm())
const imageFile = ref(null)
const imagePreview = ref(null)

const detailProduct = ref(null)
const detailVisible = ref(false)
const uploadTargetId = ref(null)
const uploadingImage = ref(false)

function emptyForm() {
  return {
    id: null,
    name: '',
    slug: '',
    description: '',
    product_type: 'physical',
    price_egp: 0,
    price_usd: 0,
    cost: 0,
    status: 'published',
    publish_date: '',
    country_availability: '',
  }
}

async function fetchProducts() {
  loading.value = true
  try {
    const params = { page: currentPage.value }
    if (search.value) params.search = search.value
    const { data } = await api.get('/api/products', { params })
    products.value = data.data
    currentPage.value = data.current_page
    lastPage.value = data.last_page
  } catch (e) {
    toast.error('Failed to load products.')
  } finally {
    loading.value = false
  }
}

function openCreate() {
  form.value = emptyForm()
  editing.value = false
  modalVisible.value = true
}

function openEdit(product) {
  form.value = { ...emptyForm(), ...product }
  editing.value = true
  modalVisible.value = true
}

function slugify(value) {
  return value.toLowerCase().trim().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '')
}

function onNameInput() {
  if (!editing.value) {
    form.value.slug = slugify(form.value.name)
  }
}

async function save() {
  saving.value = true
  try {
    const payload = { ...form.value }
    if (editing.value) {
      await api.put(`/api/products/${form.value.id}`, payload)
      toast.success('Product updated.')
    } else {
      payload.slug = payload.slug || slugify(payload.name)
      payload.publish_date = payload.publish_date || new Date().toISOString().slice(0, 10)
      await api.post('/api/products', payload)
      toast.success('Product created.')
    }
    modalVisible.value = false
    await fetchProducts()
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to save product.')
  } finally {
    saving.value = false
  }
}

async function remove(product) {
  if (!confirm(`Delete "${product.name}"? This cannot be undone.`)) return
  try {
    await api.delete(`/api/products/${product.id}`)
    toast.success('Product deleted.')
    await fetchProducts()
  } catch (e) {
    toast.error('Failed to delete product.')
  }
}

function openDetail(product) {
  detailProduct.value = product
  detailVisible.value = true
}

function openImageUpload(product) {
  uploadTargetId.value = product.id
  imageFile.value = null
  imagePreview.value = null
}

function onImageSelect(e) {
  imageFile.value = e.target.files?.[0] || null
  if (imageFile.value) {
    const reader = new FileReader()
    reader.onload = (ev) => { imagePreview.value = ev.target.result }
    reader.readAsDataURL(imageFile.value)
  } else {
    imagePreview.value = null
  }
}

async function uploadImage() {
  if (!imageFile.value || !uploadTargetId.value) return
  uploadingImage.value = true
  const fd = new FormData()
  fd.append('image', imageFile.value)
  try {
    await api.post(`/api/products/${uploadTargetId.value}/images`, fd, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    toast.success('Image uploaded.')
    imageFile.value = null
    imagePreview.value = null
    uploadTargetId.value = null
    await fetchProducts()
  } catch (e) {
    toast.error(e.response?.data?.message || 'Image upload failed.')
  } finally {
    uploadingImage.value = false
  }
}

async function removeImage(productId, imageId) {
  try {
    await api.delete(`/api/products/${productId}/images/${imageId}`)
    toast.success('Image removed.')
    const { data } = await api.get(`/api/products/${productId}`)
    detailProduct.value = data
    await fetchProducts()
  } catch (e) {
    toast.error('Failed to remove image.')
  }
}

const productImage = (product) => {
  const img = product.images?.[0]
  if (img && img.image_url) return `${api.defaults.baseURL}/storage/${img.image_url}`
  return null
}

const formatPrice = (p) => {
  if (parseFloat(p.price_egp) > 0) return `${parseFloat(p.price_egp).toFixed(2)} EGP`
  if (parseFloat(p.price_usd) > 0) return `$${parseFloat(p.price_usd).toFixed(2)}`
  return 'Free'
}

onMounted(fetchProducts)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">Product Management</h3>
        <p class="text-body-secondary mb-0">Create, edit, and manage all products.</p>
      </div>
      <CButton color="primary" @click="openCreate">
        <CIcon icon="cil-plus" class="me-1" /> Add Product
      </CButton>
    </div>

    <CCard class="mb-4 shadow-sm">
      <CCardBody>
        <div class="input-group">
          <span class="input-group-text"><CIcon icon="cil-search" /></span>
          <input v-model="search" class="form-control" placeholder="Search products..." @input="fetchProducts" />
        </div>
      </CCardBody>
    </CCard>

    <div v-if="loading" class="text-center py-5"><CSpinner /></div>

    <div v-else-if="!products.length" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-cart" size="3xl" class="mb-3" />
      <h4>No products yet</h4>
      <CButton color="primary" @click="openCreate">Create your first product</CButton>
    </div>

    <CCard v-else class="shadow-sm">
      <CTable hover responsive align="middle">
        <CTableHead>
          <CTableRow>
            <CTableHeaderCell style="width: 60px">Image</CTableHeaderCell>
            <CTableHeaderCell>Name</CTableHeaderCell>
            <CTableHeaderCell>Type</CTableHeaderCell>
            <CTableHeaderCell>Price</CTableHeaderCell>
            <CTableHeaderCell>Status</CTableHeaderCell>
            <CTableHeaderCell class="text-end">Actions</CTableHeaderCell>
          </CTableRow>
        </CTableHead>
        <CTableBody>
          <CTableRow v-for="p in products" :key="p.id">
            <CTableDataCell>
              <img v-if="productImage(p)" :src="productImage(p)" class="rounded" style="width: 40px; height: 40px; object-fit: cover;" />
              <CIcon v-else icon="cil-image" class="text-body-secondary" />
            </CTableDataCell>
            <CTableDataCell class="fw-semibold">{{ p.name }}</CTableDataCell>
            <CTableDataCell>
              <CBadge :color="p.product_type === 'digital' ? 'info' : 'success'">{{ p.product_type }}</CBadge>
            </CTableDataCell>
            <CTableDataCell>{{ formatPrice(p) }}</CTableDataCell>
            <CTableDataCell>
              <CBadge :color="p.status === 'published' ? 'success' : 'secondary'">{{ p.status }}</CBadge>
            </CTableDataCell>
            <CTableDataCell class="text-end">
              <CButton color="info" variant="ghost" size="sm" class="me-1" @click="openImageUpload(p)">
                <CIcon icon="cil-image-plus" />
              </CButton>
              <CButton color="primary" variant="ghost" size="sm" class="me-1" @click="openDetail(p)">
                <CIcon icon="cil-eye" />
              </CButton>
              <CButton color="warning" variant="ghost" size="sm" class="me-1" @click="openEdit(p)">
                <CIcon icon="cil-pencil" />
              </CButton>
              <CButton color="danger" variant="ghost" size="sm" @click="remove(p)">
                <CIcon icon="cil-trash" />
              </CButton>
            </CTableDataCell>
          </CTableRow>
        </CTableBody>
      </CTable>
    </CCard>

    <div v-if="lastPage > 1" class="mt-4">
      <CPagination align="center">
        <CPaginationItem :disabled="currentPage === 1" @click="currentPage--; fetchProducts()">Previous</CPaginationItem>
        <CPaginationItem v-for="page in lastPage" :key="page" :active="page === currentPage" @click="currentPage = page; fetchProducts()">{{ page }}</CPaginationItem>
        <CPaginationItem :disabled="currentPage === lastPage" @click="currentPage++; fetchProducts()">Next</CPaginationItem>
      </CPagination>
    </div>

    <!-- Create/Edit Modal -->
    <CModal :visible="modalVisible" @close="modalVisible = false" size="lg" backdrop="static">
      <CModalHeader>
        <CModalTitle>{{ editing ? 'Edit Product' : 'Add Product' }}</CModalTitle>
      </CModalHeader>
      <CModalBody>
        <CRow>
          <CCol :sm="12" class="mb-3">
            <CFormLabel class="fw-semibold">Name</CFormLabel>
            <CFormInput v-model="form.name" placeholder="Product name" @input="onNameInput" />
          </CCol>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold">Slug</CFormLabel>
            <CFormInput v-model="form.slug" placeholder="product-slug" />
          </CCol>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold">Type</CFormLabel>
            <CFormSelect v-model="form.product_type">
              <option value="physical">Physical</option>
              <option value="digital">Digital</option>
            </CFormSelect>
          </CCol>
          <CCol :sm="12" class="mb-3">
            <CFormLabel class="fw-semibold">Description</CFormLabel>
            <CFormTextarea v-model="form.description" rows="3" placeholder="Product description" />
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">Price (EGP)</CFormLabel>
            <CFormInput v-model.number="form.price_egp" type="number" min="0" step="0.01" />
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">Price (USD)</CFormLabel>
            <CFormInput v-model.number="form.price_usd" type="number" min="0" step="0.01" />
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">Cost</CFormLabel>
            <CFormInput v-model.number="form.cost" type="number" min="0" step="0.01" />
          </CCol>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold">Status</CFormLabel>
            <CFormSelect v-model="form.status">
              <option value="published">Published</option>
              <option value="draft">Draft</option>
              <option value="archived">Archived</option>
            </CFormSelect>
          </CCol>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold">Country Availability</CFormLabel>
            <CFormInput v-model="form.country_availability" placeholder="e.g. Egypt, USA" />
          </CCol>
        </CRow>
      </CModalBody>
      <CModalFooter>
        <CButton color="secondary" variant="outline" @click="modalVisible = false">Cancel</CButton>
        <CButton color="primary" :disabled="saving || !form.name || !form.slug" @click="save">
          <CSpinner v-if="saving" size="sm" class="me-1" /> {{ editing ? 'Update' : 'Create' }}
        </CButton>
      </CModalFooter>
    </CModal>

    <!-- Image Upload Modal -->
    <CModal :visible="!!uploadTargetId" @close="uploadTargetId = null" backdrop="static">
      <CModalHeader>
        <CModalTitle>Upload Product Image</CModalTitle>
      </CModalHeader>
      <CModalBody>
        <CFormInput type="file" accept="image/*" @change="onImageSelect" class="mb-3" />
        <div v-if="imagePreview" class="text-center">
          <img :src="imagePreview" class="rounded" style="max-width: 100%; max-height: 300px; object-fit: contain;" />
        </div>
      </CModalBody>
      <CModalFooter>
        <CButton color="secondary" variant="outline" @click="uploadTargetId = null">Cancel</CButton>
        <CButton color="primary" :disabled="!imageFile || uploadingImage" @click="uploadImage">
          <CSpinner v-if="uploadingImage" size="sm" class="me-1" /> Upload
        </CButton>
      </CModalFooter>
    </CModal>

    <!-- Detail Modal -->
    <CModal :visible="detailVisible" @close="detailVisible = false" size="lg" scrollable>
      <CModalHeader>
        <CModalTitle>{{ detailProduct?.name }}</CModalTitle>
      </CModalHeader>
      <CModalBody v-if="detailProduct">
        <CRow class="mb-3">
          <CCol :sm="6">
            <span class="text-body-secondary d-block small">Type</span>
            <CBadge :color="detailProduct.product_type === 'digital' ? 'info' : 'success'">{{ detailProduct.product_type }}</CBadge>
          </CCol>
          <CCol :sm="6">
            <span class="text-body-secondary d-block small">Status</span>
            <CBadge :color="detailProduct.status === 'published' ? 'success' : 'secondary'">{{ detailProduct.status }}</CBadge>
          </CCol>
          <CCol :sm="6" class="mt-2">
            <span class="text-body-secondary d-block small">Price EGP</span>
            <strong>{{ parseFloat(detailProduct.price_egp || 0).toFixed(2) }} EGP</strong>
          </CCol>
          <CCol :sm="6" class="mt-2">
            <span class="text-body-secondary d-block small">Price USD</span>
            <strong>${{ parseFloat(detailProduct.price_usd || 0).toFixed(2) }}</strong>
          </CCol>
        </CRow>
        <hr />
        <p>{{ detailProduct.description || 'No description' }}</p>
        <hr />
        <h6>Images ({{ detailProduct.images?.length || 0 }})</h6>
        <CRow v-if="detailProduct.images?.length">
          <CCol v-for="img in detailProduct.images" :key="img.id" sm="6" md="4" class="mb-3">
            <div class="position-relative">
              <img :src="`${api.defaults.baseURL}/storage/${img.image_url}`" class="w-100 rounded" style="height: 120px; object-fit: cover;" />
              <CButton color="danger" size="sm" class="position-absolute top-0 end-0 m-1" @click="removeImage(detailProduct.id, img.id)">
                <CIcon icon="cil-x" />
              </CButton>
            </div>
          </CCol>
        </CRow>
        <div v-else class="text-body-secondary small">No images uploaded yet.</div>
      </CModalBody>
      <CModalFooter>
        <CButton color="info" variant="outline" @click="openImageUpload(detailProduct); detailVisible = false">
          <CIcon icon="cil-image-plus" class="me-1" /> Add Image
        </CButton>
        <CButton color="secondary" @click="detailVisible = false">Close</CButton>
      </CModalFooter>
    </CModal>
  </div>
</template>
