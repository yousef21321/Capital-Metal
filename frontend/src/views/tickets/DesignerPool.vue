<script setup>
import { ref, onMounted } from 'vue'
import api from '@/api'

const designers = ref([])
const loading = ref(true)
const error = ref('')
const addEmail = ref('')
const adding = ref(false)

async function fetchDesigners() {
  loading.value = true
  try {
    const { data } = await api.get('/api/industor/designers')
    designers.value = data
  } catch (e) {
    error.value = 'Failed to load designers.'
  } finally {
    loading.value = false
  }
}

async function addDesigner() {
  adding.value = true
  error.value = ''
  try {
    const { data: user } = await api.get('/api/industor/designers/by-email', { params: { email: addEmail.value } })
    if (user.in_pool) {
      error.value = 'This designer is already in your pool.'
      return
    }
    await api.post('/api/industor/designers', { designer_id: user.id })
    addEmail.value = ''
    await fetchDesigners()
  } catch (e) {
    error.value = e.response?.data?.message || 'Could not add designer.'
  } finally {
    adding.value = false
  }
}

async function removeDesigner(id) {
  try {
    await api.delete(`/api/industor/designers/${id}`)
    await fetchDesigners()
  } catch (e) {
    error.value = 'Could not remove designer.'
  }
}

onMounted(fetchDesigners)
</script>

<template>
  <div>
    <h3 class="mb-1">My Designers</h3>
    <p class="text-body-secondary mb-4">Manage the designers available for your ticket assignments.</p>

    <CAlert v-if="error" color="danger" class="mb-3">{{ error }}</CAlert>

    <CCard class="mb-4 shadow-sm">
      <CCardBody>
        <label class="form-label small fw-semibold">Add designer by email</label>
        <CInputGroup>
          <CInputGroupText><CIcon icon="cil-envelope" /></CInputGroupText>
          <CFormInput v-model="addEmail" type="email" placeholder="designer@example.com" @keyup.enter="addDesigner" />
          <CButton color="primary" :disabled="adding || !addEmail" @click="addDesigner">
            <CSpinner v-if="adding" size="sm" /> Add
          </CButton>
        </CInputGroup>
        <div class="form-text">The user must have the designer role.</div>
      </CCardBody>
    </CCard>

    <div v-if="loading" class="text-center py-5"><CSpinner /></div>

    <CCard v-else class="shadow-sm">
      <CCardBody>
        <div v-if="!designers.length" class="text-center text-body-secondary py-4">
          <CIcon icon="cil-people" size="3xl" class="mb-2" />
          <p>No designers yet. Add one above.</p>
        </div>
        <CListGroup v-else>
          <CListGroupItem v-for="d in designers" :key="d.id" class="d-flex justify-content-between align-items-center">
            <div>
              <strong>{{ d.name }}</strong>
              <span class="text-body-secondary ms-2 small">{{ d.email }}</span>
            </div>
            <CButton color="danger" variant="ghost" size="sm" @click="removeDesigner(d.id)">
              <CIcon icon="cil-trash" />
            </CButton>
          </CListGroupItem>
        </CListGroup>
      </CCardBody>
    </CCard>
  </div>
</template>
