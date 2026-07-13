<script setup>
import { ref, watch, onMounted, computed } from 'vue'
import api from '@/api'
import { useToastStore } from '@/stores/toast'
import { useAuthStore } from '@/stores/auth'

const toast = useToastStore()
const authStore = useAuthStore()
const products = ref([])
const loading = ref(true)
const search = ref('')
const currentPage = ref(1)
const lastPage = ref(1)

const showArchived = ref(false)

const activeProducts = computed(() => products.value.filter(p => p.status !== 'archived'))
const archivedProducts = computed(() => products.value.filter(p => p.status === 'archived'))

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
    type_sample: '',
    material: '',
    manufacturing_method: '',
    material_other: '',
    manufacturing_method_other: '',
  }
}

async function fetchProducts() {
  loading.value = true
  try {
    const params = { page: currentPage.value, status: 'all' }
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

let converting = false

watch(() => form.value.price_egp, (val) => {
  if (converting || !val || val <= 0) return
  converting = true
  const rate = authStore.exchangeRate || 30
  if (rate > 0) {
    form.value.price_usd = parseFloat((val / rate).toFixed(4))
  }
  converting = false
})

watch(() => form.value.price_usd, (val) => {
  if (converting || !val || val <= 0) return
  converting = true
  const rate = authStore.exchangeRate || 30
  if (rate > 0) {
    form.value.price_egp = parseFloat((val * rate).toFixed(4))
  }
  converting = false
})

async function save() {
  saving.value = true
  try {
    const payload = { ...form.value }
    if (payload.material === 'other') payload.material = payload.material_other || 'other'
    if (payload.manufacturing_method === 'other') payload.manufacturing_method = payload.manufacturing_method_other || 'other'
    delete payload.material_other
    delete payload.manufacturing_method_other
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

async function moveImage(productId, index, direction) {
  const images = [...detailProduct.value.images]
  const target = index + direction
  if (target < 0 || target >= images.length) return
  ;[images[index], images[target]] = [images[target], images[index]]
  try {
    await api.put(`/api/products/${productId}/images/reorder`, {
      image_ids: images.map(i => i.id),
    })
    detailProduct.value = { ...detailProduct.value, images }
    await fetchProducts()
  } catch (e) {
    toast.error('Failed to reorder images.')
  }
}

const productImage = (product) => {
  const img = product.images?.[0]
  if (img && img.image_url) return `/storage/${img.image_url}`
  return null
}

const formatPrice = (p) => {
  if (parseFloat(p.price_egp) > 0) return `${parseFloat(p.price_egp).toFixed(2)} EGP`
  if (parseFloat(p.price_usd) > 0) return `$${parseFloat(p.price_usd).toFixed(2)}`
  return $t('admin_products.free')
}

onMounted(() => {
  fetchProducts()
  if (!authStore.exchangeRate) authStore.fetchExchangeRate()
})
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">{{ $t('admin_products.title') }}</h3>
        <p class="text-body-secondary mb-0">{{ $t('admin_products.desc') }}</p>
      </div>
      <CButton color="primary" @click="openCreate">
        <CIcon icon="cil-plus" class="me-1" /> {{ $t('admin_products.add') }}
      </CButton>
    </div>

    <CCard class="mb-4 shadow-sm">
      <CCardBody>
        <div class="input-group">
          <span class="input-group-text"><CIcon icon="cil-search" /></span>
          <input v-model="search" class="form-control" :placeholder="$t('admin_products.search')" @input="fetchProducts" />
        </div>
      </CCardBody>
    </CCard>

    <div v-if="loading" class="text-center py-5"><CSpinner /></div>

    <div v-else-if="!products.length" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-cart" size="3xl" class="mb-3" />
      <h4>{{ $t('admin_products.no_products') }}</h4>
      <CButton color="primary" @click="openCreate">{{ $t('admin_products.create_first') }}</CButton>
    </div>

    <div v-else>
      <!-- Archived Toggle -->
      <div class="mb-3">
        <CButton
          color="dark"
          variant="ghost"
          class="w-100 d-flex justify-content-between align-items-center archived-toggle"
          @click="showArchived = !showArchived"
        >
          <span>
            <CIcon icon="cil-archive" class="me-2" />
            Archived ({{ archivedProducts.length }})
          </span>
          <CIcon :icon="showArchived ? 'cil-chevron-up' : 'cil-chevron-down'" />
        </CButton>
        <CCard v-if="showArchived && archivedProducts.length" class="shadow-sm mt-1 mb-4">
          <CTable hover responsive align="middle">
            <CTableHead>
              <CTableRow>
                <CTableHeaderCell style="width: 60px">{{ $t('admin_products.image') }}</CTableHeaderCell>
                <CTableHeaderCell>{{ $t('admin_products.name') }}</CTableHeaderCell>
                <CTableHeaderCell>{{ $t('admin_products.type') }}</CTableHeaderCell>
                <CTableHeaderCell>{{ $t('admin_products.price') }}</CTableHeaderCell>
                <CTableHeaderCell>{{ $t('admin_products.status') }}</CTableHeaderCell>
                <CTableHeaderCell class="text-end">{{ $t('admin_products.actions') }}</CTableHeaderCell>
              </CTableRow>
            </CTableHead>
            <CTableBody>
              <CTableRow v-for="p in archivedProducts" :key="p.id">
                <CTableDataCell>
                  <img v-if="productImage(p)" :src="productImage(p)" class="rounded" style="width: 40px; height: 40px; object-fit: cover;" />
                  <CIcon v-else icon="cil-image" class="text-body-secondary" />
                </CTableDataCell>
                <CTableDataCell class="fw-semibold">{{ p.name }}</CTableDataCell>
                <CTableDataCell>
                  <CBadge :color="p.product_type === 'digital' ? 'info' : 'success'">{{ $t('products.' + p.product_type) }}</CBadge>
                </CTableDataCell>
                <CTableDataCell>{{ formatPrice(p) }}</CTableDataCell>
                <CTableDataCell>
                  <CBadge :color="p.status === 'published' ? 'success' : 'secondary'">{{ $t('admin_products.' + p.status) }}</CBadge>
                </CTableDataCell>
                <CTableDataCell class="text-end">
                  <CButton color="info" variant="ghost" size="sm" class="me-1" @click="openImageUpload(p)">
                    {{ $t('admin_products.upload') }}
                  </CButton>
                  <CButton color="primary" variant="ghost" size="sm" class="me-1" @click="openDetail(p)">
                    {{ $t('admin_products.view') }}
                  </CButton>
                  <CButton color="warning" variant="ghost" size="sm" class="me-1" @click="openEdit(p)">
                    {{ $t('admin_products.edit') }}
                  </CButton>
                  <CButton color="danger" variant="ghost" size="sm" @click="remove(p)">
                    {{ $t('admin_products.delete') }}
                  </CButton>
                </CTableDataCell>
              </CTableRow>
            </CTableBody>
          </CTable>
        </CCard>
      </div>

      <!-- Active Products -->
      <CCard class="shadow-sm">
        <CTable hover responsive align="middle">
          <CTableHead>
            <CTableRow>
              <CTableHeaderCell style="width: 60px">{{ $t('admin_products.image') }}</CTableHeaderCell>
              <CTableHeaderCell>{{ $t('admin_products.name') }}</CTableHeaderCell>
              <CTableHeaderCell>{{ $t('admin_products.type') }}</CTableHeaderCell>
              <CTableHeaderCell>{{ $t('admin_products.price') }}</CTableHeaderCell>
              <CTableHeaderCell>{{ $t('admin_products.status') }}</CTableHeaderCell>
              <CTableHeaderCell class="text-end">{{ $t('admin_products.actions') }}</CTableHeaderCell>
            </CTableRow>
          </CTableHead>
          <CTableBody>
            <CTableRow v-for="p in activeProducts" :key="p.id">
              <CTableDataCell>
                <img v-if="productImage(p)" :src="productImage(p)" class="rounded" style="width: 40px; height: 40px; object-fit: cover;" />
                <CIcon v-else icon="cil-image" class="text-body-secondary" />
              </CTableDataCell>
              <CTableDataCell class="fw-semibold">{{ p.name }}</CTableDataCell>
              <CTableDataCell>
                <CBadge :color="p.product_type === 'digital' ? 'info' : 'success'">{{ $t('products.' + p.product_type) }}</CBadge>
              </CTableDataCell>
              <CTableDataCell>{{ formatPrice(p) }}</CTableDataCell>
              <CTableDataCell>
                <CBadge :color="p.status === 'published' ? 'success' : 'secondary'">{{ $t('admin_products.' + p.status) }}</CBadge>
              </CTableDataCell>
              <CTableDataCell class="text-end">
                <CButton color="info" variant="ghost" size="sm" class="me-1" @click="openImageUpload(p)">
                  {{ $t('admin_products.upload') }}
                </CButton>
                <CButton color="primary" variant="ghost" size="sm" class="me-1" @click="openDetail(p)">
                  {{ $t('admin_products.view') }}
                </CButton>
                <CButton color="warning" variant="ghost" size="sm" class="me-1" @click="openEdit(p)">
                  {{ $t('admin_products.edit') }}
                </CButton>
                <CButton color="danger" variant="ghost" size="sm" @click="remove(p)">
                  {{ $t('admin_products.delete') }}
                </CButton>
              </CTableDataCell>
            </CTableRow>
          </CTableBody>
        </CTable>
      </CCard>

      <div v-if="lastPage > 1" class="mt-4">
        <CPagination align="center">
          <CPaginationItem :disabled="currentPage === 1" @click="currentPage--; fetchProducts()">{{ $t('admin_products.previous') }}</CPaginationItem>
          <CPaginationItem v-for="page in lastPage" :key="page" :active="page === currentPage" @click="currentPage = page; fetchProducts()">{{ page }}</CPaginationItem>
          <CPaginationItem :disabled="currentPage === lastPage" @click="currentPage++; fetchProducts()">{{ $t('admin_products.next') }}</CPaginationItem>
        </CPagination>
      </div>

    </div>

    <!-- Create/Edit Modal -->
    <CModal :visible="modalVisible" @close="modalVisible = false" size="lg" backdrop="static">
      <CModalHeader>
        <CModalTitle>{{ editing ? $t('admin_products.edit_title') : $t('admin_products.add_title') }}</CModalTitle>
      </CModalHeader>
      <CModalBody>
        <CRow>
          <CCol :sm="12" class="mb-3">
            <CFormLabel class="fw-semibold">{{ $t('admin_products.name_label') }}</CFormLabel>
            <CFormInput v-model="form.name" :placeholder="$t('admin_products.name_placeholder')" @input="onNameInput" />
          </CCol>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold">{{ $t('admin_products.slug') }}</CFormLabel>
            <CFormInput v-model="form.slug" :placeholder="$t('admin_products.slug_placeholder')" />
          </CCol>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold">{{ $t('admin_products.type') }}</CFormLabel>
            <CFormSelect v-model="form.product_type">
              <option value="physical">{{ $t('products.physical') }}</option>
              <option value="digital">{{ $t('products.digital') }}</option>
            </CFormSelect>
          </CCol>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold">Type Sample</CFormLabel>
            <CFormInput v-model="form.type_sample" placeholder="e.g. sample type" />
          </CCol>
          <CCol :sm="12" class="mb-3">
            <CFormLabel class="fw-semibold">{{ $t('admin_products.description') }}</CFormLabel>
            <CFormTextarea v-model="form.description" rows="3" :placeholder="$t('admin_products.description_placeholder')" />
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">{{ $t('admin_products.price_egp') }}</CFormLabel>
            <CFormInput v-model.number="form.price_egp" type="text" inputmode="decimal" />
            <small v-if="form.price_egp > 0" class="text-body-secondary">
              ≈ {{ (form.price_egp / (authStore.exchangeRate || 30)).toFixed(2) }} USD
            </small>
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">{{ $t('admin_products.price_usd') }}</CFormLabel>
            <CFormInput v-model.number="form.price_usd" type="text" inputmode="decimal" />
            <small v-if="form.price_usd > 0" class="text-body-secondary">
              ≈ {{ (form.price_usd * (authStore.exchangeRate || 30)).toFixed(2) }} EGP
            </small>
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">{{ $t('admin_products.cost') }}</CFormLabel>
            <CFormInput v-model.number="form.cost" type="text" inputmode="decimal" />
          </CCol>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold">{{ $t('admin_products.status') }}</CFormLabel>
            <CFormSelect v-model="form.status">
              <option value="published">{{ $t('admin_products.published') }}</option>
              <option value="draft">{{ $t('admin_products.draft') }}</option>
              <option value="archived">{{ $t('admin_products.archived') }}</option>
            </CFormSelect>
          </CCol>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold">{{ $t('admin_products.country') }}</CFormLabel>
            <CFormInput v-model="form.country_availability" :placeholder="$t('admin_products.country_placeholder')" />
          </CCol>
          <CCol :sm="6" class="mb-3">
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
          </CCol>
          <CCol :sm="6" class="mb-3">
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
          </CCol>
        </CRow>
      </CModalBody>
      <CModalFooter>
        <CButton color="secondary" variant="outline" @click="modalVisible = false">{{ $t('admin_products.cancel') }}</CButton>
        <CButton color="primary" :disabled="saving || !form.name || !form.slug" @click="save">
          <CSpinner v-if="saving" size="sm" class="me-1" /> {{ editing ? $t('admin_products.update') : $t('admin_products.create_btn') }}
        </CButton>
      </CModalFooter>
    </CModal>

    <!-- Image Upload Modal -->
    <CModal :visible="!!uploadTargetId" @close="uploadTargetId = null" backdrop="static">
      <CModalHeader>
        <CModalTitle>{{ $t('admin_products.upload_image') }}</CModalTitle>
      </CModalHeader>
      <CModalBody>
        <CFormInput type="file" accept="image/*" @change="onImageSelect" class="mb-3" />
        <div v-if="imagePreview" class="text-center">
          <img :src="imagePreview" class="rounded" style="max-width: 100%; max-height: 300px; object-fit: contain;" />
        </div>
      </CModalBody>
      <CModalFooter>
        <CButton color="secondary" variant="outline" @click="uploadTargetId = null">{{ $t('admin_products.cancel') }}</CButton>
        <CButton color="primary" :disabled="!imageFile || uploadingImage" @click="uploadImage">
          <CSpinner v-if="uploadingImage" size="sm" class="me-1" /> {{ $t('admin_products.upload') }}
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
            <span class="text-body-secondary d-block small">{{ $t('admin_products.type') }}</span>
            <CBadge :color="detailProduct.product_type === 'digital' ? 'info' : 'success'">{{ $t('products.' + detailProduct.product_type) }}</CBadge>
          </CCol>
          <CCol :sm="6">
            <span class="text-body-secondary d-block small">{{ $t('admin_products.status') }}</span>
            <CBadge :color="detailProduct.status === 'published' ? 'success' : 'secondary'">{{ $t('admin_products.' + detailProduct.status) }}</CBadge>
          </CCol>
          <CCol :sm="6" class="mt-2">
            <span class="text-body-secondary d-block small">{{ $t('admin_products.price_egp') }}</span>
            <strong>{{ parseFloat(detailProduct.price_egp || 0).toFixed(2) }} EGP</strong>
          </CCol>
          <CCol :sm="6" class="mt-2">
            <span class="text-body-secondary d-block small">{{ $t('admin_products.price_usd') }}</span>
            <strong>${{ parseFloat(detailProduct.price_usd || 0).toFixed(2) }}</strong>
          </CCol>
        </CRow>
        <hr />
        <p>{{ detailProduct.description || $t('admin_products.no_description') }}</p>
        <hr />
        <h6>{{ $t('admin_products.images', { count: detailProduct.images?.length || 0 }) }}</h6>
        <CRow v-if="detailProduct.images?.length">
          <CCol v-for="(img, idx) in detailProduct.images" :key="img.id" sm="6" md="4" class="mb-3">
            <div class="position-relative">
              <img :src="`/storage/${img.image_url}`" class="w-100 rounded" style="height: 120px; object-fit: cover;" />
              <div v-if="idx === 0" class="position-absolute top-0 start-0 m-1">
                <span class="badge bg-dark">Main</span>
              </div>
              <div class="image-arrows">
                <button class="arrow-btn" :disabled="idx === 0" @click="moveImage(detailProduct.id, idx, -1)">&#9650;</button>
                <button class="arrow-btn" :disabled="idx === detailProduct.images.length - 1" @click="moveImage(detailProduct.id, idx, 1)">&#9660;</button>
              </div>
              <CButton color="danger" size="sm" class="position-absolute top-0 end-0 m-1" @click="removeImage(detailProduct.id, img.id)">
                {{ $t('admin_products.delete') }}
              </CButton>
            </div>
          </CCol>
        </CRow>
        <div v-else class="text-body-secondary small">{{ $t('admin_products.no_images') }}</div>
      </CModalBody>
      <CModalFooter>
        <CButton color="info" variant="outline" @click="openImageUpload(detailProduct); detailVisible = false">
          <CIcon icon="cil-image-plus" class="me-1" /> {{ $t('admin_products.add_image') }}
        </CButton>
        <CButton color="secondary" @click="detailVisible = false">{{ $t('admin_products.close') }}</CButton>
      </CModalFooter>
    </CModal>
  </div>
</template>

<style scoped>
.archived-toggle {
  border: 1px solid rgba(128, 128, 128, 0.2);
  border-radius: 12px;
  padding: 0.85rem 1.25rem;
  transition: all 0.25s ease;
  font-weight: 500;
  letter-spacing: 0.3px;
  background: transparent;
  color: var(--cui-body-color, inherit);
}
.image-arrows {
  position: absolute;
  top: 4px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 4px;
}
.arrow-btn {
  background: rgba(0,0,0,0.55);
  color: #fff;
  border: none;
  border-radius: 4px;
  width: 28px;
  height: 24px;
  font-size: 12px;
  line-height: 1;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.15s;
}
.arrow-btn:hover:not(:disabled) {
  background: rgba(0,0,0,0.8);
}
.arrow-btn:disabled {
  opacity: 0.3;
  cursor: default;
}
.archived-toggle:hover {
  background: rgba(128, 128, 128, 0.06);
  border-color: var(--cui-primary, #b81300);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}
.archived-toggle:active {
  transform: translateY(0);
}
</style>
