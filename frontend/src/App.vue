<script setup>
import { onBeforeMount, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useThemeStore } from '@/stores/theme.js'
import { useAuthStore } from '@/stores/auth'
import { loadLocale } from '@/i18n'

const currentTheme = useThemeStore()
const authStore = useAuthStore()
const { locale } = useI18n()

watch(locale, async (val) => {
  document.documentElement.dir = val === 'ar' ? 'rtl' : 'ltr'
  document.documentElement.lang = val
  localStorage.setItem('locale', val)
  await loadLocale(val)
})

onBeforeMount(async () => {
  document.documentElement.dir = locale.value === 'ar' ? 'rtl' : 'ltr'
  document.documentElement.lang = locale.value

  await loadLocale(locale.value)

  // Clean up old CoreUI theme key that conflicts with our store
  localStorage.removeItem('coreui-free-vue-admin-template-theme')

  const urlParams = new URLSearchParams(window.location.href.split('?')[1])
  let theme = urlParams.get('theme')

  if (theme !== null && theme.match(/^[A-Za-z0-9\s]+/)) {
    theme = theme.match(/^[A-Za-z0-9\s]+/)[0]
  }

  if (theme) {
    currentTheme.toggleTheme(theme)
    return
  }

  // Always apply stored theme to DOM
  currentTheme.toggleTheme(currentTheme.theme)

  if (authStore.token) {
    await authStore.fetchUser()
  }

  await Promise.all([
    authStore.detectAndSetCurrency(),
    authStore.fetchExchangeRate(),
  ])
})
</script>

<template>
  <router-view />
</template>

<style lang="scss">
@use 'styles/style';
@use 'styles/examples';
</style>
