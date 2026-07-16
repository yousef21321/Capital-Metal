<script setup>
import { ref, onMounted } from 'vue'
import api from '@/api'
import { useToastStore } from '@/stores/toast'
import { formatPrice } from '@/utils/price'

const toast = useToastStore()
const coupons = ref([])
const loading = ref(true)
const modalVisible = ref(false)
const saving = ref(false)
const editing = ref(false)
const form = ref(emptyForm())

function emptyForm() {
  return {
    code: '',
    discount_type: 'percentage',
    discount_value: 0,
    min_order_amount: '',
    expiry_date: '',
    usage_limit: '',
  }
}

async function fetchCoupons() {
  loading.value = true
  try {
    const { data } = await api.get('/api/coupons')
    coupons.value = data
  } catch (e) {
    toast.error('Failed to load coupons.')
  } finally {
    loading.value = false
  }
}

function openCreate() {
  form.value = emptyForm()
  editing.value = false
  modalVisible.value = true
}

function openEdit(coupon) {
  form.value = {
    code: coupon.code,
    discount_type: coupon.discount_type,
    discount_value: coupon.discount_value,
    min_order_amount: coupon.min_order_amount || '',
    expiry_date: coupon.expiry_date ? coupon.expiry_date.slice(0, 10) : '',
    usage_limit: coupon.usage_limit || '',
  }
  editing.value = coupon.id
  modalVisible.value = true
}

async function save() {
  saving.value = true
  try {
    const payload = { ...form.value }
    if (!payload.min_order_amount) delete payload.min_order_amount
    if (!payload.expiry_date) delete payload.expiry_date
    if (!payload.usage_limit) delete payload.usage_limit
    payload.code = payload.code.toUpperCase()
    if (editing.value) {
      await api.put(`/api/coupons/${editing.value}`, payload)
      toast.success('Coupon updated.')
    } else {
      await api.post('/api/coupons', payload)
      toast.success('Coupon created.')
    }
    modalVisible.value = false
    await fetchCoupons()
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to save coupon.')
  } finally {
    saving.value = false
  }
}

async function remove(coupon) {
  if (!confirm(`Delete coupon "${coupon.code}"?`)) return
  try {
    await api.delete(`/api/coupons/${coupon.id}`)
    toast.success('Coupon deleted.')
    await fetchCoupons()
  } catch (e) {
    toast.error('Failed to delete coupon.')
  }
}

function formatDate(date) {
  if (!date) return '—'
  return new Date(date).toLocaleDateString()
}

onMounted(fetchCoupons)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">Coupons</h3>
        <p class="text-body-secondary mb-0">Manage discount coupons.</p>
      </div>
      <CButton color="primary" @click="openCreate">
        <CIcon icon="cil-plus" class="me-1" /> Add Coupon
      </CButton>
    </div>

    <div v-if="loading" class="text-center py-5"><CSpinner /></div>

    <div v-else-if="!coupons.length" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-tag" size="3xl" class="mb-3" />
      <h4>No coupons yet</h4>
      <CButton color="primary" @click="openCreate">Create your first coupon</CButton>
    </div>

    <CCard v-else class="shadow-sm">
      <CTable hover responsive align="middle">
        <CTableHead>
          <CTableRow>
            <CTableHeaderCell>Code</CTableHeaderCell>
            <CTableHeaderCell>Type</CTableHeaderCell>
            <CTableHeaderCell>Value</CTableHeaderCell>
            <CTableHeaderCell>Min Order</CTableHeaderCell>
            <CTableHeaderCell>Expires</CTableHeaderCell>
            <CTableHeaderCell>Used</CTableHeaderCell>
            <CTableHeaderCell>Limit</CTableHeaderCell>
            <CTableHeaderCell class="text-end">Actions</CTableHeaderCell>
          </CTableRow>
        </CTableHead>
        <CTableBody>
          <CTableRow v-for="c in coupons" :key="c.id">
            <CTableDataCell class="fw-semibold">{{ c.code }}</CTableDataCell>
            <CTableDataCell>
              <CBadge :color="c.discount_type === 'percentage' ? 'info' : 'success'">
                {{ c.discount_type === 'percentage' ? '%' : 'Fixed' }}
              </CBadge>
            </CTableDataCell>
            <CTableDataCell>
              {{ c.discount_type === 'percentage' ? c.discount_value + '%' : formatPrice(c.discount_value) }}
            </CTableDataCell>
            <CTableDataCell>{{ c.min_order_amount ? formatPrice(c.min_order_amount) : '—' }}</CTableDataCell>
            <CTableDataCell>{{ formatDate(c.expiry_date) }}</CTableDataCell>
            <CTableDataCell>{{ c.used_count || 0 }}</CTableDataCell>
            <CTableDataCell>{{ c.usage_limit || '∞' }}</CTableDataCell>
            <CTableDataCell class="text-end">
              <CButton color="warning" variant="ghost" size="sm" class="me-1" @click="openEdit(c)">
                <CIcon icon="cil-pencil" /> Edit
              </CButton>
              <CButton color="danger" variant="ghost" size="sm" @click="remove(c)">
                <CIcon icon="cil-trash" /> Delete
              </CButton>
            </CTableDataCell>
          </CTableRow>
        </CTableBody>
      </CTable>
    </CCard>

    <CModal :visible="modalVisible" @close="modalVisible = false" backdrop="static">
      <CModalHeader>
        <CModalTitle>{{ editing ? 'Edit Coupon' : 'Add Coupon' }}</CModalTitle>
      </CModalHeader>
      <CModalBody>
        <CRow>
          <CCol :sm="12" class="mb-3">
            <CFormLabel class="fw-semibold">Code</CFormLabel>
            <CFormInput v-model="form.code" placeholder="e.g. SUMMER20" @input="form.code = form.code.toUpperCase()" />
          </CCol>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold">Discount Type</CFormLabel>
            <CFormSelect v-model="form.discount_type">
              <option value="percentage">Percentage (%)</option>
              <option value="fixed">Fixed (EGP)</option>
            </CFormSelect>
          </CCol>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold">Value</CFormLabel>
            <CFormInput v-model.number="form.discount_value" type="number" min="0" step="0.01" />
          </CCol>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold">Min Order Amount (optional)</CFormLabel>
            <CFormInput v-model.number="form.min_order_amount" type="number" min="0" step="0.01" placeholder="0" />
          </CCol>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold">Expiry Date (optional)</CFormLabel>
            <CFormInput v-model="form.expiry_date" type="date" />
          </CCol>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold">Usage Limit (optional)</CFormLabel>
            <CFormInput v-model.number="form.usage_limit" type="number" min="1" placeholder="Unlimited" />
          </CCol>
        </CRow>
      </CModalBody>
      <CModalFooter>
        <CButton color="secondary" variant="outline" @click="modalVisible = false">Cancel</CButton>
        <CButton color="primary" :disabled="saving || !form.code || !form.discount_value" @click="save">
          <CSpinner v-if="saving" size="sm" class="me-1" /> {{ editing ? 'Update' : 'Create' }}
        </CButton>
      </CModalFooter>
    </CModal>
  </div>
</template>
