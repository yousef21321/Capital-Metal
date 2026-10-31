<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/api'
import { useAuthStore } from '@/stores/auth'
import { useToastStore } from '@/stores/toast'
import nav from '@/_nav.js'

const auth = useAuthStore()
const toast = useToastStore()

const loading = ref(true)
const saving = ref(false)
const error = ref('')
const roles = ref([])
const selectedRoleId = ref(null)
const permissions = ref([])

const selectedPermissions = ref(new Set())

const selectedRole = computed(() => roles.value.find((r) => r.id === selectedRoleId.value) || null)

const permissionCount = (role) => (Array.isArray(role?.permissions) ? role.permissions.length : 0)

async function fetchRoles() {
  loading.value = true
  error.value = ''
  try {
    const { data } = await api.get('/api/admin/roles')
    roles.value = Array.isArray(data) ? data : (data.data || [])
    if (!selectedRoleId.value && roles.value.length) {
      selectedRoleId.value = roles.value[0].id
    }
    syncSelected()
  } catch (e) {
    error.value = e.response?.data?.message || 'Failed to load roles.'
  } finally {
    loading.value = false
  }
}

function syncSelected() {
  const role = selectedRole.value
  selectedPermissions.value = new Set(Array.isArray(role?.permissions) ? role.permissions : [])
}

function selectRole(id) {
  selectedRoleId.value = id
  syncSelected()
}

function isChecked(perm) {
  return selectedPermissions.value.has(perm)
}

function toggle(perm, checked) {
  if (checked) selectedPermissions.value.add(perm)
  else selectedPermissions.value.delete(perm)
}

async function save() {
  if (!selectedRole.value) return
  saving.value = true
  error.value = ''
  try {
    await api.put(`/api/admin/roles/${selectedRole.value.id}/permissions`, {
      permissions: [...selectedPermissions.value],
    })
    selectedRole.value.permissions = [...selectedPermissions.value]
    toast.success('Permissions updated.')
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to save permissions.')
  } finally {
    saving.value = false
  }
}

onMounted(async () => {
  permissions.value = nav.map((item) => ({
    key: item.name,
    label: item.name,
    translationKey: item.translationKey,
  }))
  await fetchRoles()
})
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">Role Permissions</h3>
        <p class="text-body-secondary mb-0">Select a role, then choose its header permissions.</p>
      </div>
      <CButton color="primary" :disabled="saving || loading || !selectedRole" @click="save">
        <CSpinner v-if="saving" size="sm" class="me-1" /> Save Changes
      </CButton>
    </div>

    <CAlert v-if="error" color="danger" class="mb-3">{{ error }}</CAlert>

    <div v-if="loading" class="text-center py-5"><CSpinner /></div>

    <CRow v-else>
      <CCol md="4" class="mb-3">
        <CCard class="shadow-sm h-100">
          <CCardHeader class="fw-semibold">Roles</CCardHeader>
          <CListGroup flush>
            <CListGroupItem
              v-for="role in roles"
              :key="role.id"
              :active="role.id === selectedRoleId"
              class="d-flex justify-content-between align-items-center role-item"
              @click="selectRole(role.id)"
            >
              <span class="fw-semibold">{{ role.display_name || role.name }}</span>
              <CBadge color="primary" shape="rounded-pill">{{ permissionCount(role) }}</CBadge>
            </CListGroupItem>
          </CListGroup>
        </CCard>
      </CCol>

      <CCol md="8" class="mb-3">
        <CCard class="shadow-sm h-100">
          <CCardHeader class="d-flex justify-content-between align-items-center">
            <span class="fw-semibold">
              Permissions for {{ selectedRole?.display_name || selectedRole?.name || '—' }}
            </span>
            <small class="text-body-secondary">{{ selectedPermissions.size }} selected</small>
          </CCardHeader>
          <CCardBody style="max-height: 60vh; overflow-y: auto">
            <div v-for="perm in permissions" :key="perm.key" class="permission-row d-flex align-items-center justify-content-between py-2 border-bottom">
              <div>
                <div class="fw-semibold">{{ $t(perm.translationKey || perm.key) }}</div>
                <small class="text-body-secondary">{{ perm.key }}</small>
              </div>
              <CFormCheck
                :checked="isChecked(perm.key)"
                @change="toggle(perm.key, $event.target.checked)"
              />
            </div>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>
  </div>
</template>

<style scoped>
.role-item {
  cursor: pointer;
}
.permission-row:last-child {
  border-bottom: 0 !important;
}
</style>
" filePath">
/home/ubuntu/Cairo-Metal/frontend/src/views/pages/RolePermissions.vue