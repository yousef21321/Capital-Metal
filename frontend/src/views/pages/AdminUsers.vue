<script setup>
import { ref, onMounted } from 'vue'
import api from '@/api'
import { useAuthStore } from '@/stores/auth'
import { useToastStore } from '@/stores/toast'

const toast = useToastStore()
const auth = useAuthStore()
const authUserId = ref(auth.user?.id ?? null)
const users = ref([])
const loading = ref(true)
const error = ref('')
const search = ref('')
const roleFilter = ref('')
const modalVisible = ref(false)
const saving = ref(false)
const editingId = ref(null)
const passwordModal = ref(false)
const resetUser = ref(null)
const resetSaving = ref(false)

const roles = [
  { name: 'user', label: 'User' },
  { name: 'industor', label: 'Industor' },
  { name: 'designer', label: 'Designer' },
  { name: 'tester', label: 'Tester' },
  { name: 'admin', label: 'Admin' },
]

const form = ref(emptyForm())

function emptyForm() {
  return {
    name: '',
    email: '',
    password: '',
    password_confirmation: '',
    phone: '',
    role: 'user',
    is_active: true,
  }
}

async function fetchUsers() {
  loading.value = true
  error.value = ''
  try {
    const params = {}
    if (search.value) params.search = search.value
    if (roleFilter.value) params.role = roleFilter.value
    const { data } = await api.get('/api/admin/users', { params })
    users.value = data.data || []
  } catch (e) {
    error.value = e.response?.data?.message || 'Failed to load users.'
  } finally {
    loading.value = false
  }
}

function openCreate() {
  form.value = emptyForm()
  editingId.value = null
  modalVisible.value = true
}

function openEdit(user) {
  form.value = {
    name: user.name,
    email: user.email,
    password: '',
    password_confirmation: '',
    phone: user.phone || '',
    role: user.role?.name || 'user',
    is_active: !!user.is_active,
  }
  editingId.value = user.id
  modalVisible.value = true
}

async function save() {
  saving.value = true
  error.value = ''
  try {
    if (editingId.value) {
      const payload = {
        name: form.value.name,
        email: form.value.email,
        phone: form.value.phone,
        role: form.value.role,
        is_active: form.value.is_active,
      }
      await api.put(`/api/admin/users/${editingId.value}`, payload)
      toast.success('User updated.')
    } else {
      await api.post('/api/admin/users', form.value)
      toast.success('User created.')
    }
    modalVisible.value = false
    await fetchUsers()
  } catch (e) {
    toast.error(e.response?.data?.message || e.response?.data?.errors?.email?.[0] || 'Failed to save user.')
  } finally {
    saving.value = false
  }
}

function openPassword(user) {
  resetUser.value = user
  passwordModal.value = true
}

async function resetPassword() {
  if (!resetUser.value) return
  resetSaving.value = true
  error.value = ''
  try {
    await api.put(`/api/admin/users/${resetUser.value.id}/password`, {
      password: form.value.password,
      password_confirmation: form.value.password_confirmation,
    })
    toast.success('Password reset.')
    passwordModal.value = false
    form.value.password = ''
    form.value.password_confirmation = ''
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to reset password.')
  } finally {
    resetSaving.value = false
  }
}

const roleBadge = (name) => {
  const map = {
    admin: 'danger',
    industri: 'primary',
    industor: 'primary',
    designer: 'info',
    tester: 'warning',
    user: 'secondary',
  }
  return map[name] || 'secondary'
}

async function toggleActive(u) {
  const action = u.is_active ? 'deactivate' : 'activate'
  if (!confirm(`${action === 'deactivate' ? 'Deactivate' : 'Activate'} user "${u.name}"?`)) return
  error.value = ''
  try {
    await api.put(`/api/admin/users/${u.id}`, {
      name: u.name,
      email: u.email,
      is_active: !u.is_active,
    })
    toast.success(u.is_active ? 'User deactivated.' : 'User activated.')
    u.is_active = !u.is_active
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to update user status.')
  }
}

async function loginAs(u) {
  if (!confirm(`Login as "${u.name}" (${u.email})?`)) return
  error.value = ''
  try {
    const user = await auth.impersonate(u)
    toast.success(`Logged in as ${user.name}.`)
    window.location.href = '/dashboard'
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to login as user.')
  }
}

function formatDate(date) {
  if (!date) return '—'
  return new Date(date).toLocaleDateString()
}

onMounted(fetchUsers)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">{{ $t('admin_users.title') }}</h3>
        <p class="text-body-secondary mb-0">{{ $t('admin_users.desc') }}</p>
      </div>
      <CButton color="primary" @click="openCreate">
        <CIcon icon="cil-user-plus" class="me-1" /> {{ $t('admin_users.add_user') }}
      </CButton>
    </div>

    <CAlert v-if="error" color="danger" class="mb-3">{{ error }}</CAlert>

    <CCard class="shadow-sm mb-4">
      <CCardBody>
        <div class="d-flex flex-wrap gap-2">
          <CInputGroup style="max-width: 280px">
            <CInputGroupText><CIcon icon="cil-search" /></CInputGroupText>
            <CFormInput v-model="search" :placeholder="$t('admin_users.search')" @input="fetchUsers" />
          </CInputGroup>
          <CFormSelect v-model="roleFilter" style="max-width: 180px" @change="fetchUsers">
            <option value="">{{ $t('admin_users.all_roles') }}</option>
            <option v-for="r in roles" :key="r.name" :value="r.name">{{ r.label }}</option>
          </CFormSelect>
        </div>
      </CCardBody>
    </CCard>

    <div v-if="loading" class="text-center py-5"><CSpinner /></div>

    <div v-else-if="!users.length" class="text-center py-5 text-body-secondary">
      <CIcon icon="cil-user" size="3xl" class="mb-3" />
      <h4>{{ $t('admin_users.empty') }}</h4>
      <CButton color="primary" @click="openCreate">{{ $t('admin_users.add_user') }}</CButton>
    </div>

    <CCard v-else class="shadow-sm">
      <CTable hover responsive align="middle">
        <CTableHead>
          <CTableRow>
            <CTableHeaderCell>{{ $t('admin_users.name') }}</CTableHeaderCell>
            <CTableHeaderCell>Email</CTableHeaderCell>
            <CTableHeaderCell>Phone</CTableHeaderCell>
            <CTableHeaderCell>{{ $t('admin_users.role') }}</CTableHeaderCell>
            <CTableHeaderCell>{{ $t('admin_users.status') }}</CTableHeaderCell>
            <CTableHeaderCell>{{ $t('admin_users.joined') }}</CTableHeaderCell>
            <CTableHeaderCell class="text-end">{{ $t('admin_users.actions') }}</CTableHeaderCell>
          </CTableRow>
        </CTableHead>
        <CTableBody>
          <CTableRow v-for="u in users" :key="u.id">
            <CTableDataCell class="fw-semibold">{{ u.name }}</CTableDataCell>
            <CTableDataCell>{{ u.email }}</CTableDataCell>
            <CTableDataCell>{{ u.phone || '—' }}</CTableDataCell>
            <CTableDataCell>
              <CBadge :color="roleBadge(u.role?.name)">{{ u.role?.display_name || u.role?.name }}</CBadge>
            </CTableDataCell>
            <CTableDataCell>
              <CFormSwitch
                :checked="u.is_active"
                :disabled="u.id === authUserId"
                color="success"
                :label="u.is_active ? $t('admin_users.active') : $t('admin_users.inactive')"
                @change="toggleActive(u)"
              />
            </CTableDataCell>
            <CTableDataCell>{{ formatDate(u.created_at) }}</CTableDataCell>
            <CTableDataCell class="text-end">
              <CButton color="warning" variant="ghost" size="sm" class="me-1" @click="openEdit(u)">
                <CIcon icon="cil-pencil" /> {{ $t('admin_users.edit') }}
              </CButton>
              <CButton color="danger" variant="ghost" size="sm" @click="openPassword(u)">
                <CIcon icon="cil-lock-locked" /> {{ $t('admin_users.reset_password') }}
              </CButton>
              <CButton
                color="success"
                variant="ghost"
                size="sm"
                :disabled="u.id === authUserId || !u.is_active"
                @click="loginAs(u)"
              >
                <CIcon icon="cil-account-login" /> {{ $t('admin_users.login_as') }}
              </CButton>
            </CTableDataCell>
          </CTableRow>
        </CTableBody>
      </CTable>
    </CCard>

    <CModal :visible="modalVisible" @close="modalVisible = false" backdrop="static">
      <CModalHeader>
        <CModalTitle>{{ editingId ? $t('admin_users.edit_title') : $t('admin_users.add_title') }}</CModalTitle>
      </CModalHeader>
      <CModalBody>
        <div class="mb-3">
          <CFormLabel class="fw-semibold">{{ $t('admin_users.name') }}</CFormLabel>
          <CFormInput v-model="form.name" />
        </div>
        <div class="mb-3">
          <CFormLabel class="fw-semibold">Email</CFormLabel>
          <CFormInput v-model="form.email" type="email" />
        </div>
        <div class="mb-3">
          <CFormLabel class="fw-semibold">Phone</CFormLabel>
          <CFormInput v-model="form.phone" />
        </div>
        <div class="mb-3">
          <CFormLabel class="fw-semibold">{{ $t('admin_users.role') }}</CFormLabel>
          <CFormSelect v-model="form.role">
            <option v-for="r in roles" :key="r.name" :value="r.name">{{ r.label }}</option>
          </CFormSelect>
        </div>
        <template v-if="!editingId">
          <div class="mb-3">
            <CFormLabel class="fw-semibold">{{ $t('admin_users.password') }}</CFormLabel>
            <CFormInput v-model="form.password" type="password" autocomplete="new-password" />
          </div>
          <div class="mb-3">
            <CFormLabel class="fw-semibold">{{ $t('admin_users.confirm_password') }}</CFormLabel>
            <CFormInput v-model="form.password_confirmation" type="password" autocomplete="new-password" />
          </div>
        </template>
        <div class="mb-3">
          <CFormCheck v-model="form.is_active" :label="$t('admin_users.active_account')" />
        </div>
      </CModalBody>
      <CModalFooter>
        <CButton color="secondary" variant="outline" @click="modalVisible = false">{{ $t('admin_users.cancel') }}</CButton>
        <CButton color="primary" :disabled="saving || !form.name || !form.email" @click="save">
          <CSpinner v-if="saving" size="sm" class="me-1" /> {{ editingId ? $t('admin_users.save') : $t('admin_users.create') }}
        </CButton>
      </CModalFooter>
    </CModal>

    <CModal :visible="passwordModal" @close="passwordModal = false" backdrop="static">
      <CModalHeader>
        <CModalTitle>{{ $t('admin_users.reset_title') }}</CModalTitle>
      </CModalHeader>
      <CModalBody>
        <p class="text-body-secondary mb-3">
          {{ $t('admin_users.reset_desc') }} <strong>{{ resetUser?.name }} ({{ resetUser?.email }})</strong>
        </p>
        <div class="mb-3">
          <CFormLabel class="fw-semibold">{{ $t('admin_users.new_password') }}</CFormLabel>
          <CFormInput v-model="form.password" type="password" autocomplete="new-password" />
        </div>
        <div class="mb-3">
          <CFormLabel class="fw-semibold">{{ $t('admin_users.confirm_password') }}</CFormLabel>
          <CFormInput v-model="form.password_confirmation" type="password" autocomplete="new-password" />
        </div>
      </CModalBody>
      <CModalFooter>
        <CButton color="secondary" variant="outline" @click="passwordModal = false">{{ $t('admin_users.cancel') }}</CButton>
        <CButton color="danger" :disabled="resetSaving || !form.password" @click="resetPassword">
          <CSpinner v-if="resetSaving" size="sm" class="me-1" /> {{ $t('admin_users.reset_password') }}
        </CButton>
      </CModalFooter>
    </CModal>
  </div>
</template>
