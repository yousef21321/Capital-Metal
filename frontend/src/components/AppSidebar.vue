<script setup>
import { RouterLink } from 'vue-router'

import { AppSidebarNav } from '@/components/AppSidebarNav.js'
import { useSidebarStore } from '@/stores/sidebar.js'

const sidebar = useSidebarStore()
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
            <img src="@/assets/images/logo.png" alt="FLFL Design" class="sidebar-logo" />
          </span>
          <span class="sidebar-brand-narrow">
            <img src="@/assets/images/logo.png" alt="FLFL Design" class="sidebar-logo-narrow" />
          </span>
        </CSidebarBrand>
      </RouterLink>
      <CCloseButton class="d-lg-none" dark @click="sidebar.toggleVisible()" />
    </CSidebarHeader>
    <AppSidebarNav />
    <CSidebarFooter class="border-top d-none d-lg-flex sidebar-footer-modern">
      <CSidebarToggler @click="sidebar.toggleUnfoldable()" class="sidebar-toggler-modern" />
    </CSidebarFooter>
  </CSidebar>
</template>
