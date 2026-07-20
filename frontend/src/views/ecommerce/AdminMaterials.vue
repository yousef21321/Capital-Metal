<script setup>
import { ref, onMounted } from 'vue'
import api from '@/api'
import { useToastStore } from '@/stores/toast'

const toast = useToastStore()
const materials = ref([])
const manufacturingMethods = ref([])
const loading = ref(true)

const newMaterial = ref({ name: '', slug: '' })
const editingMaterial = ref(null)
const selectedMethods = ref([])

const newMethod = ref({ name: '', slug: '' })
const editingMethod = ref(null)

async function fetchMaterials() {
  loading.value = true
  try {
    const { data } = await api.get('/api/materials')
    materials.value = data
  } catch (_) {
    toast.error('Failed to load materials.')
  } finally {
    loading.value = false
  }
}

async function fetchManufacturingMethods() {
  try {
    const { data } = await api.get('/api/manufacturing-methods')
    manufacturingMethods.value = data
  } catch (_) {}
}

function slugify(value) {
  return value.toLowerCase().trim().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '')
}

function onMaterialNameInput(target) {
  target.slug = slugify(target.name)
}

async function addMaterial() {
  if (!newMaterial.value.name) return
  try {
    await api.post('/api/materials', { name: newMaterial.value.name, slug: newMaterial.value.slug })
    toast.success('Material added.')
    newMaterial.value = { name: '', slug: '' }
    await fetchMaterials()
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to add material.')
  }
}

async function updateMaterial(mat) {
  try {
    await api.put(`/api/materials/${mat.id}`, { name: mat.name })
    toast.success('Material updated.')
    editingMaterial.value = null
    await fetchMaterials()
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to update.')
  }
}

async function toggleMaterialActive(mat) {
  try {
    await api.put(`/api/materials/${mat.id}`, { is_active: !mat.is_active })
    await fetchMaterials()
  } catch (_) {}
}

async function deleteMaterial(id) {
  if (!confirm('Delete this material?')) return
  try {
    await api.delete(`/api/materials/${id}`)
    toast.success('Deleted.')
    await fetchMaterials()
  } catch (e) {
    toast.error('Failed to delete.')
  }
}

async function addMethod() {
  if (!newMethod.value.name) return
  try {
    await api.post('/api/manufacturing-methods', { name: newMethod.value.name, slug: newMethod.value.slug })
    toast.success('Manufacturing method added.')
    newMethod.value = { name: '', slug: '' }
    await fetchManufacturingMethods()
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to add method.')
  }
}

async function updateMethod(method) {
  try {
    await api.put(`/api/manufacturing-methods/${method.id}`, { name: method.name })
    toast.success('Method updated.')
    editingMethod.value = null
    await fetchManufacturingMethods()
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to update.')
  }
}

async function deleteMethod(id) {
  if (!confirm('Delete this manufacturing method?')) return
  try {
    await api.delete(`/api/manufacturing-methods/${id}`)
    toast.success('Deleted.')
    await fetchManufacturingMethods()
  } catch (e) {
    toast.error('Failed to delete.')
  }
}

async function loadMaterialMethods(mat) {
  editingMaterial.value = mat
  try {
    const { data } = await api.get(`/api/materials/${mat.slug}/manufacturing-methods`)
    selectedMethods.value = data.map(m => m.id)
  } catch (_) {
    selectedMethods.value = []
  }
}

async function toggleMethodForMaterial(methodId) {
  if (!editingMaterial.value) return
  const matId = editingMaterial.value.id
  try {
    if (selectedMethods.value.includes(methodId)) {
      await api.delete(`/api/materials/${matId}/detach-method/${methodId}`)
      selectedMethods.value = selectedMethods.value.filter(id => id !== methodId)
    } else {
      await api.post(`/api/materials/${matId}/attach-method`, { manufacturing_method_id: methodId })
      selectedMethods.value.push(methodId)
    }
  } catch (_) {}
}

onMounted(() => {
  fetchMaterials()
  fetchManufacturingMethods()
})
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">Materials & Manufacturing Methods</h3>
        <p class="text-body-secondary mb-0">Manage product materials and their available manufacturing methods</p>
      </div>
    </div>

    <CRow class="g-4">
      <!-- Materials -->
      <CCol lg="6">
        <CCard class="shadow-sm">
          <CCardHeader class="fw-semibold">
            <CIcon icon="cil-layers" class="me-2" />Materials
          </CCardHeader>
          <CCardBody>
            <div class="d-flex gap-2 mb-3">
              <CFormInput v-model="newMaterial.name" placeholder="Material name" @input="onMaterialNameInput(newMaterial)" @keydown.enter="addMaterial" />
              <CButton color="primary" :disabled="!newMaterial.name" @click="addMaterial">Add</CButton>
            </div>

            <div v-if="loading" class="text-center py-3"><CSpinner size="sm" /></div>

            <div v-else-if="!materials.length" class="text-center py-4 text-body-secondary">
              <p class="mb-0">No materials yet.</p>
            </div>

            <table v-else class="table table-hover mb-0">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Slug</th>
                  <th class="text-center">Active</th>
                  <th class="text-center">Methods</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="mat in materials" :key="mat.id">
                  <td>
                    <template v-if="editingMaterial?.id === mat.id">
                      <CFormInput v-model="editingMaterial.name" size="sm" @keydown.enter="updateMaterial(editingMaterial)" @keydown.escape="editingMaterial = null" />
                    </template>
                    <template v-else>
                      {{ mat.name }}
                    </template>
                  </td>
                  <td><code>{{ mat.slug }}</code></td>
                  <td class="text-center">
                    <CFormSwitch :model-value="mat.is_active" @change="toggleMaterialActive(mat)" />
                  </td>
                  <td class="text-center">
                    <CButton size="sm" color="info" variant="ghost" @click="loadMaterialMethods(mat)" :disabled="editingMaterial?.id === mat.id">
                      <CIcon icon="cil-settings" />
                    </CButton>
                  </td>
                  <td class="text-end">
                    <template v-if="editingMaterial?.id === mat.id">
                      <CButton size="sm" color="success" variant="ghost" @click="updateMaterial(editingMaterial)"><CIcon icon="cil-check" /></CButton>
                      <CButton size="sm" color="secondary" variant="ghost" @click="editingMaterial = null"><CIcon icon="cil-x" /></CButton>
                    </template>
                    <template v-else>
                      <CButton size="sm" color="primary" variant="ghost" @click="editingMaterial = { ...mat }"><CIcon icon="cil-pencil" /></CButton>
                      <CButton size="sm" color="danger" variant="ghost" @click="deleteMaterial(mat.id)"><CIcon icon="cil-trash" /></CButton>
                    </template>
                  </td>
                </tr>
              </tbody>
            </table>

            <!-- Assign manufacturing methods to material -->
            <div v-if="editingMaterial" class="mt-3 p-3 rounded" style="background: var(--cui-tertiary-bg, #f8f9fa);">
              <h6 class="fw-semibold mb-2">Manufacturing Methods for <strong>{{ editingMaterial.name }}</strong></h6>
              <div v-if="!manufacturingMethods.length" class="text-body-secondary small">No manufacturing methods available.</div>
              <div v-else class="d-flex flex-wrap gap-2">
                <CFormCheck
                  v-for="method in manufacturingMethods"
                  :key="method.id"
                  :label="method.name"
                  :model-value="selectedMethods.includes(method.id)"
                  @change="toggleMethodForMaterial(method.id)"
                />
              </div>
            </div>
          </CCardBody>
        </CCard>
      </CCol>

      <!-- Manufacturing Methods -->
      <CCol lg="6">
        <CCard class="shadow-sm">
          <CCardHeader class="fw-semibold">
            <CIcon icon="cil-settings" class="me-2" />Manufacturing Methods
          </CCardHeader>
          <CCardBody>
            <div class="d-flex gap-2 mb-3">
              <CFormInput v-model="newMethod.name" placeholder="Method name" @input="onMaterialNameInput(newMethod)" @keydown.enter="addMethod" />
              <CButton color="primary" :disabled="!newMethod.name" @click="addMethod">Add</CButton>
            </div>

            <div v-if="!manufacturingMethods.length" class="text-center py-4 text-body-secondary">
              <p class="mb-0">No manufacturing methods yet.</p>
            </div>

            <table v-else class="table table-hover mb-0">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Slug</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="method in manufacturingMethods" :key="method.id">
                  <td>
                    <template v-if="editingMethod?.id === method.id">
                      <CFormInput v-model="editingMethod.name" size="sm" @keydown.enter="updateMethod(editingMethod)" @keydown.escape="editingMethod = null" />
                    </template>
                    <template v-else>
                      {{ method.name }}
                    </template>
                  </td>
                  <td><code>{{ method.slug }}</code></td>
                  <td class="text-end">
                    <template v-if="editingMethod?.id === method.id">
                      <CButton size="sm" color="success" variant="ghost" @click="updateMethod(editingMethod)"><CIcon icon="cil-check" /></CButton>
                      <CButton size="sm" color="secondary" variant="ghost" @click="editingMethod = null"><CIcon icon="cil-x" /></CButton>
                    </template>
                    <template v-else>
                      <CButton size="sm" color="primary" variant="ghost" @click="editingMethod = { ...method }"><CIcon icon="cil-pencil" /></CButton>
                      <CButton size="sm" color="danger" variant="ghost" @click="deleteMethod(method.id)"><CIcon icon="cil-trash" /></CButton>
                    </template>
                  </td>
                </tr>
              </tbody>
            </table>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>
  </div>
</template>
