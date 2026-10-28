<script setup>
import { computed, onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import logoLight from '@/assets/images/logo-small.webp'
import logoDark from '@/assets/images/logodark-small.webp'
import { RouterLink, useRoute } from 'vue-router'

import AppBreadcrumb from '@/components/AppBreadcrumb.vue'
import AppHeaderDropdownAccnt from '@/components/AppHeaderDropdownAccnt.vue'
import { useSidebarStore } from '@/stores/sidebar.js'
import { useCartStore } from '@/stores/cart'
import { useAuthStore } from '@/stores/auth'
import { useNotificationStore } from '@/stores/notifications'
import { useThemeStore } from '@/stores/theme.js'
import api from '@/api'
import nav from '@/_nav.js'

function timeAgo(date) {
  const diff = Date.now() - new Date(date).getTime()
  const mins = Math.floor(diff / 60000)
  if (mins < 1) return 'just now'
  if (mins < 60) return `${mins}m ago`
  const hours = Math.floor(mins / 60)
  if (hours < 24) return `${hours}h ago`
  const days = Math.floor(hours / 24)
  return `${days}d ago`
}

const headerClassNames = ref('mb-4 p-0')
const navMenuOpen = ref(false)
const themeStore = useThemeStore()
const colorMode = computed(() => themeStore.theme)
const logoSrc = computed(() => colorMode.value === 'dark' ? logoDark : logoLight)
const { locale } = useI18n()
const toggleLocale = () => {
  locale.value = locale.value === 'ar' ? 'en' : 'ar'
}
const sidebar = useSidebarStore()
const cart = useCartStore()
const auth = useAuthStore()
const notif = useNotificationStore()
const route = useRoute()
const testerPendingCount = ref(0)
const designerModificationCount = ref(0)

async function fetchTesterCount() {
  try {
    const { data } = await api.get('/api/tester/products/pending-count')
    testerPendingCount.value = data.count
  } catch {}
}

async function fetchDesignerModificationCount() {
  try {
    const { data } = await api.get('/api/designer/products/modification-count')
    designerModificationCount.value = data.count
  } catch {}
}

async function exitImpersonation() {
  const ok = await auth.exitImpersonation()
  if (ok) {
    window.location.href = '/admin/users'
  }
}

const canSee = (item) => {
  const role = auth.userRole
  if (!role) return !item.roles || item.roles.length === 0
  if (role === 'admin') return true
  if (!item.roles || item.roles.length === 0) return true
  return item.roles.includes(role)
}

function setCurrency(currency) {
  if (auth.isAuthenticated) {
    auth.updateCurrency(currency).catch(() => {})
  } else {
    auth.detectedCurrency = currency
    localStorage.setItem('guest-currency', currency)
  }
}

const visibleNav = computed(() => {
  const result = []
  nav.forEach((item) => {
    if (!canSee(item)) return
    if (item.items) {
      const children = item.items.filter((child) => canSee(child))
      if (children.length === 0) return
      result.push({ ...item, items: children })
      return
    }
    result.push(item)
  })
  return result
})

const moreNav = computed(() => visibleNav.value.filter((item) => !['Cart', 'Notifications'].includes(item.name)))

onMounted(() => {
  document.addEventListener('scroll', () => {
    if (document.documentElement.scrollTop > 0) {
      headerClassNames.value = 'mb-4 p-0 shadow-sm'
    } else {
      headerClassNames.value = 'mb-4 p-0'
    }
  }, { passive: true })

  if (auth.isAuthenticated) {
    notif.startPolling(30000)
    if (['tester', 'admin'].includes(auth.userRole)) {
      fetchTesterCount()
      setInterval(fetchTesterCount, 30000)
    }
    if (['designer', 'admin'].includes(auth.userRole)) {
      fetchDesignerModificationCount()
      setInterval(fetchDesignerModificationCount, 30000)
    }
  }
})
</script>

<template>
  <CHeader position="sticky" :class="['modern-header', headerClassNames]">
    <div v-if="auth.impersonating" class="impersonation-banner w-100 d-flex align-items-center justify-content-between px-4 py-1">
      <span class="impersonation-text">
        <CIcon icon="cil-account-login" class="me-1" />
        {{ $t('header.impersonating') }} <strong>{{ auth.userName }}</strong>
      </span>
      <CButton color="light" size="sm" class="impersonation-back" @click="exitImpersonation">
        <CIcon icon="cil-arrow-left" class="me-1" /> {{ $t('header.back_to_admin') }}
      </CButton>
    </div>
    <CContainer class="border-bottom px-4" fluid>
      <CHeaderToggler @click="sidebar.toggleVisible()" style="margin-inline-start: -14px">
      </CHeaderToggler>
      <div class="header-brand d-flex align-items-center ms-2">
        <RouterLink to="/">
          <img :src="logoSrc" alt="Capital-Metal" class="header-logo" width="85" height="47" />
        </RouterLink>
      </div>
      <div class="header-actions d-flex align-items-center gap-2 ms-4">
        <button class="btn-animated-glow" @click="sidebar.toggleVisible()" aria-label="Toggle sidebar">
          <CIcon icon="cil-view-quilt" class="me-1" />
  <CIcon icon="cil-menu" size="lg" />
        </button>
      </div>
      <CHeaderNav class="ms-auto">
        <CNavItem class="cart-fly-zone">
          <RouterLink custom to="/cart" v-slot="{ href, navigate, isActive }">
            <CNavLink :href="href" @click="navigate" :active="isActive" class="cart-fly-link position-relative" :aria-label="$t('header.cart')">
              <CIcon icon="cil-basket" size="lg" />
              <CBadge
                v-if="cart.count > 0"
                color="danger"
                shape="rounded-pill"
                class="position-absolute top-0 start-100 translate-middle"
                style="font-size: 0.65rem"
              >
                {{ cart.count }}
              </CBadge>
            </CNavLink>
          </RouterLink>
        </CNavItem>
        <CDropdown
          v-if="moreNav.length > 0"
          variant="nav-item"
          placement="bottom-end"
          class="d-lg-none header-more-menu"
        >
          <CDropdownToggle :caret="false" class="py-0" :aria-label="$t('header.more')">
            <CIcon icon="cil-applications" size="lg" />
          </CDropdownToggle>
          <CDropdownMenu align="end">
            <CDropdownItem
              v-for="item in moreNav"
              :key="item.name"
              :to="item.to"
              :href="item.href"
              :target="item.href ? '_blank' : undefined"
              router-link
            >
              <CIcon v-if="item.icon" :icon="item.icon" class="me-2" />
              {{ $t(item.translationKey || item.name) }}
            </CDropdownItem>
          </CDropdownMenu>
        </CDropdown>
        <CNavItem v-if="['industor','admin'].includes(auth.userRole)" class="d-none d-lg-flex">
          <RouterLink custom to="/plans" v-slot="{ href, navigate, isActive }">
            <CNavLink :href="href" @click="navigate" :active="isActive" :aria-label="$t('header.plans')">
              <CIcon icon="cil-layers" size="lg" />
            </CNavLink>
          </RouterLink>
        </CNavItem>
        <CNavItem v-if="['industor','designer','tester','admin'].includes(auth.userRole)" class="d-none d-lg-flex">
          <RouterLink custom to="/tickets" v-slot="{ href, navigate, isActive }">
            <CNavLink :href="href" @click="navigate" :active="isActive" :aria-label="$t('header.tickets')">
              <CIcon icon="cil-description" size="lg" />
            </CNavLink>
          </RouterLink>
        </CNavItem>
        <CNavItem v-if="['tester','admin'].includes(auth.userRole)" class="d-none d-lg-flex">
          <RouterLink custom to="/tester/products" v-slot="{ href, navigate, isActive }">
            <CNavLink :href="href" @click="navigate" :active="isActive" class="position-relative" :aria-label="$t('header.testerProducts')">
              <CIcon icon="cil-cart" size="lg" />
              <CBadge
                v-if="testerPendingCount > 0"
                color="warning"
                shape="rounded-pill"
                class="position-absolute top-0 start-100 translate-middle"
                style="font-size: 0.65rem"
              >
                {{ testerPendingCount }}
              </CBadge>
            </CNavLink>
          </RouterLink>
        </CNavItem>
        <CNavItem v-if="['designer','admin'].includes(auth.userRole)" class="d-none d-lg-flex">
          <RouterLink custom to="/designer/products/create" v-slot="{ href, navigate, isActive }">
            <CNavLink :href="href" @click="navigate" :active="isActive" class="position-relative" :aria-label="$t('header.designerProducts')">
              <CIcon icon="cil-grid" size="lg" />
              <CBadge
                v-if="designerModificationCount > 0"
                color="danger"
                shape="rounded-pill"
                class="position-absolute top-0 start-100 translate-middle"
                style="font-size: 0.65rem"
              >
                {{ designerModificationCount }}
              </CBadge>
            </CNavLink>
          </RouterLink>
        </CNavItem>
        <CNavItem v-if="['industor','admin'].includes(auth.userRole)" class="d-none d-lg-flex">
          <RouterLink custom to="/tickets/create" v-slot="{ href, navigate }">
            <CNavLink :href="href" class="btn-create-header" @click="navigate" :aria-label="$t('header.createTicket')">
              <CIcon icon="cil-plus" size="lg" />
            </CNavLink>
          </RouterLink>
        </CNavItem>
        <CNavItem v-if="auth.userRole === 'admin'" class="d-none d-lg-flex">
          <RouterLink custom to="/admin/orders" v-slot="{ href, navigate, isActive }">
            <CNavLink :href="href" @click="navigate" :active="isActive" :aria-label="$t('header.orders')">
              <CIcon icon="cil-layers" size="lg" />
            </CNavLink>
          </RouterLink>
        </CNavItem>
        <CNavItem v-if="auth.userRole === 'admin'" class="d-none d-lg-flex">
          <RouterLink custom to="/admin/coupons" v-slot="{ href, navigate, isActive }">
            <CNavLink :href="href" @click="navigate" :active="isActive" :aria-label="$t('header.coupons')">
              <CIcon icon="cil-tag" size="lg" />
            </CNavLink>
          </RouterLink>
        </CNavItem>
        <CNavItem v-if="auth.userRole === 'admin'" class="d-none d-lg-flex">
          <RouterLink custom to="/admin/materials" v-slot="{ href, navigate, isActive }">
            <CNavLink :href="href" @click="navigate" :active="isActive" :aria-label="$t('header.materials')">
              <CIcon icon="cil-layers" size="lg" />
            </CNavLink>
          </RouterLink>
        </CNavItem>
        <CNavItem v-if="auth.userRole === 'admin'" class="d-none d-lg-flex">
          <RouterLink custom to="/admin/shipping-rates" v-slot="{ href, navigate, isActive }">
            <CNavLink :href="href" @click="navigate" :active="isActive" :aria-label="$t('header.shippingRates')">
              <CIcon icon="cil-truck" size="lg" />
            </CNavLink>
          </RouterLink>
        </CNavItem>
        <CNavItem v-if="auth.userRole === 'admin'" class="d-none d-lg-flex">
          <RouterLink custom to="/admin/users" v-slot="{ href, navigate, isActive }">
            <CNavLink :href="href" @click="navigate" :active="isActive" :aria-label="$t('header.users')">
              <CIcon icon="cil-user" size="lg" />
            </CNavLink>
          </RouterLink>
        </CNavItem>

        <CNavItem v-if="auth.isAuthenticated">
          <CDropdown placement="bottom-end" variant="nav-item" @show="notif.fetchNotifications()">
            <CDropdownToggle :caret="false" class="position-relative py-0" :aria-label="$t('header.notifications')">
              <CIcon icon="cil-bell" size="lg" />
              <CBadge
                v-if="notif.unreadCount > 0"
                color="danger"
                shape="pill"
                class="position-absolute top-0 start-100 translate-middle"
                style="font-size: 0.65rem"
              >
                {{ notif.unreadCount > 99 ? '99+' : notif.unreadCount }}
              </CBadge>
            </CDropdownToggle>
            <CDropdownMenu class="notif-dropdown-menu p-0">
              <CDropdownHeader class="notif-header fw-bold small py-2 px-3 d-flex justify-content-between align-items-center">
                <span>{{ $t('header.notifications') }}</span>
                <CButton
                  v-if="notif.unreadCount > 0"
                  color="link"
                  size="sm"
                  class="p-0 text-decoration-none"
                  @click="notif.markAllAsRead()"
                >
                  {{ $t('header.mark_all_read') }}
                </CButton>
              </CDropdownHeader>
              <div style="max-height: 300px; overflow-y: auto">
                <CDropdownItem
                  v-for="n in notif.notifications.slice(0, 5)"
                  :key="n.id"
                  :class="!n.read_at ? 'notif-item-unread' : 'notif-item-read'"
                  class="d-flex flex-column align-items-start py-2 px-3 border-bottom"
                  style="cursor: pointer"
                  @click="notif.markAsRead(n.id)"
                >
                  <div class="d-flex justify-content-between w-100">
                    <small class="fw-semibold">{{ n.title }}</small>
                    <small class="text-body-secondary ms-2 text-nowrap">{{ timeAgo(n.created_at) }}</small>
                  </div>
                  <small class="text-body-secondary mt-1">{{ n.body || n.data?.message || '' }}</small>
                </CDropdownItem>
                <div v-if="notif.notifications.length === 0" class="text-center py-4 notif-empty small">
                  {{ $t('header.no_notifications') }}
                </div>
              </div>
              <CDropdownItem
                class="notif-view-all text-center small py-2 fw-semibold"
                router-link to="/notifications"
              >
                {{ $t('header.view_all') }}
              </CDropdownItem>
            </CDropdownMenu>
          </CDropdown>
        </CNavItem>
      </CHeaderNav>
      <CHeaderNav>
        <CNavItem class="py-1">
          <div class="vr h-100 mx-2 text-body text-opacity-25"></div>
        </CNavItem>
        <CDropdown variant="nav-item" placement="bottom-end">
          <CDropdownToggle :caret="false">
            <CIcon v-if="colorMode === 'dark'" icon="cil-moon" size="lg" />
            <CIcon v-else-if="colorMode === 'light'" icon="cil-sun" size="lg" />
            <CIcon v-else icon="cil-contrast" size="lg" />
          </CDropdownToggle>
          <CDropdownMenu>
            <CDropdownItem :class="['d-flex', 'align-items-center', 'theme-dropdown-item', { active: colorMode === 'light' }]">
              <button type="button" class="theme-toggle-btn d-flex align-items-center w-100 border-0 bg-transparent p-0" @click.stop="themeStore.toggleTheme('light')">
                <CIcon class="me-2" icon="cil-sun" size="lg" />{{ $t('header.light') }}
              </button>
            </CDropdownItem>
            <CDropdownItem :class="['d-flex', 'align-items-center', 'theme-dropdown-item', { active: colorMode === 'dark' }]">
              <button type="button" class="theme-toggle-btn d-flex align-items-center w-100 border-0 bg-transparent p-0" @click.stop="themeStore.toggleTheme('dark')">
                <CIcon class="me-2" icon="cil-moon" size="lg" />{{ $t('header.dark') }}
              </button>
            </CDropdownItem>
            <CDropdownItem :class="['d-flex', 'align-items-center', 'theme-dropdown-item', { active: colorMode === 'auto' }]">
              <button type="button" class="theme-toggle-btn d-flex align-items-center w-100 border-0 bg-transparent p-0" @click.stop="themeStore.toggleTheme('auto')">
                <CIcon class="me-2" icon="cil-contrast" size="lg" />{{ $t('header.auto') }}
              </button>
            </CDropdownItem>
          </CDropdownMenu>
        </CDropdown>
        <CNavItem>
          <CNavLink class="lang-switcher-btn" @click="toggleLocale">
            {{ locale === 'ar' ? 'EN' : 'AR' }}
          </CNavLink>
        </CNavItem>
        <CNavItem class="currency-switcher">
          <CButtonGroup size="sm" class="currency-group-header">
            <CButton
              :color="auth.userCurrency === 'EGP' ? 'primary' : 'outline-primary'"
              @click="setCurrency('EGP')"
              class="px-2"
            >
              EGP
            </CButton>
            <CButton
              :color="auth.userCurrency === 'USD' ? 'primary' : 'outline-primary'"
              @click="setCurrency('USD')"
              class="px-2"
            >
              USD
            </CButton>
          </CButtonGroup>
        </CNavItem>
        <CNavItem class="py-1">
          <div class="vr h-100 mx-2 text-body text-opacity-25"></div>
        </CNavItem>
        <template v-if="auth.isAuthenticated">
          <AppHeaderDropdownAccnt />
        </template>
        <template v-else>
          <CNavItem>
            <RouterLink to="/pages/login" custom v-slot="{ href, navigate }">
              <CNavLink :href="href" @click="navigate" class="fw-semibold">
                <CIcon icon="cil-account-login" class="me-1" />{{ $t('header.login') }}
              </CNavLink>
            </RouterLink>
          </CNavItem>
          <CNavItem>
            <RouterLink to="/pages/register" custom v-slot="{ href, navigate }">
              <CButton color="primary" size="sm" :href="href" @click="navigate" class="my-1">
                {{ $t('header.sign_up') }}
              </CButton>
            </RouterLink>
          </CNavItem>
        </template>
      </CHeaderNav>
    </CContainer>
    <CContainer class="px-4 header-nav-row" fluid :class="{ 'nav-menu-open': navMenuOpen }">
      <button
        class="header-nav-mobile-toggle"
        type="button"
        :aria-expanded="navMenuOpen"
        aria-label="Menu"
        @click="navMenuOpen = !navMenuOpen"
      >
        <CIcon :icon="navMenuOpen ? 'cil-x' : 'cil-menu'" size="lg" />
        <span>{{ $t('header.menu') }}</span>
      </button>
      <CNav variant="underline-border" class="header-nav-horizontal">
          <template v-for="item in visibleNav" :key="item.name">
            <template v-if="item.component === 'CNavTitle'">
              <CNavItem class="header-nav-title">
                <span class="nav-link disabled">{{ $t(item.translationKey || item.name) }}</span>
              </CNavItem>
            </template>
            <template v-else-if="item.items">
              <CDropdown variant="nav-item" placement="bottom">
                <CDropdownToggle :caret="true">
                  <CIcon v-if="item.icon" :icon="item.icon" class="me-1" />
                  {{ $t(item.translationKey || item.name) }}
                </CDropdownToggle>
                <CDropdownMenu>
                  <CDropdownItem
                    v-for="child in item.items"
                    :key="child.name"
                    :to="child.to"
                    :href="child.href"
                    :target="child.href ? '_blank' : undefined"
                    router-link
                  >
                    <CIcon v-if="child.icon" :icon="child.icon" class="me-2" />
                    {{ $t(child.translationKey || child.name) }}
                  </CDropdownItem>
                </CDropdownMenu>
              </CDropdown>
            </template>
            <template v-else>
              <CNavItem>
                <RouterLink
                  custom
                  :to="item.to"
                  v-slot="{ href, navigate, isActive }"
                >
                  <CNavLink
                    :href="href"
                    @click="navigate"
                    :active="isActive"
                  >
                    <CIcon v-if="item.icon" :icon="item.icon" class="me-1" />
                    {{ $t(item.translationKey || item.name) }}
                    <CBadge
                      v-if="item.badge"
                      :color="item.badge.color"
                      shape="rounded-pill"
                      class="ms-1"
                      size="sm"
                    >
                      {{ item.badge.text }}
                    </CBadge>
                  </CNavLink>
                </RouterLink>
              </CNavItem>
            </template>
          </template>
      </CNav>
      <AppBreadcrumb />
    </CContainer>
  </CHeader>
</template>

<style scoped>
.impersonation-banner {
  background: linear-gradient(90deg, #0EA5E9, #8f0e00);
  color: #fff;
}

.impersonation-text {
  font-size: 0.85rem;
}

.impersonation-back {
  font-weight: 600;
  font-size: 0.75rem;
}

.notif-dropdown-menu {
  min-width: 320px;
}

.notif-header {
  background: var(--cui-body-bg, #fff);
  border-bottom: 1px solid var(--cui-border-color, rgba(0,0,0,.125));
}

.notif-item-unread {
  background: var(--cui-tertiary-bg, #f8f9fa);
}

.notif-item-read {
  background: transparent;
}

.notif-item-unread:hover,
.notif-item-read:hover {
  background: var(--cui-tertiary-bg, #e9ecef);
}

.notif-empty {
  color: var(--cui-secondary-color, #6c757d);
}

.notif-view-all {
  border-top: 1px solid var(--cui-border-color, rgba(0,0,0,.125));
  color: var(--cui-primary, #0EA5E9);
}

.currency-group-header {
  display: flex;
  align-items: center;
  gap: 0;
  border-radius: 6px;
  overflow: hidden;
}
.currency-group-header .btn {
  font-size: 0.72rem;
  font-weight: 600;
  padding: 0.2rem 0.5rem;
  border: 1px solid var(--cui-border-color, rgba(0,0,0,.125));
}
.currency-group-header .btn:first-child {
  border-radius: 6px 0 0 6px;
}
.currency-group-header .btn:last-child {
  border-radius: 0 6px 6px 0;
}
</style>
