<script setup>
import { ref, onMounted } from 'vue'
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
const selected = ref({})

const permissions = nav.map((item) => ({
  key: item.name,
  label: item.name,
  translationKey: item.translationKey,
}))

async function fetchRoles() {
  loading.value = true
  error.value = ''
  try {
    const { data } = await api.get('/api/admin/roles')
    roles.value = Array.isArray(data) ? data : (data.data || [])
    const map = {}
    roles.value.forEach((role) => {
      map[role.id] = new Set(Array.isArray(role.permissions) ? role.permissions : [])
    })
    selected.value = map
  } catch (e) {
    error.value = e.response?.data?.message || 'Failed to load roles.'
  } finally {
    loading.value = false
  }
}

function isChecked(roleId, perm) {
  return selected.value[roleId]?.has(perm) || false
}

function toggle(roleId, perm, checked) {
  if (!selected.value[roleId]) selected.value[roleId] = new Set()
  if (checked) selected.value[roleId].add(perm)
  else selected.value[roleId].delete(perm)
}

async function save() {
  saving.value = true
  error.value = ''
  try {
    await Promise.all(
      roles.value.map((role) =>
        api.put(`/api/admin/roles/${role.id}/permissions`, {
          permissions: [...(selected.value[role.id] || [])],
        })
      )
    )
    toast.success('Permissions updated.')
    await fetchRoles()
  } catch (e) {
    toast.error(e.response?.data?.message || 'Failed to save permissions.')
  } finally {
    saving.value = false
  }
}

onMounted(fetchRoles)
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h3 class="mb-1">Role Permissions</h3>
        <p class="text-body-secondary mb-0">Assign header permissions to any role.</p>
      </div>
      <CButton color="primary" :disabled="saving || loading" @click="save">
        <CSpinner v-if="saving" size="sm" class="me-1" /> Save Changes
      </CButton>
    </div>

    <CAlert v-if="error" color="danger" class="mb-3">{{ error }}</CAlert>

    <div v-if="loading" class="text-center py-5"><CSpinner /></div>

    <CCard v-else class="shadow-sm">
      <CCardBody class="p-0">
        <CTable hover responsive align="middle" class="mb-0">
          <CTableHead>
            <CTableRow>
              <CTableHeaderCell>Permission</CTableHeaderCell>
              <CTableHeaderCell v-for="role in roles" :key="role.id" class="text-center">
                {{ role.display_name || role.name }}
              </CTableHeaderCell>
            </CTableRow>
          </CTableHead>
          <CTableBody>
            <CTableRow v-for="perm in permissions" :key="perm.key">
              <CTableDataCell class="fw-semibold">
                {{ $t(perm.translationKey || perm.key) }}
              </CTableDataCell>
              <CTableDataCell v-for="role in roles" :key="role.id" class="text-center">
                <CFormCheck
                  :checked="isChecked(role.id, perm.key)"
                  @change="toggle(role.id, perm.key, $event.target.checked)"
                />
              </CTableDataCell>
            </CTableRow>
          </CTableBody>
        </CTable>
      </CCardBody>
    </CCard>
  </div>
</template>
" filePath">
/home/ubuntu/Capital-Metal/frontend/src/views/pages/RolePermissions.vue