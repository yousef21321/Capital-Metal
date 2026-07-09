<script setup>
import { onBeforeMount, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useColorModes } from '@coreui/vue'
import { useThemeStore } from '@/stores/theme.js'
import { useAuthStore } from '@/stores/auth'

const { isColorModeSet, setColorMode } = useColorModes(
  'coreui-free-vue-admin-template-theme',
)
const currentTheme = useThemeStore()
const authStore = useAuthStore()
const { locale } = useI18n()

watch(locale, (val) => {
  document.documentElement.dir = val === 'ar' ? 'rtl' : 'ltr'
  localStorage.setItem('locale', val)
})

onBeforeMount(async () => {
  document.documentElement.dir = locale.value === 'ar' ? 'rtl' : 'ltr'
  const urlParams = new URLSearchParams(window.location.href.split('?')[1])
  let theme = urlParams.get('theme')

  if (theme !== null && theme.match(/^[A-Za-z0-9\s]+/)) {
    theme = theme.match(/^[A-Za-z0-9\s]+/)[0]
  }

  if (theme) {
    setColorMode(theme)
    return
  }

  if (isColorModeSet()) {
    return
  }

  setColorMode(currentTheme.theme)

  if (authStore.token) {
    await authStore.fetchUser()
  }

  authStore.fetchExchangeRate()
})
</script>

<template>
  <router-view />
</template>

<style lang="scss">
@use 'styles/style';
@use 'styles/examples';
</style>
