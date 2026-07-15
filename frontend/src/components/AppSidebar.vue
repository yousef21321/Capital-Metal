<script setup>
import { computed } from 'vue'
import { RouterLink } from 'vue-router'
import { useColorModes } from '@coreui/vue'

import { AppSidebarNav } from '@/components/AppSidebarNav.js'
import { useSidebarStore } from '@/stores/sidebar.js'
import logoLight from '@/assets/images/logo.webp'
import logoDark from '@/assets/images/logodark.webp'

const sidebar = useSidebarStore()
const { colorMode } = useColorModes('coreui-free-vue-admin-template-theme')
const logoSrc = computed(() => colorMode.value === 'dark' ? logoDark : logoLight)
</script>

<template>
  <CSidebar
    class="modern-sidebar"
    colorScheme="dark"
    position="fixed"
    :unfoldable="sidebar.unfoldable"
    :visible="sidebar.visible"
    @visible-change="(value) => sidebar.toggleVisible(value)"
  >
    <CSidebarHeader class="border-bottom sidebar-header-modern">
      <RouterLink custom to="/" v-slot="{ href, navigate }">
        <CSidebarBrand v-bind="$attrs" as="a" :href="href" @click="navigate" class="text-decoration-none">
          <span class="sidebar-brand-full d-flex align-items-center gap-2">
            <img :src="logoSrc" alt="FLFL Design" class="sidebar-logo" width="85" height="47" />
          </span>
          <span class="sidebar-brand-narrow">
            <img :src="logoSrc" alt="FLFL Design" class="sidebar-logo-narrow" width="46" height="24" />
          </span>
        </CSidebarBrand>
      </RouterLink>
      <CCloseButton class="d-lg-none" dark @click="sidebar.toggleVisible()" />
    </CSidebarHeader>
    <AppSidebarNav />
    <CSidebarFooter class="border-top d-none d-lg-flex sidebar-footer-modern">
      <CSidebarToggler @click="sidebar.toggleUnfoldable()" class="sidebar-toggler-modern" aria-label="Toggle sidebar" />
    </CSidebarFooter>
  </CSidebar>
</template>
