<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import api from '@/api'
import { useToastStore } from '@/stores/toast'
import { useAuthStore } from '@/stores/auth'
import { formatProductPrice } from '@/utils/price'
import { thumbImageUrl } from '@/utils/image'

const toast = useToastStore()
const authStore = useAuthStore()
const products = ref([])
const loading = ref(true)
const search = ref('')
const currentPage = ref(1)
const lastPage = ref(1)

const showArchived = ref(false)

const mainCategories = ref([])

const activeProducts = computed(() => products.value.filter(p => p.status !== 'archived'))
const archivedProducts = computed(() => products.value.filter(p => p.status === 'archived'))

const modalVisible = ref(false)
const editing = ref(false)
const saving = ref(false)
const form = ref(emptyForm())
const imageFile = ref(null)
const imagePreview = ref(null)

// Multi-image state for create/edit modal
const newImages = ref([])
const newImagePreviews = ref([])

const detailProduct = ref(null)
const detailVisible = ref(false)
const uploadTargetId = ref(null)
const uploadingImage = ref(false)

// Variant state
const variantModalVisible = ref(false)
const variantEditing = ref(false)
const variantSaving = ref(false)
const variantForm = ref(emptyVariantForm())
const variantTargetProductId = ref(null)
const variantImageFile = ref(null)
const variantImagePreview = ref(null)
const variantImageUploadTarget = ref(null)
const uploadingVariantImage = ref(false)

// Bullet points state
const productPoints = ref([])
const variantPoints = ref([])

// Variant material/method state
const variantAvailableMethods = ref([])
const variantMethodOther = ref('')

watch(() => variantForm.value.material, async (val) => {
  variantForm.value.manufacturing_method = ''
  variantMethodOther.value = ''
  if (!val) { variantAvailableMethods.value = []; return }
  try {
    const { data } = await api.get(`/api/materials/${val}/manufacturing-methods`)
    variantAvailableMethods.value = data
  } catch (_) {
    variantAvailableMethods.value = []
  }
})

function parseDescriptionToPoints(desc) {
  if (!desc) return []
  return desc.split('\n').map(l => l.trimStart().replace(/^- /, '')).filter(l => l.length > 0)
}

function pointsToDescription(points) {
  return points.filter(p => p.trim().length > 0).map(p => `- ${p}`).join('\n')
}

function addProductPoint() {
  productPoints.value.push('')
}

function removeProductPoint(index) {
  productPoints.value.splice(index, 1)
}

function onNewImagesSelect(e) {
  const files = Array.from(e.target.files || [])
  for (const file of files) {
    if (newImages.value.length >= 10) break
    newImages.value.push(file)
    const reader = new FileReader()
    reader.onload = (ev) => { newImagePreviews.value.push(ev.target.result) }
    reader.readAsDataURL(file)
  }
  e.target.value = ''
}

function removeNewImage(index) {
  newImages.value.splice(index, 1)
  newImagePreviews.value.splice(index, 1)
}

function addVariantPoint() {
  variantPoints.value.push('')
}

function removeVariantPoint(index) {
  variantPoints.value.splice(index, 1)
}

function emptyVariantForm() {
  return {
    id: null,
    name: '',
    description: '',
    price_egp: 0,
    price_usd: 0,
    fake_price_egp: '',
    fake_price_usd: '',
    cost: 0,
    sku: '',
    material: '',
    manufacturing_method: '',
    stock_quantity: null,
    star_rating: 0,
    sold_count: 0,
    is_active: true,
    sort_order: 0,
  }
}

function emptyForm() {
  return {
    id: null,
    name: '',
    slug: '',
    description: '',
    product_type: 'physical',
    main_category_id: '',
    price_egp: 0,
    price_usd: 0,
    fake_price_egp: '',
    fake_price_usd: '',
    cost: 0,
    status: 'published',
    publish_date: '',
    country_availability: '',
    type_sample: '',
    material: '',
    manufacturing_method: '',
    manufacturing_method_other: '',
    sku: '',
    star_rating: 0,
    sold_count: 0,
  }
}

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

async function fetchMainCategories() {
  try {
    const { data } = await api.get('/api/main-categories')
    mainCategories.value = data
  } catch (_) {}
}

watch(() => form.value.material, async (val) => {
  form.value.manufacturing_method = ''
  form.value.manufacturing_method_other = ''
  await fetchManufacturingMethods(val)
})

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
  productPoints.value = []
  newImages.value = []
  newImagePreviews.value = []
  editing.value = false
  modalVisible.value = true
}

function openEdit(product) {
  form.value = { ...emptyForm(), ...product, sku: product.inventory?.sku || '' }
  productPoints.value = parseDescriptionToPoints(product.description)
  newImages.value = []
  newImagePreviews.value = []
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

function convertEgpToUsd() {
  const val = parseFloat(form.value.price_egp)
  if (!val || val <= 0) return
  const rate = authStore.exchangeRate || 30
  if (rate > 0) {
    form.value.price_usd = parseFloat((val / rate).toFixed(2))
  }
}

function convertUsdToEgp() {
  const val = parseFloat(form.value.price_usd)
  if (!val || val <= 0) return
  const rate = authStore.exchangeRate || 30
  if (rate > 0) {
    form.value.price_egp = parseFloat((val * rate).toFixed(2))
  }
}

async function save() {
  saving.value = true
  try {
    if (editing.value) {
      const payload = {
        name: form.value.name,
        slug: form.value.slug || slugify(form.value.name),
        product_type: form.value.product_type,
        status: form.value.status || 'published',
        description: pointsToDescription(productPoints.value),
      }
      if (form.value.main_category_id) payload.main_category_id = form.value.main_category_id
      if (form.value.price_egp) payload.price_egp = form.value.price_egp
      if (form.value.price_usd) payload.price_usd = form.value.price_usd
      if (form.value.fake_price_egp) payload.fake_price_egp = form.value.fake_price_egp
      if (form.value.fake_price_usd) payload.fake_price_usd = form.value.fake_price_usd
      if (form.value.cost) payload.cost = form.value.cost
      if (form.value.publish_date) payload.publish_date = form.value.publish_date
      if (form.value.country_availability) payload.country_availability = form.value.country_availability
      if (form.value.type_sample) payload.type_sample = form.value.type_sample
      if (form.value.material) payload.material = form.value.material
      if (form.value.manufacturing_method) {
        payload.manufacturing_method = form.value.manufacturing_method === 'other' ? (form.value.manufacturing_method_other || 'other') : form.value.manufacturing_method
      }
      if (form.value.product_type === 'physical' && form.value.sku) {
        payload.sku = form.value.sku
      }
      if (form.value.star_rating !== undefined && form.value.star_rating !== null) payload.star_rating = form.value.star_rating
      if (form.value.sold_count !== undefined && form.value.sold_count !== null) payload.sold_count = form.value.sold_count
      await api.put(`/api/products/${form.value.id}`, payload)
      toast.success('Product updated.')
    } else {
      const fd = new FormData()
      fd.append('name', form.value.name)
      fd.append('slug', form.value.slug || slugify(form.value.name))
      fd.append('product_type', form.value.product_type)
      fd.append('status', form.value.status || 'published')
      if (form.value.main_category_id) fd.append('main_category_id', form.value.main_category_id)
      if (form.value.description || productPoints.value.length) {
        fd.append('description', pointsToDescription(productPoints.value))
      }
      if (form.value.price_egp) fd.append('price_egp', form.value.price_egp)
      if (form.value.price_usd) fd.append('price_usd', form.value.price_usd)
      if (form.value.fake_price_egp) fd.append('fake_price_egp', form.value.fake_price_egp)
      if (form.value.fake_price_usd) fd.append('fake_price_usd', form.value.fake_price_usd)
      if (form.value.cost) fd.append('cost', form.value.cost)
      if (form.value.publish_date) fd.append('publish_date', form.value.publish_date)
      if (form.value.country_availability) fd.append('country_availability', form.value.country_availability)
      if (form.value.type_sample) fd.append('type_sample', form.value.type_sample)
      if (form.value.material) fd.append('material', form.value.material)
      if (form.value.manufacturing_method) {
        fd.append('manufacturing_method', form.value.manufacturing_method === 'other' ? (form.value.manufacturing_method_other || 'other') : form.value.manufacturing_method)
      }
      if (form.value.product_type === 'physical' && form.value.sku) {
        fd.append('sku', form.value.sku)
      }
      fd.append('star_rating', form.value.star_rating || 0)
      fd.append('sold_count', form.value.sold_count || 0)
      for (const file of newImages.value) {
        fd.append('images[]', file)
      }
      await api.post('/api/products', fd, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
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

function openCreateVariant(productId) {
  variantForm.value = emptyVariantForm()
  variantPoints.value = []
  variantEditing.value = false
  variantTargetProductId.value = productId
  variantModalVisible.value = true
}

function openEditVariant(productId, variant) {
  variantForm.value = { ...emptyVariantForm(), ...variant }
  variantPoints.value = parseDescriptionToPoints(variant.description)
  variantEditing.value = true
  variantTargetProductId.value = productId
  variantModalVisible.value = true
}

async function saveVariant() {
  variantSaving.value = true
  try {
    const payload = { ...variantForm.value }
    payload.description = pointsToDescription(variantPoints.value)
    if (payload.manufacturing_method === 'other') payload.manufacturing_method = variantMethodOther.value || 'other'
    payload.star_rating = variantForm.value.star_rating || 0
    payload.sold_count = variantForm.value.sold_count || 0
    const pid = variantTargetProductId.value
    if (variantEditing.value) {
      await api.put(`/api/products/${pid}/variants/${variantForm.value.id}`, variantForm.value)
      toast.success('Variant updated.')
    } else {
      await api.post(`/api/products/${pid}/variants`, variantForm.value)
      toast.success('Variant created.')
    }
    variantModalVisible.value = false
    await refreshDetailProduct(pid)
    await fetchProducts()
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to save variant.')
  } finally {
    variantSaving.value = false
  }
}

async function removeVariant(productId, variantId) {
  if (!confirm('Delete this variant? This cannot be undone.')) return
  try {
    await api.delete(`/api/products/${productId}/variants/${variantId}`)
    toast.success('Variant deleted.')
    await refreshDetailProduct(productId)
    await fetchProducts()
  } catch (e) {
    toast.error('Failed to delete variant.')
  }
}

function openVariantImageUpload(productId, variantId) {
  variantImageUploadTarget.value = { productId, variantId }
  variantImageFile.value = null
  variantImagePreview.value = null
}

function onVariantImageSelect(e) {
  variantImageFile.value = e.target.files?.[0] || null
  if (variantImageFile.value) {
    const reader = new FileReader()
    reader.onload = (ev) => { variantImagePreview.value = ev.target.result }
    reader.readAsDataURL(variantImageFile.value)
  } else {
    variantImagePreview.value = null
  }
}

async function uploadVariantImage() {
  if (!variantImageFile.value || !variantImageUploadTarget.value) return
  uploadingVariantImage.value = true
  const { productId, variantId } = variantImageUploadTarget.value
  const fd = new FormData()
  fd.append('image', variantImageFile.value)
  try {
    await api.post(`/api/products/${productId}/variants/${variantId}/images`, fd, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    toast.success('Variant image uploaded.')
    variantImageFile.value = null
    variantImagePreview.value = null
    variantImageUploadTarget.value = null
    await refreshDetailProduct(productId)
    await fetchProducts()
  } catch (e) {
    toast.error(e.response?.data?.message || 'Image upload failed.')
  } finally {
    uploadingVariantImage.value = false
  }
}

async function removeVariantImage(productId, variantId, imageId) {
  try {
    await api.delete(`/api/products/${productId}/variants/${variantId}/images/${imageId}`)
    toast.success('Image removed.')
    await refreshDetailProduct(productId)
    await fetchProducts()
  } catch (e) {
    toast.error('Failed to remove image.')
  }
}

async function moveVariantImage(productId, variantId, images, index, direction) {
  const imgs = [...images]
  const target = index + direction
  if (target < 0 || target >= imgs.length) return
  ;[imgs[index], imgs[target]] = [imgs[target], imgs[index]]
  try {
    await api.put(`/api/products/${productId}/variants/${variantId}/images/reorder`, {
      image_ids: imgs.map(i => i.id),
    })
    await refreshDetailProduct(productId)
    await fetchProducts()
  } catch (e) {
    toast.error('Failed to reorder images.')
  }
}

async function refreshDetailProduct(productId) {
  try {
    const { data } = await api.get(`/api/products/${productId}`)
    detailProduct.value = data
  } catch (_) {}
}

function convertVariantEgpToUsd() {
  const val = parseFloat(variantForm.value.price_egp)
  if (!val || val <= 0) return
  const rate = authStore.exchangeRate || 30
  if (rate > 0) {
    variantForm.value.price_usd = parseFloat((val / rate).toFixed(2))
  }
}

function convertVariantUsdToEgp() {
  const val = parseFloat(variantForm.value.price_usd)
  if (!val || val <= 0) return
  const rate = authStore.exchangeRate || 30
  if (rate > 0) {
    variantForm.value.price_egp = parseFloat((val * rate).toFixed(2))
  }
}

const formatPrice = formatProductPrice

function adminProductPrice(product) {
  const variants = (product.variants || []).filter(v => v.is_active)
  if (variants.length === 0) return formatPrice(product)
  const prices = variants.map(v => parseFloat(v.price_egp || 0)).filter(p => p > 0)
  if (prices.length === 0) return formatPrice(product)
  const min = Math.min(...prices)
  const max = Math.max(...prices)
  return min === max ? `${min.toFixed(2)} EGP` : `${min.toFixed(2)} - ${max.toFixed(2)} EGP`
}

function renderDescription(text) {
  if (!text) return ''
  const lines = text.split('\n')
  const hasBullets = lines.some(l => l.trimStart().startsWith('- '))
  if (!hasBullets) return text.replace(/\n/g, '<br>')
  let html = ''
  let inList = false
  for (const line of lines) {
    const trimmed = line.trimStart()
    if (trimmed.startsWith('- ')) {
      if (!inList) { html += '<ul class="desc-list mb-2">'; inList = true }
      html += `<li>${trimmed.slice(2)}</li>`
    } else {
      if (inList) { html += '</ul>'; inList = false }
      if (line.trim()) html += `<p class="mb-1">${line}</p>`
    }
  }
  if (inList) html += '</ul>'
  return html
}

onMounted(() => {
  fetchProducts()
  fetchMaterials()
  fetchMainCategories()
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
                  <img v-if="productImage(p)" :src="thumbImageUrl(p.images?.[0])" class="rounded" style="width: 40px; height: 40px; object-fit: cover;" />
                  <CIcon v-else icon="cil-image" class="text-body-secondary" />
                </CTableDataCell>
                <CTableDataCell class="fw-semibold">{{ p.name }}</CTableDataCell>
                <CTableDataCell>
                  <CBadge :color="p.product_type === 'digital' ? 'info' : 'success'">{{ $t('products.' + p.product_type) }}</CBadge>
                </CTableDataCell>
                <CTableDataCell>{{ adminProductPrice(p) }}</CTableDataCell>                <CTableDataCell>
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
                <img v-if="productImage(p)" :src="thumbImageUrl(p.images?.[0])" class="rounded" style="width: 40px; height: 40px; object-fit: cover;" />
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
            <CFormLabel class="fw-semibold">Main Category</CFormLabel>
            <CFormSelect v-model="form.main_category_id">
              <option value="">No Category</option>
              <option v-for="cat in mainCategories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
            </CFormSelect>
          </CCol>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold">Type Sample</CFormLabel>
            <CFormInput v-model="form.type_sample" placeholder="e.g. sample type" />
          </CCol>
          <CCol :sm="6" class="mb-3" v-if="form.product_type === 'physical'">
            <CFormLabel class="fw-semibold">SKU *</CFormLabel>
            <CFormInput v-model="form.sku" placeholder="e.g. CAPITAL-METAL-TSHIRT-001" />
            <small class="text-body-secondary">Required for shipping integration (Stox)</small>
          </CCol>
          <CCol :sm="12" class="mb-3">
            <CFormLabel class="fw-semibold">{{ $t('admin_products.description') }}</CFormLabel>
            <div class="points-editor">
              <div v-for="(point, idx) in productPoints" :key="idx" class="d-flex align-items-center gap-2 mb-2">
                <span class="point-bullet">&#8226;</span>
                <CFormInput v-model="productPoints[idx]" placeholder="Enter point..." />
                <CButton color="danger" variant="ghost" size="sm" @click="removeProductPoint(idx)">
                  <CIcon icon="cil-x" />
                </CButton>
              </div>
              <CButton color="primary" variant="ghost" size="sm" @click="addProductPoint">
                <CIcon icon="cil-plus" class="me-1" /> Add Point
              </CButton>
            </div>
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">{{ $t('admin_products.price_egp') }}</CFormLabel>
            <CFormInput v-model.number="form.price_egp" type="text" inputmode="decimal" @blur="convertEgpToUsd" />
            <small v-if="form.price_egp > 0" class="text-body-secondary">
              ≈ {{ (form.price_egp / (authStore.exchangeRate || 30)).toFixed(2) }} USD
            </small>
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">{{ $t('admin_products.price_usd') }}</CFormLabel>
            <CFormInput v-model.number="form.price_usd" type="text" inputmode="decimal" @blur="convertUsdToEgp" />
            <small v-if="form.price_usd > 0" class="text-body-secondary">
              ≈ {{ (form.price_usd * (authStore.exchangeRate || 30)).toFixed(2) }} EGP
            </small>
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">{{ $t('admin_products.cost') }}</CFormLabel>
            <CFormInput v-model.number="form.cost" type="text" inputmode="decimal" />
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">Fake Price (EGP)</CFormLabel>
            <CFormInput v-model="form.fake_price_egp" type="text" inputmode="decimal" placeholder="Optional" />
            <small class="text-body-secondary">Strikethrough price, shown on card & detail</small>
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">Fake Price (USD)</CFormLabel>
            <CFormInput v-model="form.fake_price_usd" type="text" inputmode="decimal" placeholder="Optional" />
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
              <option v-for="m in materials" :key="m.id" :value="m.slug">{{ m.name }}</option>
            </CFormSelect>
          </CCol>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold">{{ $t('designer_product.method') }}</CFormLabel>
            <CFormSelect v-model="form.manufacturing_method" :disabled="!form.material">
              <option value="">{{ $t('designer_product.select_method') }}</option>
              <option v-for="method in availableManufacturingMethods" :key="method.id" :value="method.slug">{{ method.name }}</option>
              <option value="other">{{ $t('product_type.other') }}</option>
            </CFormSelect>
            <CFormInput v-if="form.manufacturing_method === 'other'" v-model="form.manufacturing_method_other" class="mt-2" :placeholder="$t('designer_product.method_other_placeholder')" />
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">Star Rating (0-5)</CFormLabel>
            <CFormInput v-model.number="form.star_rating" type="number" min="0" max="5" step="0.1" placeholder="0" />
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">Sold Count</CFormLabel>
            <CFormInput v-model.number="form.sold_count" type="number" min="0" placeholder="0" />
          </CCol>
          <CCol :sm="12" class="mb-3">
            <CFormLabel class="fw-semibold">Product Images</CFormLabel>
            <div class="image-picker-area">
              <input type="file" accept="image/*" multiple @change="onNewImagesSelect" class="d-none" ref="newImagesInput" />
              <CButton color="primary" variant="outline" size="sm" @click="$refs.newImagesInput.click()">
                <CIcon icon="cil-image-plus" class="me-1" /> Select Images
              </CButton>
              <small class="text-body-secondary ms-2">Max 10 images, 5MB each</small>
              <div v-if="newImagePreviews.length" class="mt-2 d-flex gap-2 flex-wrap">
                <div v-for="(preview, idx) in newImagePreviews" :key="idx" class="position-relative new-image-thumb">
                  <img :src="preview" class="rounded" style="width: 80px; height: 80px; object-fit: cover;" />
                  <button class="new-image-remove" @click="removeNewImage(idx)">&times;</button>
                  <span v-if="idx === 0" class="badge bg-dark position-absolute bottom-0 start-0 mb-1 ms-1" style="font-size:9px">Main</span>
                </div>
              </div>
            </div>
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
            <strong>{{ formatProductPrice(detailProduct) }}</strong>
          </CCol>
          <CCol :sm="6" class="mt-2">
            <span class="text-body-secondary d-block small">{{ $t('admin_products.price_usd') }}</span>
            <strong>${{ parseFloat(detailProduct.price_usd || 0).toFixed(2) }}</strong>
          </CCol>
        </CRow>
        <hr />
        <div class="small" v-html="renderDescription(detailProduct.description || $t('admin_products.no_description'))"></div>
        <hr />

        <!-- Variants Section -->
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h4 class="fs-6 mb-0">
            <CIcon icon="cil-layers" class="me-1" /> Variants ({{ detailProduct.variants?.length || 0 }})
          </h4>
          <CButton color="primary" size="sm" @click="openCreateVariant(detailProduct.id)">
            <CIcon icon="cil-plus" class="me-1" /> Add Variant
          </CButton>
        </div>
        <div v-if="detailProduct.variants?.length" class="mb-4">
          <CCard v-for="variant in detailProduct.variants" :key="variant.id" class="mb-2 variant-card">
            <CCardBody class="py-3">
              <div class="d-flex justify-content-between align-items-start">
                <div class="flex-grow-1">
                  <div class="d-flex align-items-center gap-2 mb-1">
                    <strong>{{ variant.name }}</strong>
                    <CBadge :color="variant.is_active ? 'success' : 'secondary'" class="small">
                      {{ variant.is_active ? 'Active' : 'Inactive' }}
                    </CBadge>
                  </div>
                  <div v-if="variant.description" class="small text-body-secondary mb-1" v-html="renderDescription(variant.description)"></div>
                  <div class="small">
                    <span class="fw-semibold">${{ parseFloat(variant.price_egp || 0).toFixed(2) }} EGP</span>
                    <small v-if="variant.fake_price_egp" class="text-decoration-line-through text-body-secondary ms-1">${{ parseFloat(variant.fake_price_egp).toFixed(2) }} EGP</small>
                    <span class="text-body-secondary mx-1">/</span>
                    <span>${{ parseFloat(variant.price_usd || 0).toFixed(2) }} USD</span>
                    <small v-if="variant.fake_price_usd" class="text-decoration-line-through text-body-secondary ms-1">${{ parseFloat(variant.fake_price_usd).toFixed(2) }} USD</small>
                    <span v-if="variant.sku" class="text-body-secondary ms-2">SKU: {{ variant.sku }}</span>
                  </div>
                  <div class="small text-body-secondary mt-1">
                    <span v-if="variant.material" class="me-2">Material: {{ variant.material }}</span>
                    <span v-if="variant.manufacturing_method">Method: {{ variant.manufacturing_method }}</span>
                  </div>
                  <!-- Variant Images -->
                  <div v-if="variant.images?.length" class="mt-2 d-flex gap-1 flex-wrap">
                    <div v-for="(img, idx) in variant.images" :key="img.id" class="position-relative variant-thumb">
                      <img :src="thumbImageUrl(img)" class="rounded" style="width: 48px; height: 48px; object-fit: cover;" />
                      <div class="variant-thumb-arrows">
                        <button class="arrow-btn-sm" :disabled="idx === 0" @click="moveVariantImage(detailProduct.id, variant.id, variant.images, idx, -1)">&#9650;</button>
                        <button class="arrow-btn-sm" :disabled="idx === variant.images.length - 1" @click="moveVariantImage(detailProduct.id, variant.id, variant.images, idx, 1)">&#9660;</button>
                      </div>
                      <button class="variant-thumb-del" @click="removeVariantImage(detailProduct.id, variant.id, img.id)">&times;</button>
                    </div>
                  </div>
                </div>
                <div class="d-flex gap-1 ms-2">
                  <CButton color="info" variant="ghost" size="sm" @click="openVariantImageUpload(detailProduct.id, variant.id)">
                    <CIcon icon="cil-image-plus" />
                  </CButton>
                  <CButton color="warning" variant="ghost" size="sm" @click="openEditVariant(detailProduct.id, variant)">
                    <CIcon icon="cil-pencil" />
                  </CButton>
                  <CButton color="danger" variant="ghost" size="sm" @click="removeVariant(detailProduct.id, variant.id)">
                    <CIcon icon="cil-trash" />
                  </CButton>
                </div>
              </div>
            </CCardBody>
          </CCard>
        </div>
        <div v-else class="text-body-secondary small mb-4">No variants yet. Add variants to offer different types of this product (e.g., Acrylic, Wood) with different prices, descriptions, and images.</div>
        <hr />

        <h4 class="fs-6">{{ $t('admin_products.images', { count: detailProduct.images?.length || 0 }) }}</h4>
        <CRow v-if="detailProduct.images?.length">
          <CCol v-for="(img, idx) in detailProduct.images" :key="img.id" sm="6" md="4" class="mb-3">
            <div class="position-relative">
              <img :src="thumbImageUrl(img)" class="w-100 rounded" style="height: 120px; object-fit: cover;" />
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

    <!-- Variant Create/Edit Modal -->
    <CModal :visible="variantModalVisible" @close="variantModalVisible = false" size="lg" backdrop="static">
      <CModalHeader>
        <CModalTitle>{{ variantEditing ? 'Edit Variant' : 'Add Variant' }}</CModalTitle>
      </CModalHeader>
      <CModalBody>
        <CRow>
          <CCol :sm="12" class="mb-3">
            <CFormLabel class="fw-semibold">Variant Name *</CFormLabel>
            <CFormInput v-model="variantForm.name" placeholder="e.g. Acrylic, Wood, Metal" />
          </CCol>
          <CCol :sm="12" class="mb-3">
            <CFormLabel class="fw-semibold">Description</CFormLabel>
            <div class="points-editor">
              <div v-for="(point, idx) in variantPoints" :key="idx" class="d-flex align-items-center gap-2 mb-2">
                <span class="point-bullet">&#8226;</span>
                <CFormInput v-model="variantPoints[idx]" placeholder="Enter point..." />
                <CButton color="danger" variant="ghost" size="sm" @click="removeVariantPoint(idx)">
                  <CIcon icon="cil-x" />
                </CButton>
              </div>
              <CButton color="primary" variant="ghost" size="sm" @click="addVariantPoint">
                <CIcon icon="cil-plus" class="me-1" /> Add Point
              </CButton>
            </div>
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">Price (EGP) *</CFormLabel>
            <CFormInput v-model.number="variantForm.price_egp" type="text" inputmode="decimal" @blur="convertVariantEgpToUsd" />
            <small v-if="variantForm.price_egp > 0" class="text-body-secondary">
              ≈ {{ (variantForm.price_egp / (authStore.exchangeRate || 30)).toFixed(2) }} USD
            </small>
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">Price (USD)</CFormLabel>
            <CFormInput v-model.number="variantForm.price_usd" type="text" inputmode="decimal" @blur="convertVariantUsdToEgp" />
            <small v-if="variantForm.price_usd > 0" class="text-body-secondary">
              ≈ {{ (variantForm.price_usd * (authStore.exchangeRate || 30)).toFixed(2) }} EGP
            </small>
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">Cost</CFormLabel>
            <CFormInput v-model.number="variantForm.cost" type="text" inputmode="decimal" />
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">Fake Price (EGP)</CFormLabel>
            <CFormInput v-model="variantForm.fake_price_egp" type="text" inputmode="decimal" placeholder="Optional" />
            <small class="text-body-secondary">Strikethrough price</small>
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">Fake Price (USD)</CFormLabel>
            <CFormInput v-model="variantForm.fake_price_usd" type="text" inputmode="decimal" placeholder="Optional" />
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">SKU</CFormLabel>
            <CFormInput v-model="variantForm.sku" placeholder="Optional SKU" />
          </CCol>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold">{{ $t('designer_product.material') }}</CFormLabel>
            <CFormSelect v-model="variantForm.material">
              <option value="">{{ $t('designer_product.select_material') }}</option>
              <option v-for="m in materials" :key="m.id" :value="m.slug">{{ m.name }}</option>
            </CFormSelect>
          </CCol>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold">{{ $t('designer_product.method') }}</CFormLabel>
            <CFormSelect v-model="variantForm.manufacturing_method" :disabled="!variantForm.material">
              <option value="">{{ $t('designer_product.select_method') }}</option>
              <option v-for="method in variantAvailableMethods" :key="method.id" :value="method.slug">{{ method.name }}</option>
              <option value="other">{{ $t('product_type.other') }}</option>
            </CFormSelect>
            <CFormInput v-if="variantForm.manufacturing_method === 'other'" v-model="variantMethodOther" class="mt-2" :placeholder="$t('designer_product.method_other_placeholder')" />
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">Stock Quantity</CFormLabel>
            <CFormInput v-model.number="variantForm.stock_quantity" type="number" min="0" placeholder="Optional" />
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">Star Rating (0-5)</CFormLabel>
            <CFormInput v-model.number="variantForm.star_rating" type="number" min="0" max="5" step="0.1" placeholder="0" />
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">Sold Count</CFormLabel>
            <CFormInput v-model.number="variantForm.sold_count" type="number" min="0" placeholder="0" />
          </CCol>
          <CCol :sm="4" class="mb-3">
            <CFormLabel class="fw-semibold">Active</CFormLabel>
            <CFormSelect v-model="variantForm.is_active">
              <option :value="true">Active</option>
              <option :value="false">Inactive</option>
            </CFormSelect>
          </CCol>
        </CRow>
      </CModalBody>
      <CModalFooter>
        <CButton color="secondary" variant="outline" @click="variantModalVisible = false">Cancel</CButton>
        <CButton color="primary" :disabled="variantSaving || !variantForm.name" @click="saveVariant">
          <CSpinner v-if="variantSaving" size="sm" class="me-1" /> {{ variantEditing ? 'Update' : 'Create' }}
        </CButton>
      </CModalFooter>
    </CModal>

    <!-- Variant Image Upload Modal -->
    <CModal :visible="!!variantImageUploadTarget" @close="variantImageUploadTarget = null" backdrop="static">
      <CModalHeader>
        <CModalTitle>Upload Variant Image</CModalTitle>
      </CModalHeader>
      <CModalBody>
        <CFormInput type="file" accept="image/*" @change="onVariantImageSelect" class="mb-3" />
        <div v-if="variantImagePreview" class="text-center">
          <img :src="variantImagePreview" class="rounded" style="max-width: 100%; max-height: 300px; object-fit: contain;" />
        </div>
      </CModalBody>
      <CModalFooter>
        <CButton color="secondary" variant="outline" @click="variantImageUploadTarget = null">Cancel</CButton>
        <CButton color="primary" :disabled="!variantImageFile || uploadingVariantImage" @click="uploadVariantImage">
          <CSpinner v-if="uploadingVariantImage" size="sm" class="me-1" /> Upload
        </CButton>
      </CModalFooter>
    </CModal>
  </div>
</template>

<style scoped>
.variant-card {
  border: 1px solid rgba(128, 128, 128, 0.15);
  border-radius: 10px;
  transition: all 0.2s ease;
}
.variant-card:hover {
  border-color: var(--cui-primary, #0EA5E9);
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}
.variant-thumb {
  position: relative;
  display: inline-block;
}
.variant-thumb-arrows {
  position: absolute;
  top: 0;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 2px;
}
.arrow-btn-sm {
  background: rgba(0,0,0,0.5);
  color: #fff;
  border: none;
  border-radius: 3px;
  width: 18px;
  height: 14px;
  font-size: 8px;
  line-height: 1;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
}
.arrow-btn-sm:hover:not(:disabled) {
  background: rgba(0,0,0,0.8);
}
.arrow-btn-sm:disabled {
  opacity: 0.3;
  cursor: default;
}
.variant-thumb-del {
  position: absolute;
  top: 0;
  right: 0;
  background: rgba(220,53,69,0.85);
  color: #fff;
  border: none;
  border-radius: 50%;
  width: 16px;
  height: 16px;
  font-size: 11px;
  line-height: 1;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  opacity: 0;
  transition: opacity 0.15s;
}
.variant-thumb:hover .variant-thumb-del {
  opacity: 1;
}
.desc-list {
  padding-left: 1.25rem;
  margin-bottom: 0.5rem;
}
.desc-list li {
  margin-bottom: 0.25rem;
  line-height: 1.6;
}
.points-editor {
  border: 1px solid var(--cui-border-color, #dee2e6);
  border-radius: 8px;
  padding: 10px 12px;
  background: var(--cui-tertiary-bg, #f8f9fa);
}
.point-bullet {
  font-size: 1.2rem;
  color: var(--cui-primary, #0EA5E9);
  flex-shrink: 0;
  width: 14px;
  text-align: center;
}
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
  border-color: var(--cui-primary, #0EA5E9);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}
.archived-toggle:active {
  transform: translateY(0);
}
.image-picker-area {
  border: 2px dashed var(--cui-border-color, #dee2e6);
  border-radius: 10px;
  padding: 14px;
  background: var(--cui-tertiary-bg, #f8f9fa);
  transition: border-color 0.2s;
}
.image-picker-area:hover {
  border-color: var(--cui-primary, #0EA5E9);
}
.new-image-thumb {
  position: relative;
  display: inline-block;
  border-radius: 8px;
  overflow: hidden;
  border: 2px solid var(--cui-border-color, #dee2e6);
}
.new-image-remove {
  position: absolute;
  top: 2px;
  right: 2px;
  background: rgba(220, 53, 69, 0.9);
  color: #fff;
  border: none;
  border-radius: 50%;
  width: 20px;
  height: 20px;
  font-size: 14px;
  line-height: 1;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  opacity: 0;
  transition: opacity 0.15s;
}
.new-image-thumb:hover .new-image-remove {
  opacity: 1;
}
</style>
