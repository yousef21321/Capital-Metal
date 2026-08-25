<script setup>
import { ref, onMounted, computed } from 'vue'
import api from '@/api'
import { useToastStore } from '@/stores/toast'
import { thumbImageUrl } from '@/utils/image'

const toast = useToastStore()
const categories = ref([])
const loading = ref(true)
const modalVisible = ref(false)
const editing = ref(false)
const saving = ref(false)
const form = ref(emptyForm())
const imageFile = ref(null)
const imagePreview = ref(null)

function emptyForm() {
  return {
    id: null,
    name: '',
    slug: '',
    description: '',
    is_active: true,
    sort_order: 0,
  }
}

async function fetchCategories() {
  loading.value = true
  try {
    const { data } = await api.get('/api/main-categories')
    categories.value = data
  } catch (e) {
    toast.error('Failed to load categories.')
  } finally {
    loading.value = false
  }
}

function openCreate() {
  form.value = emptyForm()
  imageFile.value = null
  imagePreview.value = null
  editing.value = false
  modalVisible.value = true
}

function openEdit(category) {
  form.value = { ...emptyForm(), ...category }
  imageFile.value = null
  imagePreview.value = null
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

function onImageSelect(e) {
  const file = e.target.files?.[0] || null
  imageFile.value = file
  if (file) {
    const reader = new FileReader()
    reader.onload = (ev) => { imagePreview.value = ev.target.result }
    reader.readAsDataURL(file)
  } else {
    imagePreview.value = null
  }
}

async function save() {
  saving.value = true
  try {
    const fd = new FormData()
    fd.append('name', form.value.name)
    fd.append('slug', form.value.slug || slugify(form.value.name))
    if (form.value.description) fd.append('description', form.value.description)
    fd.append('is_active', form.value.is_active ? '1' : '0')
    fd.append('sort_order', form.value.sort_order || 0)
    if (imageFile.value) fd.append('image', imageFile.value)

    const config = { headers: { 'Content-Type': 'multipart/form-data' } }

    if (editing.value) {
      fd.append('_method', 'PUT')
      await api.post(`/api/main-categories/${form.value.id}`, fd, config)
      toast.success('Category updated.')
    } else {
      await api.post('/api/main-categories', fd, config)
      toast.success('Category created.')
    }
    modalVisible.value = false
    await fetchCategories()
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to save category.')
  } finally {
    saving.value = false
  }
}

async function remove(category) {
  if (!confirm(`Delete "${category.name}"? Products in this category will not be deleted.`)) return
  try {
    await api.delete(`/api/main-categories/${category.id}`)
    toast.success('Category deleted.')
    await fetchCategories()
  } catch (e) {
    toast.error('Failed to delete category.')
  }
}

onMounted(fetchCategories)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">Main Categories</h3>
        <p class="text-body-secondary mb-0">Manage product categories visible to all users.</p>
      </div>
      <CButton color="primary" @click="openCreate">
        <CIcon icon="cil-plus" class="me-1" /> Add Category
      </CButton>
    </div>

    <div v-if="loading" class="text-center py-5"><CSpinner /></div>

    <div v-else-if="!categories.length" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-grid" size="3xl" class="mb-3" />
      <h4>No categories yet.</h4>
      <CButton color="primary" @click="openCreate">Create your first category</CButton>
    </div>

    <CCard v-else class="shadow-sm">
      <CTable hover responsive align="middle">
        <CTableHead>
          <CTableRow>
            <CTableHeaderCell style="width: 60px">Image</CTableHeaderCell>
            <CTableHeaderCell>Name</CTableHeaderCell>
            <CTableHeaderCell>Slug</CTableHeaderCell>
            <CTableHeaderCell>Products</CTableHeaderCell>
            <CTableHeaderCell>Status</CTableHeaderCell>
            <CTableHeaderCell>Sort</CTableHeaderCell>
            <CTableHeaderCell class="text-end">Actions</CTableHeaderCell>
          </CTableRow>
        </CTableHead>
        <CTableBody>
          <CTableRow v-for="cat in categories" :key="cat.id">
            <CTableDataCell>
              <img v-if="cat.image_url" :src="`/storage/${cat.image_url}`" class="rounded" style="width: 40px; height: 40px; object-fit: cover;" />
              <CIcon v-else icon="cil-image" class="text-body-secondary" />
            </CTableDataCell>
            <CTableDataCell class="fw-semibold">{{ cat.name }}</CTableDataCell>
            <CTableDataCell class="text-body-secondary">{{ cat.slug }}</CTableDataCell>
            <CTableDataCell>
              <CBadge color="info">{{ cat.products_count || 0 }}</CBadge>
            </CTableDataCell>
            <CTableDataCell>
              <CBadge :color="cat.is_active ? 'success' : 'secondary'">{{ cat.is_active ? 'Active' : 'Inactive' }}</CBadge>
            </CTableDataCell>
            <CTableDataCell>{{ cat.sort_order }}</CTableDataCell>
            <CTableDataCell class="text-end">
              <CButton color="warning" variant="ghost" size="sm" class="me-1" @click="openEdit(cat)">
                <CIcon icon="cil-pencil" />
              </CButton>
              <CButton color="danger" variant="ghost" size="sm" @click="remove(cat)">
                <CIcon icon="cil-trash" />
              </CButton>
            </CTableDataCell>
          </CTableRow>
        </CTableBody>
      </CTable>
    </CCard>

    <!-- Create/Edit Modal -->
    <CModal :visible="modalVisible" @close="modalVisible = false" backdrop="static">
      <CModalHeader>
        <CModalTitle>{{ editing ? 'Edit Category' : 'Add Category' }}</CModalTitle>
      </CModalHeader>
      <CModalBody>
        <CCol :sm="12" class="mb-3">
          <CFormLabel class="fw-semibold">Category Name *</CFormLabel>
          <CFormInput v-model="form.name" placeholder="e.g. Home Decor" @input="onNameInput" />
        </CCol>
        <CCol :sm="12" class="mb-3">
          <CFormLabel class="fw-semibold">Slug *</CFormLabel>
          <CFormInput v-model="form.slug" placeholder="e.g. home-decor" />
        </CCol>
        <CCol :sm="12" class="mb-3">
          <CFormLabel class="fw-semibold">Description</CFormLabel>
          <CFormInput v-model="form.description" placeholder="Optional description" />
        </CCol>
        <CCol :sm="12" class="mb-3">
          <CFormLabel class="fw-semibold">Image</CFormLabel>
          <CFormInput type="file" accept="image/*" @change="onImageSelect" />
          <div v-if="imagePreview" class="mt-2">
            <img :src="imagePreview" class="rounded" style="max-width: 200px; max-height: 120px; object-fit: cover;" />
          </div>
        </CCol>
        <CRow>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold">Active</CFormLabel>
            <CFormSelect v-model="form.is_active">
              <option :value="true">Active</option>
              <option :value="false">Inactive</option>
            </CFormSelect>
          </CCol>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold">Sort Order</CFormLabel>
            <CFormInput v-model.number="form.sort_order" type="number" min="0" />
          </CCol>
        </CRow>
      </CModalBody>
      <CModalFooter>
        <CButton color="secondary" variant="outline" @click="modalVisible = false">Cancel</CButton>
        <CButton color="primary" :disabled="saving || !form.name" @click="save">
          <CSpinner v-if="saving" size="sm" class="me-1" /> {{ editing ? 'Update' : 'Create' }}
        </CButton>
      </CModalFooter>
    </CModal>
  </div>
</template>
