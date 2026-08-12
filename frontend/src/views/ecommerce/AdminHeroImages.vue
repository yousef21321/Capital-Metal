<script setup>
import { ref, onMounted, computed } from 'vue'
import api from '@/api'
import { useToastStore } from '@/stores/toast'
import { thumbImageUrl } from '@/utils/image'

const toast = useToastStore()
const images = ref([])
const loading = ref(true)
const uploading = ref(false)
const selectedFile = ref(null)
const previewUrl = ref(null)
const mediaType = ref('image')
const videoUrl = ref('')
const altText = ref('')
const sortOrder = ref(0)

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
  videoUrl.value = ''
  altText.value = ''
  sortOrder.value = 0
}

function onTypeChange(type) {
  mediaType.value = type
  selectedFile.value = null
  previewUrl.value = null
  videoUrl.value = ''
}

const canUpload = computed(() => {
  if (mediaType.value === 'video') return !!videoUrl.value.trim()
  return !!selectedFile.value
})

async function upload() {
  if (!canUpload.value) return
  uploading.value = true
  const fd = new FormData()
  fd.append('media_type', mediaType.value)
  fd.append('alt_text', altText.value)
  fd.append('sort_order', sortOrder.value)

  if (mediaType.value === 'video') {
    fd.append('video_url', videoUrl.value.trim())
  } else {
    fd.append('image', selectedFile.value)
  }

  try {
    await api.post('/api/hero-images', fd, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    toast.success(mediaType.value === 'video' ? 'Video added.' : 'Image uploaded.')
    clearSelection()
    await fetchImages()
  } catch (e) {
    toast.error(e.response?.data?.message || 'Upload failed.')
  } finally {
    uploading.value = false
  }
}

async function remove(id) {
  if (!confirm('Delete this hero item?')) return
  try {
    await api.delete(`/api/hero-images/${id}`)
    toast.success('Deleted.')
    await fetchImages()
  } catch (e) {
    toast.error('Failed to delete.')
  }
}

onMounted(fetchImages)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">Hero Media</h3>
        <p class="text-body-secondary mb-0">Manage background images &amp; videos for the hero section</p>
      </div>
    </div>

    <CCard class="mb-4 shadow-sm">
      <CCardBody>
        <div class="d-flex gap-3 align-items-center flex-wrap mb-3">
          <div class="btn-group">
            <CButton
              :color="mediaType === 'image' ? 'primary' : 'outline-primary'"
              @click="onTypeChange('image')"
            >
              <CIcon icon="cil-image" class="me-1" />Image
            </CButton>
            <CButton
              :color="mediaType === 'video' ? 'primary' : 'outline-primary'"
              @click="onTypeChange('video')"
            >
              <CIcon icon="cil-video" class="me-1" />Video
            </CButton>
          </div>
        </div>

        <CRow :gutter="{ xs: 16 }">
          <CCol :sm="mediaType === 'image' ? 6 : 8">
            <div v-if="mediaType === 'image'">
              <label class="form-label fw-semibold">Upload Image</label>
              <CFormInput type="file" accept="image/*" @change="onFileSelect" />
            </div>
            <div v-else>
              <label class="form-label fw-semibold">Video URL (YouTube / Vimeo / MP4)</label>
              <CFormInput
                v-model="videoUrl"
                placeholder="https://www.youtube.com/watch?v=... or https://example.com/video.mp4"
              />
              <small class="text-body-secondary">Paste a YouTube, Vimeo, or direct MP4 video URL</small>
            </div>
          </CCol>
          <CCol :sm="3">
            <label class="form-label fw-semibold">Sort Order</label>
            <CFormInput v-model.number="sortOrder" type="number" min="0" />
          </CCol>
          <CCol :sm="3">
            <label class="form-label fw-semibold">Alt Text</label>
            <CFormInput v-model="altText" placeholder="Description" />
          </CCol>
        </CRow>

        <div v-if="previewUrl" class="mt-3">
          <img :src="previewUrl" class="rounded" style="max-width: 200px; max-height: 120px; object-fit: cover;" />
        </div>

        <div class="mt-3 d-flex gap-2">
          <CButton color="primary" :disabled="!canUpload || uploading" @click="upload">
            <CSpinner v-if="uploading" size="sm" class="me-1" />
            {{ mediaType === 'video' ? 'Add Video' : 'Upload Image' }}
          </CButton>
          <CButton v-if="selectedFile || videoUrl" color="secondary" variant="outline" size="sm" @click="clearSelection">
            <CIcon icon="cil-x" class="me-1" />Clear
          </CButton>
        </div>
      </CCardBody>
    </CCard>

    <div v-if="loading" class="text-center py-5"><CSpinner /></div>

    <div v-else-if="!images.length" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-image" size="3xl" class="mb-3" />
      <h4>No hero media yet</h4>
      <p>Upload an image or add a video above to get started</p>
    </div>

    <CRow v-else>
      <CCol v-for="item in images" :key="item.id" sm="6" md="4" lg="3" class="mb-4">
        <CCard class="shadow-sm h-100">
          <div class="position-relative hero-preview">
            <div v-if="item.media_type === 'video'" class="hero-video-preview">
              <CIcon icon="cil-video" size="3xl" class="text-primary" />
              <small class="text-body-secondary mt-1 d-block">Video</small>
            </div>
            <img
              v-else
              :src="thumbImageUrl(item)"
              class="w-100 rounded-top"
              style="height: 180px; object-fit: cover;"
              :alt="item.alt_text || ''"
            />
            <CBadge :color="item.media_type === 'video' ? 'info' : 'success'" class="position-absolute top-0 end-0 m-2">
              {{ item.media_type }}
            </CBadge>
          </div>
          <CCardBody>
            <small class="text-body-secondary d-block mb-1">
              Order: {{ item.sort_order }}
              <span v-if="item.alt_text" class="ms-1">| {{ item.alt_text }}</span>
            </small>
            <small v-if="item.media_type === 'video' && item.video_url" class="text-body-secondary d-block text-truncate mb-2" :title="item.video_url">
              {{ item.video_url }}
            </small>
            <CButton color="danger" variant="ghost" size="sm" @click="remove(item.id)">
              <CIcon icon="cil-trash" /> Delete
            </CButton>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>
  </div>
</template>

<style scoped>
.hero-preview {
  height: 180px;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--cui-tertiary-bg);
}
.hero-video-preview {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  width: 100%;
}
</style>
