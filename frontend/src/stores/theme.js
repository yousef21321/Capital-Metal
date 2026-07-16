import { ref, watch } from 'vue'
import { defineStore } from 'pinia'

const STORAGE_KEY = 'app-theme'

function applyTheme(mode) {
  if (mode === 'auto') {
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
    document.documentElement.dataset.coreuiTheme = prefersDark ? 'dark' : 'light'
  } else {
    document.documentElement.dataset.coreuiTheme = mode
  }
}

export const useThemeStore = defineStore('theme', () => {
  const theme = ref(localStorage.getItem(STORAGE_KEY) || 'light')

  const toggleTheme = (mode) => {
    theme.value = mode
    localStorage.setItem(STORAGE_KEY, mode)
    applyTheme(mode)
  }

  watch(theme, (val) => applyTheme(val), { immediate: true })

  return { theme, toggleTheme }
})
