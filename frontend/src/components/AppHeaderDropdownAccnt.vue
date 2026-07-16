<script setup>
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { computed } from 'vue'

const authStore = useAuthStore()
const router = useRouter()

const avatarUrl = computed(() => {
  if (!authStore.user?.avatar) return null
  return authStore.user.avatar.startsWith('http')
    ? authStore.user.avatar
    : `/storage/${authStore.user.avatar}`
})

async function handleLogout() {
  await authStore.logout()
  router.push('/pages/login')
}
</script>

<template>
  <CDropdown placement="bottom-end" variant="nav-item">
    <CDropdownToggle class="py-0 pe-0" :caret="false">
      <CAvatar v-if="avatarUrl" :src="avatarUrl" size="md" class="user-avatar" />
      <CAvatar v-else color="primary" text-color="white" size="md" class="user-avatar">
        {{ authStore.userName?.charAt(0)?.toUpperCase() || 'U' }}
      </CAvatar>
    </CDropdownToggle>
    <CDropdownMenu class="pt-0 account-dropdown" style="min-width: 240px">
      <CDropdownHeader
        component="h6"
        class="bg-body-secondary text-body-secondary fw-semibold mb-2 rounded-top account-header"
      >
        <div class="d-flex align-items-center gap-2">
          <CAvatar v-if="avatarUrl" :src="avatarUrl" size="sm" />
          <CAvatar v-else color="primary" text-color="white" size="sm">
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
      <CDropdownItem @click="router.push('/profile')" style="cursor: pointer" class="dropdown-item-custom">
        <CIcon icon="cil-user" class="dropdown-item-icon" />{{ $t('account.profile') }}
      </CDropdownItem>
      <CDropdownItem @click="router.push('/settings')" style="cursor: pointer" class="dropdown-item-custom">
        <CIcon icon="cil-settings" class="dropdown-item-icon" />{{ $t('account.settings') }}
      </CDropdownItem>
      <CDropdownDivider class="my-1" />
      <CDropdownItem @click="handleLogout" style="cursor: pointer" class="dropdown-item-custom logout-item">
        <CIcon icon="cil-lock-locked" class="dropdown-item-icon" />{{ $t('account.logout') }}
      </CDropdownItem>
    </CDropdownMenu>
  </CDropdown>
</template>
