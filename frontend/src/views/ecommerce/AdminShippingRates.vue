<script setup>
import { ref, onMounted } from 'vue'
import api from '@/api'
import { useToastStore } from '@/stores/toast'

const toast = useToastStore()
const rates = ref([])
const loading = ref(true)
const saving = ref(false)

const editingRate = ref(null)
const newRate = ref({ region: '', governorate: '', cost: 0 })

const regions = [
  'Cairo, Giza & Outskirts',
  'Alexandria',
  'Delta',
  'Canal',
  'Upper Egypt 1',
  'Upper Egypt 2',
  'Red Sea',
  'Remote Areas',
]

async function fetchRates() {
  loading.value = true
  try {
    const { data } = await api.get('/api/shipping-rates')
    rates.value = data
  } catch (_) {
    toast.error('Failed to load shipping rates.')
  } finally {
    loading.value = false
  }
}

async function addRate() {
  if (!newRate.value.region || !newRate.value.governorate || newRate.value.cost < 0) return
  saving.value = true
  try {
    await api.post('/api/shipping-rates', newRate.value)
    toast.success('Shipping rate added.')
    newRate.value = { region: '', governorate: '', cost: 0 }
    fetchRates()
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to add rate.')
  } finally {
    saving.value = false
  }
}

function startEdit(rate) {
  editingRate.value = { ...rate }
}

function cancelEdit() {
  editingRate.value = null
}

async function saveEdit() {
  if (!editingRate.value) return
  saving.value = true
  try {
    await api.put(`/api/shipping-rates/${editingRate.value.id}`, {
      region: editingRate.value.region,
      cost: editingRate.value.cost,
    })
    toast.success('Shipping rate updated.')
    editingRate.value = null
    fetchRates()
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to update rate.')
  } finally {
    saving.value = false
  }
}

async function deleteRate(id) {
  if (!confirm('Delete this shipping rate?')) return
  try {
    await api.delete(`/api/shipping-rates/${id}`)
    toast.success('Shipping rate deleted.')
    fetchRates()
  } catch (_) {
    toast.error('Failed to delete rate.')
  }
}

onMounted(fetchRates)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">Manage Shipping Rates</h3>
        <p class="text-body-secondary mb-0">Set shipping prices per governorate. Prices auto-apply at checkout.</p>
      </div>
    </div>

    <CCard class="shadow-sm mb-4">
      <CCardHeader class="bg-body">
        <h5 class="mb-0">Add New Rate</h5>
      </CCardHeader>
      <CCardBody>
        <CRow class="g-3" aligns="end">
          <CCol :md="3">
            <CFormLabel class="small fw-semibold">Region</CFormLabel>
            <CFormSelect v-model="newRate.region">
              <option value="">-- Select Region --</option>
              <option v-for="r in regions" :key="r" :value="r">{{ r }}</option>
            </CFormSelect>
          </CCol>
          <CCol :md="3">
            <CFormLabel class="small fw-semibold">Governorate</CFormLabel>
            <CFormInput v-model="newRate.governorate" placeholder="e.g. Cairo" />
          </CCol>
          <CCol :md="2">
            <CFormLabel class="small fw-semibold">Cost (EGP)</CFormLabel>
            <CFormInput v-model.number="newRate.cost" type="number" min="0" />
          </CCol>
          <CCol :md="2">
            <CButton color="primary" :disabled="saving || !newRate.region || !newRate.governorate" @click="addRate">
              <CSpinner v-if="saving" size="sm" class="me-1" />
              Add Rate
            </CButton>
          </CCol>
        </CRow>
      </CCardBody>
    </CCard>

    <CCard class="shadow-sm">
      <CCardHeader class="bg-body d-flex justify-content-between align-items-center">
        <h5 class="mb-0">Current Rates</h5>
        <CBadge color="primary">{{ rates.length }} rates</CBadge>
      </CCardHeader>
      <CCardBody>
        <div v-if="loading" class="text-center py-4">
          <CSpinner />
        </div>
        <div v-else-if="!rates.length" class="text-center py-4 text-body-secondary">
          <p class="mb-0">No shipping rates configured yet.</p>
        </div>
        <CTable v-else hover>
          <CTableHead>
            <CTableRow>
              <CTableHeaderCell>Region</CTableHeaderCell>
              <CTableHeaderCell>Governorate</CTableHeaderCell>
              <CTableHeaderCell>Cost (EGP)</CTableHeaderCell>
              <CTableHeaderCell class="text-end">Actions</CTableHeaderCell>
            </CTableRow>
          </CTableHead>
          <CTableBody>
            <CTableRow v-for="rate in rates" :key="rate.id">
              <CTableDataCell>
                <CBadge color="secondary" class="me-1">{{ rate.region }}</CBadge>
              </CTableDataCell>
              <CTableDataCell>
                <template v-if="editingRate?.id === rate.id">
                  <CFormSelect v-model="editingRate.region" size="sm">
                    <option v-for="r in regions" :key="r" :value="r">{{ r }}</option>
                  </CFormSelect>
                </template>
                <template v-else>{{ rate.governorate }}</template>
              </CTableDataCell>
              <CTableDataCell>
                <template v-if="editingRate?.id === rate.id">
                  <CFormInput v-model.number="editingRate.cost" type="number" min="0" size="sm" style="width: 100px;" />
                </template>
                <template v-else>
                  <strong>{{ rate.cost }} EGP</strong>
                </template>
              </CTableDataCell>
              <CTableDataCell class="text-end">
                <template v-if="editingRate?.id === rate.id">
                  <CButton color="success" variant="ghost" size="sm" @click="saveEdit" :disabled="saving">
                    <CIcon icon="cil-check" />
                  </CButton>
                  <CButton color="secondary" variant="ghost" size="sm" @click="cancelEdit">
                    <CIcon icon="cil-x" />
                  </CButton>
                </template>
                <template v-else>
                  <CButton color="primary" variant="ghost" size="sm" @click="startEdit(rate)">
                    <CIcon icon="cil-pencil" />
                  </CButton>
                  <CButton color="danger" variant="ghost" size="sm" @click="deleteRate(rate.id)">
                    <CIcon icon="cil-trash" />
                  </CButton>
                </template>
              </CTableDataCell>
            </CTableRow>
          </CTableBody>
        </CTable>
      </CCardBody>
    </CCard>
  </div>
</template>
