<script setup>
import { onMounted, ref } from 'vue'
import { useColorModes } from '@coreui/vue'
import { RouterLink } from 'vue-router'

import AppBreadcrumb from '@/components/AppBreadcrumb.vue'
import AppHeaderDropdownAccnt from '@/components/AppHeaderDropdownAccnt.vue'
import { useSidebarStore } from '@/stores/sidebar.js'
import { useCartStore } from '@/stores/cart'

const headerClassNames = ref('mb-4 p-0')
const { colorMode, setColorMode } = useColorModes('coreui-free-vue-admin-template-theme')
const sidebar = useSidebarStore()
const cart = useCartStore()

onMounted(() => {
  document.addEventListener('scroll', () => {
    if (document.documentElement.scrollTop > 0) {
      headerClassNames.value = 'mb-4 p-0 shadow-sm'
    } else {
      headerClassNames.value = 'mb-4 p-0'
    }
  })
})
</script>

<template>
  <CHeader position="sticky" :class="['modern-header', headerClassNames]">
    <CContainer class="border-bottom px-4" fluid>
      <CHeaderToggler @click="sidebar.toggleVisible()" style="margin-inline-start: -14px">
        <CIcon icon="cil-menu" size="lg" />
      </CHeaderToggler>
      <div class="header-brand d-flex align-items-center gap-2 ms-2">
        <CIcon icon="cil-industry" size="xl" class="brand-icon" />
        <span class="brand-text fw-bold fs-5">FLFL_Design</span>
      </div>
      <CHeaderNav class="ms-auto">
        <CNavItem>
          <RouterLink custom to="/cart" v-slot="{ href, navigate }">
            <CNavLink :href="href" @click="navigate" class="position-relative">
              <CIcon icon="cil-basket" size="lg" />
              <CBadge
                v-if="cart.count > 0"
                color="danger"
                shape="pill"
                class="position-absolute top-0 start-100 translate-middle"
                style="font-size: 0.65rem"
              >
                {{ cart.count }}
              </CBadge>
            </CNavLink>
          </RouterLink>
        </CNavItem>
        <CNavItem>
          <RouterLink custom to="/tickets" v-slot="{ href, navigate }">
            <CNavLink :href="href" @click="navigate">
              <CIcon icon="cil-description" size="lg" />
            </CNavLink>
          </RouterLink>
        </CNavItem>
        <CNavItem>
          <RouterLink custom to="/notifications" v-slot="{ href, navigate }">
            <CNavLink :href="href" @click="navigate" class="position-relative">
              <CIcon icon="cil-bell" size="lg" />
              <CBadge
                color="info"
                shape="pill"
                class="position-absolute top-0 start-100 translate-middle"
                style="font-size: 0.65rem"
              >
                3
              </CBadge>
            </CNavLink>
          </RouterLink>
        </CNavItem>
      </CHeaderNav>
      <CHeaderNav>
        <li class="nav-item py-1">
          <div class="vr h-100 mx-2 text-body text-opacity-25"></div>
        </li>
        <CDropdown variant="nav-item" placement="bottom-end">
          <CDropdownToggle :caret="false">
            <CIcon v-if="colorMode === 'dark'" icon="cil-moon" size="lg" />
            <CIcon v-else-if="colorMode === 'light'" icon="cil-sun" size="lg" />
            <CIcon v-else icon="cil-contrast" size="lg" />
          </CDropdownToggle>
          <CDropdownMenu>
            <CDropdownItem
              :active="colorMode === 'light'"
              class="d-flex align-items-center"
              component="button"
              type="button"
              @click="setColorMode('light')"
            >
              <CIcon class="me-2" icon="cil-sun" size="lg" /> Light
            </CDropdownItem>
            <CDropdownItem
              :active="colorMode === 'dark'"
              class="d-flex align-items-center"
              component="button"
              type="button"
              @click="setColorMode('dark')"
            >
              <CIcon class="me-2" icon="cil-moon" size="lg" /> Dark
            </CDropdownItem>
            <CDropdownItem
              :active="colorMode === 'auto'"
              class="d-flex align-items-center"
              component="button"
              type="button"
              @click="setColorMode('auto')"
            >
              <CIcon class="me-2" icon="cil-contrast" size="lg" /> Auto
            </CDropdownItem>
          </CDropdownMenu>
        </CDropdown>
        <li class="nav-item py-1">
          <div class="vr h-100 mx-2 text-body text-opacity-25"></div>
        </li>
        <AppHeaderDropdownAccnt />
      </CHeaderNav>
    </CContainer>
    <CContainer class="px-4" fluid>
      <AppBreadcrumb />
    </CContainer>
  </CHeader>
</template>
