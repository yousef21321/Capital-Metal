<script setup>
import { ref, onMounted } from 'vue'
import api from '@/api'
import { useToastStore } from '@/stores/toast'

const toast = useToastStore()
const orders = ref([])
const loading = ref(true)
const detailOrder = ref(null)
const detailVisible = ref(false)
const statusUpdating = ref(null)
const exporting = ref(false)
const applyLoading = ref(false)

const search = ref('')
const dateFrom = ref('')
const dateTo = ref('')

const orderPhone = (order) => order.address?.phone || order.user?.phone || order.guest_phone || '—'
const orderPayment = (order) => order.payments?.[0]?.payment_method?.name || 'N/A'
const orderProducts = (order) => (order.items || []).map((i) => i.product?.name || i.variant?.name || 'Product').join(', ')
const orderQty = (order) => (order.items || []).reduce((sum, i) => sum + (Number(i.quantity) || 0), 0)
const orderTypes = (order) => {
  const types = [...new Set((order.items || []).map((i) => i.product?.product_type).filter(Boolean))]
  return types.length ? types.join(', ') : '—'
}
const orderAddress = (order) => {
  const a = order.address
  const line = a?.address_line || order.guest_address_line || ''
  const city = a?.city || order.guest_city || ''
  const gov = a?.governorate || order.guest_governorate || ''
  return [line, city, gov].filter(Boolean).join('، ')
}

const statusColors = {
  pending: 'warning',
  under_review: 'info',
  confirmed: 'primary',
  processing: 'info',
  shipped: 'secondary',
  delivered: 'success',
  cancelled: 'danger',
}

const paymentColors = {
  paid: 'success',
  pending: 'warning',
  failed: 'danger',
  refunded: 'info',
}

async function fetchOrders() {
  loading.value = true
  try {
    const params = {
      search: search.value || undefined,
      date_from: dateFrom.value || undefined,
      date_to: dateTo.value || undefined,
    }
    const { data } = await api.get('/api/orders', { params })
    orders.value = data.data || []
  } catch (e) {
    toast.error('Failed to load orders.')
  } finally {
    loading.value = false
  }
}

async function applyFilters() {
  applyLoading.value = true
  try {
    await fetchOrders()
  } finally {
    applyLoading.value = false
  }
}

function resetFilters() {
  search.value = ''
  dateFrom.value = ''
  dateTo.value = ''
  fetchOrders()
}

async function exportExcel() {
  exporting.value = true
  try {
    const { data } = await api.get('/api/orders/export', {
      params: {
        search: search.value || undefined,
        date_from: dateFrom.value || undefined,
        date_to: dateTo.value || undefined,
      },
      responseType: 'blob',
    })
    const url = URL.createObjectURL(data)
    const a = document.createElement('a')
    a.href = url
    a.download = `orders_${new Date().toISOString().slice(0, 10)}.xlsx`
    document.body.appendChild(a)
    a.click()
    a.remove()
    URL.revokeObjectURL(url)
    toast.success('Excel file downloaded.')
  } catch (e) {
    toast.error('Failed to export orders.')
  } finally {
    exporting.value = false
  }
}

function openDetail(order) {
  detailOrder.value = order
  detailVisible.value = true
}

async function remove(order) {
  if (!confirm(`Delete order #${order.order_number}? This cannot be undone.`)) return
  try {
    await api.delete(`/api/orders/${order.id}`)
    toast.success('Order deleted.')
    if (detailOrder.value?.id === order.id) detailVisible.value = false
    await fetchOrders()
  } catch (e) {
    toast.error('Failed to delete order.')
  }
}

async function updateStatus(order, field, value) {
  statusUpdating.value = order.id
  try {
    const payload = {}
    if (field === 'order_status') payload.order_status = value
    if (field === 'payment_status') payload.payment_status = value
    await api.put(`/api/orders/${order.id}/status`, payload)
    toast.success('Status updated.')
    order[field] = value
    if (detailOrder.value?.id === order.id) detailOrder.value[field] = value
  } catch (e) {
    toast.error('Failed to update status.')
  } finally {
    statusUpdating.value = null
  }
}

const orderStatuses = ['pending', 'under_review', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled']
const paymentStatuses = ['pending', 'paid', 'failed', 'refunded']

onMounted(fetchOrders)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-3">
      <div>
        <h3 class="mb-1">Orders</h3>
        <p class="text-body-secondary mb-0">Manage all orders.</p>
      </div>
      <CButton color="success" :disabled="exporting" @click="exportExcel">
        <CIcon icon="cil-cloud-download" class="me-1" />
        {{ exporting ? 'Exporting...' : 'Export to Excel' }}
      </CButton>
    </div>

    <CCard class="shadow-sm mb-3">
      <CCardBody>
        <CRow class="g-3 align-items-end">
          <CCol :sm="12" :md="4">
            <CFormLabel class="small fw-semibold">Customer Name</CFormLabel>
            <CFormInput
              v-model="search"
              type="text"
              placeholder="Search by customer name or order #..."
              @keyup.enter="applyFilters"
            />
          </CCol>
          <CCol :sm="6" :md="3">
            <CFormLabel class="small fw-semibold">From Date</CFormLabel>
            <CFormInput v-model="dateFrom" type="date" />
          </CCol>
          <CCol :sm="6" :md="3">
            <CFormLabel class="small fw-semibold">To Date</CFormLabel>
            <CFormInput v-model="dateTo" type="date" />
          </CCol>
          <CCol :sm="12" :md="2" class="d-flex gap-2">
            <CButton color="primary" class="flex-grow-1" :disabled="applyLoading" @click="applyFilters">
              <CIcon icon="cil-filter" class="me-1" /> Filter
            </CButton>
            <CButton color="secondary" @click="resetFilters">
              <CIcon icon="cil-reload" />
            </CButton>
          </CCol>
        </CRow>
      </CCardBody>
    </CCard>

    <div v-if="loading" class="text-center py-5"><CSpinner /></div>

    <div v-else-if="!orders.length" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-cart" size="3xl" class="mb-3" />
      <h4>No orders yet</h4>
    </div>

    <CCard v-else class="shadow-sm">
      <div class="table-responsive">
        <CTable hover responsive align="middle">
          <CTableHead>
            <CTableRow>
              <CTableHeaderCell>Order #</CTableHeaderCell>
              <CTableHeaderCell>Customer</CTableHeaderCell>
              <CTableHeaderCell>Phone</CTableHeaderCell>
              <CTableHeaderCell>Address</CTableHeaderCell>
              <CTableHeaderCell>Payment</CTableHeaderCell>
              <CTableHeaderCell>Product</CTableHeaderCell>
              <CTableHeaderCell>Type</CTableHeaderCell>
              <CTableHeaderCell>Qty</CTableHeaderCell>
              <CTableHeaderCell>Date</CTableHeaderCell>
              <CTableHeaderCell>Total</CTableHeaderCell>
              <CTableHeaderCell>Status</CTableHeaderCell>
              <CTableHeaderCell>Payment Status</CTableHeaderCell>
              <CTableHeaderCell class="text-end">Actions</CTableHeaderCell>
            </CTableRow>
          </CTableHead>
          <CTableBody>
            <CTableRow v-for="order in orders" :key="order.id">
              <CTableDataCell class="fw-semibold">#{{ order.order_number }}</CTableDataCell>
              <CTableDataCell>
                {{ order.user?.name || order.guest_name || '—' }}
              </CTableDataCell>
              <CTableDataCell dir="ltr">{{ orderPhone(order) }}</CTableDataCell>
              <CTableDataCell>{{ orderAddress(order) }}</CTableDataCell>
              <CTableDataCell>{{ orderPayment(order) }}</CTableDataCell>
              <CTableDataCell>{{ orderProducts(order) }}</CTableDataCell>
              <CTableDataCell>{{ orderTypes(order) }}</CTableDataCell>
              <CTableDataCell>{{ orderQty(order) }}</CTableDataCell>
              <CTableDataCell>{{ new Date(order.created_at).toLocaleDateString() }}</CTableDataCell>
              <CTableDataCell>{{ order.total_amount }} {{ order.currency }}</CTableDataCell>
              <CTableDataCell>
                <CBadge :color="statusColors[order.order_status] || 'light'" class="text-uppercase">
                  {{ order.order_status }}
                </CBadge>
              </CTableDataCell>
              <CTableDataCell>
                <CBadge :color="paymentColors[order.payment_status] || 'light'" class="text-uppercase">
                  {{ order.payment_status }}
                </CBadge>
              </CTableDataCell>
              <CTableDataCell class="text-end">
                <CButton color="info" variant="ghost" size="sm" class="me-1" @click="openDetail(order)">
                  <CIcon icon="cil-zoom-in" /> Details
                </CButton>
                <CButton color="danger" variant="ghost" size="sm" @click="remove(order)">
                  <CIcon icon="cil-trash" /> Delete
                </CButton>
              </CTableDataCell>
            </CTableRow>
          </CTableBody>
        </CTable>
      </div>
    </CCard>

    <CModal :visible="detailVisible" @close="detailVisible = false" size="lg" scrollable>
      <CModalHeader>
        <CModalTitle>Order #{{ detailOrder?.order_number }}</CModalTitle>
      </CModalHeader>
      <CModalBody v-if="detailOrder">
        <CRow class="mb-3">
          <CCol :sm="6">
            <span class="text-body-secondary d-block small">Customer</span>
            <strong>{{ detailOrder.user?.name || detailOrder.guest_name || '—' }}</strong>
            <div v-if="detailOrder.user?.email" class="small">{{ detailOrder.user.email }}</div>
            <div v-if="detailOrder.guest_phone" class="small">{{ detailOrder.guest_phone }}</div>
          </CCol>
          <CCol :sm="6">
            <span class="text-body-secondary d-block small">Date</span>
            <strong>{{ new Date(detailOrder.created_at).toLocaleString() }}</strong>
          </CCol>
        </CRow>
        <hr />
        <h4 class="fs-6">Items</h4>
        <div v-for="item in detailOrder.items" :key="item.id" class="d-flex justify-content-between align-items-center mb-2">
          <span>{{ item.product?.name || 'Product' }} <CBadge v-if="item.variant" color="warning" size="sm">{{ item.variant.name }}</CBadge> <small class="text-body-secondary">x{{ item.quantity }}</small></span>
          <span>{{ item.price }} {{ detailOrder.currency }}</span>
        </div>
        <hr />
        <CRow>
          <CCol :sm="4">
            <span class="text-body-secondary d-block small">Subtotal</span>
            <strong>{{ detailOrder.subtotal }} {{ detailOrder.currency }}</strong>
          </CCol>
          <CCol :sm="4">
            <span class="text-body-secondary d-block small">Shipping</span>
            <strong>{{ detailOrder.shipping_cost }} {{ detailOrder.currency }}</strong>
          </CCol>
          <CCol :sm="4">
            <span class="text-body-secondary d-block small">Total</span>
            <strong>{{ detailOrder.total_amount }} {{ detailOrder.currency }}</strong>
          </CCol>
        </CRow>
        <div v-if="detailOrder.discount > 0" class="mt-2">
          <span class="text-body-secondary small">Discount:</span>
          <span class="text-success ms-1">-{{ detailOrder.discount }} {{ detailOrder.currency }}</span>
        </div>
        <hr />
        <CRow>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold small">Order Status</CFormLabel>
            <CFormSelect
              :value="detailOrder.order_status"
              :disabled="statusUpdating === detailOrder.id"
              @change="updateStatus(detailOrder, 'order_status', $event.target.value)"
            >
              <option v-for="s in orderStatuses" :key="s" :value="s">{{ s }}</option>
            </CFormSelect>
          </CCol>
          <CCol :sm="6" class="mb-3">
            <CFormLabel class="fw-semibold small">Payment Status</CFormLabel>
            <CFormSelect
              :value="detailOrder.payment_status"
              :disabled="statusUpdating === detailOrder.id"
              @change="updateStatus(detailOrder, 'payment_status', $event.target.value)"
            >
              <option v-for="s in paymentStatuses" :key="s" :value="s">{{ s }}</option>
            </CFormSelect>
          </CCol>
        </CRow>
        <div v-if="detailOrder.notes" class="mt-3">
          <span class="text-body-secondary d-block small">Notes</span>
          <p class="mb-0">{{ detailOrder.notes }}</p>
        </div>
        <div v-if="detailOrder.guest_address_line" class="mt-3">
          <span class="text-body-secondary d-block small">Shipping Address</span>
          <p class="mb-0">
            {{ detailOrder.guest_address_line }},
            {{ detailOrder.guest_city }},
            {{ detailOrder.guest_governorate }}
          </p>
        </div>
      </CModalBody>
      <CModalFooter>
        <CButton color="danger" :disabled="!detailOrder" @click="remove(detailOrder)">
          <CIcon icon="cil-trash" class="me-1" /> Delete Order
        </CButton>
        <CButton color="secondary" @click="detailVisible = false">Close</CButton>
      </CModalFooter>
    </CModal>
  </div>
</template>
