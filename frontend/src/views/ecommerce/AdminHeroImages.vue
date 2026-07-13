<script setup>
import { ref, onMounted } from 'vue'
import api from '@/api'
import { useToastStore } from '@/stores/toast'

const toast = useToastStore()
const images = ref([])
const loading = ref(true)
const uploading = ref(false)
const selectedFile = ref(null)
const previewUrl = ref(null)

async function fetchImages() {
  loading.value = true
  try {
    const { data } = await api.get('/api/hero-images')
    images.value = data
  } catch (e) {
    toast.error('Failed to load hero images.')
  } finally {
    loading.value = false
  }
}

function onFileSelect(e) {
  const file = e.target.files?.[0] || null
  selectedFile.value = file
  if (file) {
    const reader = new FileReader()
    reader.onload = (ev) => { previewUrl.value = ev.target.result }
    reader.readAsDataURL(file)
  } else {
    previewUrl.value = null
  }
}

function clearSelection() {
  selectedFile.value = null
  previewUrl.value = null
}

async function upload() {
  if (!selectedFile.value) return
  uploading.value = true
  const fd = new FormData()
  fd.append('image', selectedFile.value)
  try {
    await api.post('/api/hero-images', fd, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    toast.success('Image uploaded.')
    selectedFile.value = null
    await fetchImages()
  } catch (e) {
    toast.error(e.response?.data?.message || 'Upload failed.')
  } finally {
    uploading.value = false
  }
}

async function remove(id) {
  if (!confirm('Delete this hero image?')) return
  try {
    await api.delete(`/api/hero-images/${id}`)
    toast.success('Image deleted.')
    await fetchImages()
  } catch (e) {
    toast.error('Failed to delete image.')
  }
}

onMounted(fetchImages)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">Hero Images</h3>
        <p class="text-body-secondary mb-0">Manage background images for the hero section</p>
      </div>
    </div>

    <CCard class="mb-4 shadow-sm">
      <CCardBody>
        <div class="d-flex gap-3 align-items-center flex-wrap">
          <CFormInput type="file" accept="image/*" @change="onFileSelect" style="max-width: 300px;" />
          <CButton color="primary" :disabled="!selectedFile || uploading" @click="upload">
            <CSpinner v-if="uploading" size="sm" class="me-1" />
            Upload
          </CButton>
          <CButton v-if="selectedFile" color="secondary" variant="outline" size="sm" @click="clearSelection">
            <CIcon icon="cil-x" class="me-1" />Clear
          </CButton>
        </div>
        <div v-if="previewUrl" class="mt-3">
          <img :src="previewUrl" class="rounded" style="max-width: 200px; max-height: 120px; object-fit: contain;" />
        </div>
      </CCardBody>
    </CCard>

    <div v-if="loading" class="text-center py-5"><CSpinner /></div>

    <div v-else-if="!images.length" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-image" size="3xl" class="mb-3" />
      <h4>No hero images yet</h4>
      <p>Upload an image above to get started</p>
    </div>

    <CRow v-else>
      <CCol v-for="img in images" :key="img.id" sm="6" md="4" lg="3" class="mb-4">
        <CCard class="shadow-sm h-100">
          <div class="position-relative">
            <img
              :src="`/storage/${img.image_url}`"
              class="w-100 rounded-top"
              style="height: 180px; object-fit: cover;"
            />
          </div>
          <CCardBody class="d-flex justify-content-between align-items-center">
            <small class="text-body-secondary">Order: {{ img.sort_order }}</small>
            <CButton color="danger" variant="ghost" size="sm" @click="remove(img.id)">
              <CIcon icon="cil-trash" class="me-1" />Delete
            </CButton>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>
  </div>
</template>
