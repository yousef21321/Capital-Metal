<script setup>
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()
const router = useRouter()

async function handleLogout() {
  await authStore.logout()
  router.push('/pages/login')
}
</script>

<template>
  <CDropdown placement="bottom-end" variant="nav-item">
    <CDropdownToggle class="py-0 pe-0" :caret="false">
      <CAvatar color="primary" text-color="white" size="md" class="user-avatar">
        {{ authStore.userName?.charAt(0)?.toUpperCase() || 'U' }}
      </CAvatar>
    </CDropdownToggle>
    <CDropdownMenu class="pt-0 account-dropdown" style="min-width: 240px">
      <CDropdownHeader
        component="h6"
        class="bg-body-secondary text-body-secondary fw-semibold mb-2 rounded-top account-header"
      >
        <div class="d-flex align-items-center gap-2">
          <CAvatar color="primary" text-color="white" size="sm">
            {{ authStore.userName?.charAt(0)?.toUpperCase() || 'U' }}
          </CAvatar>
          <div>
            <div class="fw-bold text-body">{{ authStore.userName || 'Account' }}</div>
            <small class="text-body-secondary">{{ authStore.userEmail }}</small>
          </div>
        </div>
        <div class="mt-2">
          <CBadge v-if="authStore.userRole" color="primary" class="text-uppercase role-badge">
            {{ authStore.userRole }}
          </CBadge>
        </div>
      </CDropdownHeader>
      <CDropdownItem class="dropdown-item-custom">
        <CIcon icon="cil-user" class="dropdown-item-icon" />Profile
      </CDropdownItem>
      <CDropdownItem class="dropdown-item-custom">
        <CIcon icon="cil-settings" class="dropdown-item-icon" />Settings
      </CDropdownItem>
      <CDropdownDivider class="my-1" />
      <CDropdownItem @click="handleLogout" style="cursor: pointer" class="dropdown-item-custom logout-item">
        <CIcon icon="cil-lock-locked" class="dropdown-item-icon" />Logout
      </CDropdownItem>
    </CDropdownMenu>
  </CDropdown>
</template>
