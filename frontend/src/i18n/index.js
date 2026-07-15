import { createI18n } from 'vue-i18n'
import en from '@/locales/en.json'

const savedLocale = localStorage.getItem('locale') || 'ar'

const i18n = createI18n({
  legacy: false,
  locale: savedLocale,
  fallbackLocale: 'en',
  messages: { en },
})

const loadedLocales = new Set(['en'])

async function loadLocale(locale) {
  if (loadedLocales.has(locale)) return
  const arModule = await import(`@/locales/${locale}.json`)
  i18n.global.setLocaleMessage(locale, arModule.default)
  loadedLocales.add(locale)
}

const originalSetLocale = i18n.global.setLocale
i18n.global.setLocale = async (locale) => {
  await loadLocale(locale)
  return originalSetLocale.call(i18n.global, locale)
}

export { loadLocale }
export default i18n
