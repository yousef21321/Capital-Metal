<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/api'
import { useAuthStore } from '@/stores/auth'
import { useToastStore } from '@/stores/toast'

const router = useRouter()
const auth = useAuthStore()
const toast = useToastStore()
const cart = ref(null)
const addresses = ref([])
const loading = ref(true)
const submitting = ref(false)
const error = ref('')
const success = ref('')

const form = ref({
  address_id: null,
  currency: auth.userCurrency,
  shipping_cost: 50,
  notes: '',
  guest_name: '',
  guest_phone: '',
})

const couponCode = ref('')
const couponStatus = ref('idle')
const couponError = ref('')
const appliedCoupon = ref(null)

const showAddressForm = ref(false)
const savingAddress = ref(false)
const addressForm = ref(emptyAddressForm())

function emptyAddressForm() {
  return {
    full_name: '',
    phone: '',
    country: 'Egypt',
    governorate: '',
    city: '',
    address_line: '',
    postal_code: '',
    is_default: true,
  }
}

async function saveAddress() {
  savingAddress.value = true
  try {
    const { data } = await api.post('/api/addresses', addressForm.value)
    addresses.value.push(data)
    form.value.address_id = data.id
    showAddressForm.value = false
    addressForm.value = emptyAddressForm()
    toast.success('Address added successfully.')
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to add address.')
  } finally {
    savingAddress.value = false
  }
}

function toggleAddressForm() {
  showAddressForm.value = !showAddressForm.value
  if (!showAddressForm.value) {
    addressForm.value = emptyAddressForm()
  }
}

const currencySymbol = computed(() => (form.value.currency === 'EGP' ? 'EGP' : 'USD'))

async function loadData() {
  loading.value = true
  try {
    const requests = [api.get('/api/cart')]

    if (auth.isAuthenticated) {
      requests.push(api.get('/api/addresses'))
    }

    const [cartRes, addrRes] = await Promise.all(requests)
    cart.value = cartRes.data

    if (addrRes) {
      addresses.value = addrRes.data
      const defaultAddr = addrRes.data.find(a => a.is_default)
      if (defaultAddr) form.value.address_id = defaultAddr.id
    }
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

const subtotal = computed(() => {
  if (!cart.value?.items) return 0
  const currency = form.value.currency
  return cart.value.items.reduce((sum, item) => {
    const price = checkoutItemPrice(item, currency)
    return sum + price * item.quantity
  }, 0)
})

const checkoutItemPrice = (item, currency) => {
  if (currency === 'USD') {
    if (parseFloat(item.product?.price_usd) > 0) return parseFloat(item.product.price_usd)
    if (parseFloat(item.product?.price_egp) > 0) return parseFloat(item.product.price_egp) / (auth.exchangeRate || 30)
    return 0
  }
  return parseFloat(item.product?.price_egp || 0)
}

const shippingCost = computed(() => parseFloat(form.value.shipping_cost || 0))

const discount = computed(() => {
  if (!appliedCoupon.value) return 0
  if (appliedCoupon.value.discount_type === 'percentage') {
    return (subtotal.value * appliedCoupon.value.discount_value) / 100
  }
  return parseFloat(appliedCoupon.value.discount_value || 0)
})

const totalAmount = computed(() => {
  return Math.max(0, subtotal.value + shippingCost.value - discount.value)
})

const money = (value) => Number(value).toFixed(2)

async function applyCoupon() {
  couponError.value = ''
  if (!couponCode.value.trim()) {
    couponError.value = 'Enter a coupon code first.'
    return
  }

  couponStatus.value = 'verifying'
  try {
    const { data } = await api.post('/api/coupons/verify', {
      code: couponCode.value.trim(),
      order_total: subtotal.value,
    })
    appliedCoupon.value = {
      code: couponCode.value.trim().toUpperCase(),
      discount_type: data.coupon.discount_type,
      discount_value: parseFloat(data.coupon.discount_value),
      discount: parseFloat(data.discount),
    }
    couponStatus.value = 'applied'
  } catch (e) {
    couponStatus.value = 'error'
    couponError.value = e.response?.data?.message || 'Invalid coupon code.'
    appliedCoupon.value = null
  }
}

function removeCoupon() {
  appliedCoupon.value = null
  couponCode.value = ''
  couponStatus.value = 'idle'
  couponError.value = ''
}

async function placeOrder() {
  error.value = ''
  success.value = ''
  submitting.value = true
  try {
    const payload = {
      currency: form.value.currency,
      shipping_cost: form.value.shipping_cost,
      notes: form.value.notes,
      address_id: form.value.address_id || undefined,
      coupon_code: appliedCoupon.value?.code || undefined,
    }

    if (!auth.isAuthenticated) {
      payload.guest_name = form.value.guest_name
      payload.guest_phone = form.value.guest_phone
    }

    const { data } = await api.post('/api/checkout', payload)

    const orderId = data.id
    const orderNumber = data.order_number

    try {
      const payRes = await api.post('/api/paymob/intent', { order_id: orderId })

      if (payRes.data?.payment_url) {
        success.value = `Order #${orderNumber} created! Redirecting to payment...`
        window.location.href = payRes.data.payment_url
        return
      }

      if (payRes.data?.paid) {
        success.value = `Order #${orderNumber} paid successfully!`
        setTimeout(() => router.push('/orders'), 1500)
        return
      }

      throw new Error(payRes.data?.message || 'No payment URL returned.')
    } catch (payErr) {
      error.value = payErr.response?.data?.message
        || 'Payment could not be started. Your order was saved — you can pay it from the Orders page.'
      success.value = `Order #${orderNumber} created but payment is still pending.`
    }
  } catch (e) {
    error.value = e.response?.data?.message || 'Checkout failed. Please try again.'
  } finally {
    submitting.value = false
  }
}

onMounted(loadData)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">إتمام الشراء / Checkout</h3>
        <p class="text-body-secondary mb-0">جميع الأسعار بـ ({{ currencySymbol }}) — All prices in {{ currencySymbol }}.</p>
      </div>
      <CButton color="secondary" variant="outline" size="sm" router-link to="/cart">
        <CIcon icon="cil-arrow-left" class="me-1" /> العودة للسلة / Back to Cart
      </CButton>
    </div>

    <div v-if="loading" class="text-center py-5">
      <CSpinner />
    </div>

    <div v-else-if="!cart?.items?.length" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-basket" size="3xl" class="mb-3" />
      <h4>السلة فارغة / Your cart is empty</h4>
      <p class="mb-3">أضف منتجات قبل إتمام الشراء / Add products before checking out.</p>
      <CButton color="primary" router-link to="/products">تصفح المنتجات / Browse Products</CButton>
    </div>

    <CRow v-else :gutter="{ md: 24 }">
      <!-- Left column: shipping + notes -->
      <CCol :md="7">
        <!-- Guest name/phone fields -->
        <CCard v-if="!auth.isAuthenticated" class="mb-4 shadow-sm">
          <CCardHeader class="bg-body">
            <h5 class="mb-0 d-flex align-items-center gap-2">
              <CIcon icon="cil-user" /> معلوماتك / Your Information
            </h5>
          </CCardHeader>
          <CCardBody>
            <CRow>
              <CCol :sm="6" class="mb-3">
                <CFormLabel class="small fw-semibold">الاسم بالكامل / Full Name <span class="text-danger">*</span></CFormLabel>
                <CFormInput v-model="form.guest_name" placeholder="Your full name" />
              </CCol>
              <CCol :sm="6" class="mb-3">
                <CFormLabel class="small fw-semibold">رقم التليفون / Phone Number <span class="text-danger">*</span></CFormLabel>
                <CFormInput v-model="form.guest_phone" placeholder="Phone number" />
              </CCol>
            </CRow>
            <p class="text-body-secondary small mb-0">
              <CIcon icon="cil-info" class="me-1" />
              سيتم حفظ بياناتك مع الطلب. يمكنك إنشاء حساب لتتبع طلباتك لاحقاً.
              Your details will be saved with the order. You can create an account to track your orders later.
            </p>
          </CCardBody>
        </CCard>

        <CCard class="mb-4 shadow-sm">
          <CCardHeader class="bg-body">
            <h5 class="mb-0 d-flex align-items-center gap-2">
              <CIcon icon="cil-location-pin" /> عنوان الشحن / Shipping Address
            </h5>
          </CCardHeader>
          <CCardBody>
            <div v-if="!auth.isAuthenticated" class="text-body-secondary mb-3">
              <p class="mb-0 small">سيتم تأكيد العنوان لاحقاً / Address will be confirmed later.</p>
            </div>

            <div v-if="auth.isAuthenticated && !addresses.length && !showAddressForm" class="text-body-secondary">
              <p class="mb-2">لا توجد عناوين / No addresses found.</p>
              <CButton color="primary" variant="outline" size="sm" @click="toggleAddressForm">
                <CIcon icon="cil-plus" class="me-1" /> إضافة عنوان / Add Address
              </CButton>
            </div>

            <CFormRadioGroup
              v-if="auth.isAuthenticated && addresses.length"
              v-model="form.address_id"
              :options="addresses.map(a => ({
                label: `${a.full_name || 'Address'} - ${a.governorate}, ${a.city}`,
                value: a.id,
              }))"
            />

            <CButton
              v-if="auth.isAuthenticated && addresses.length && !showAddressForm"
              color="secondary" variant="outline" size="sm" class="mt-2"
              @click="toggleAddressForm"
            >
              <CIcon icon="cil-plus" class="me-1" /> Add another address
            </CButton>

            <CCollapse :visible="showAddressForm">
              <div class="border rounded p-3 mt-2 bg-body-secondary">
                <h6 class="mb-3">New Address</h6>
                <CRow>
                  <CCol :sm="6" class="mb-2">
                    <CFormLabel class="small">Full Name</CFormLabel>
                    <CFormInput v-model="addressForm.full_name" size="sm" placeholder="Recipient name" />
                  </CCol>
                  <CCol :sm="6" class="mb-2">
                    <CFormLabel class="small">Phone</CFormLabel>
                    <CFormInput v-model="addressForm.phone" size="sm" placeholder="Phone number" />
                  </CCol>
                  <CCol :sm="4" class="mb-2">
                    <CFormLabel class="small">Country</CFormLabel>
                    <CFormInput v-model="addressForm.country" size="sm" />
                  </CCol>
                  <CCol :sm="4" class="mb-2">
                    <CFormLabel class="small">Governorate</CFormLabel>
                    <CFormInput v-model="addressForm.governorate" size="sm" placeholder="e.g. Cairo" />
                  </CCol>
                  <CCol :sm="4" class="mb-2">
                    <CFormLabel class="small">City</CFormLabel>
                    <CFormInput v-model="addressForm.city" size="sm" placeholder="e.g. New Cairo" />
                  </CCol>
                  <CCol :sm="8" class="mb-2">
                    <CFormLabel class="small">Address Line</CFormLabel>
                    <CFormInput v-model="addressForm.address_line" size="sm" placeholder="Street, building, apartment" />
                  </CCol>
                  <CCol :sm="4" class="mb-2">
                    <CFormLabel class="small">Postal Code</CFormLabel>
                    <CFormInput v-model="addressForm.postal_code" size="sm" />
                  </CCol>
                </CRow>
                <div class="d-flex gap-2 mt-2">
                  <CButton color="primary" size="sm" :disabled="savingAddress || !addressForm.governorate || !addressForm.city" @click="saveAddress">
                    <CSpinner v-if="savingAddress" size="sm" class="me-1" /> Save Address
                  </CButton>
                  <CButton color="secondary" variant="outline" size="sm" @click="toggleAddressForm">Cancel</CButton>
                </div>
              </div>
            </CCollapse>
          </CCardBody>
        </CCard>

        <CCard class="mb-4 shadow-sm">
          <CCardHeader class="bg-body">
            <h5 class="mb-0 d-flex align-items-center gap-2">
              <CIcon icon="cil-notes" /> Order Notes
            </h5>
          </CCardHeader>
          <CCardBody>
            <CFormTextarea
              v-model="form.notes"
              rows="3"
              placeholder="Any special instructions for this order..."
            />
          </CCardBody>
        </CCard>
      </CCol>

      <!-- Right column: order summary -->
      <CCol :md="5">
        <CCard class="shadow-sm sticky-top" style="top: 20px;">
          <CCardHeader class="bg-body">
            <h5 class="mb-0 d-flex align-items-center gap-2">
              <CIcon icon="cil-cart" /> Order Summary
            </h5>
          </CCardHeader>
          <CCardBody>
            <!-- Items -->
            <div
              v-for="item in cart.items"
              :key="item.id"
              class="d-flex justify-content-between align-items-start mb-2 small"
            >
              <span class="me-2">
                {{ item.product?.name }}
                <span class="text-body-secondary">x{{ item.quantity }}</span>
              </span>
              <span class="text-nowrap">{{ money(checkoutItemPrice(item, form.currency)) }} {{ currencySymbol }}</span>
            </div>

            <hr class="my-3" />

            <!-- Totals -->
            <div class="d-flex justify-content-between mb-2">
              <span class="text-body-secondary">Subtotal</span>
              <span>{{ money(subtotal) }} {{ currencySymbol }}</span>
            </div>
            <div class="d-flex justify-content-between mb-2">
              <span class="text-body-secondary">الشحن / Shipping</span>
              <span>{{ money(shippingCost) }} {{ currencySymbol }}</span>
            </div>
            <div class="small text-success mb-2">
              <CIcon icon="cil-info" class="me-1" />شحن مجاني للطلبات فوق ١٠٠٠ {{ currencySymbol }} / Free shipping on orders over 1000 {{ currencySymbol }}
            </div>
            <div v-if="appliedCoupon" class="d-flex justify-content-between mb-2">
              <span class="text-success">
                <CIcon icon="cil-tag" class="me-1" /> Discount
              </span>
              <span class="text-success">- {{ money(discount) }} {{ currencySymbol }}</span>
            </div>

            <hr class="my-3" />

            <div class="d-flex justify-content-between align-items-center mb-3">
              <span class="fw-bold fs-5">Total</span>
              <span class="fw-bold fs-4 text-primary">{{ money(totalAmount) }} {{ currencySymbol }}</span>
            </div>

            <!-- Coupon -->
            <div class="mb-3">
              <label class="form-label small fw-semibold mb-2">Promo Code</label>
              <div v-if="!appliedCoupon">
                <CInputGroup>
                  <CInputGroupText>
                    <CIcon icon="cil-tag" />
                  </CInputGroupText>
                  <CFormInput
                    v-model="couponCode"
                    placeholder="Enter coupon code"
                    :disabled="couponStatus === 'verifying'"
                    @keyup.enter="applyCoupon"
                  />
                  <CButton
                    color="primary"
                    variant="outline"
                    :disabled="couponStatus === 'verifying' || !couponCode.trim()"
                    @click="applyCoupon"
                  >
                    <CSpinner v-if="couponStatus === 'verifying'" size="sm" />
                    <template v-else>Apply</template>
                  </CButton>
                </CInputGroup>
                <div v-if="couponError" class="text-danger small mt-2">{{ couponError }}</div>
              </div>
              <div v-else class="d-flex align-items-center justify-content-between border rounded px-3 py-2 bg-success-subtle">
                <span class="small">
                  <CIcon icon="cil-check-circle" class="me-1 text-success" />
                  <strong>{{ appliedCoupon.code }}</strong> applied
                </span>
                <CButton color="danger" variant="ghost" size="sm" @click="removeCoupon">
                  <CIcon icon="cil-x" />
                </CButton>
              </div>
            </div>

            <CAlert v-if="error" color="danger" class="mb-3">{{ error }}</CAlert>
            <CAlert v-if="success" color="success" class="mb-3">{{ success }}</CAlert>

            <CButton
              color="primary"
              class="w-100"
              size="lg"
              :disabled="submitting || (!auth.isAuthenticated && (!form.guest_name || !form.guest_phone))"
              @click="placeOrder"
            >
              <CSpinner v-if="submitting" size="sm" class="me-2" />
              تأكيد الطلب / Place Order
            </CButton>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>
  </div>
</template>
