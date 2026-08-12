import { defineStore } from 'pinia'
import api from '@/api'

function loadUser() {
  try {
    const raw = localStorage.getItem('auth-user')
    return raw ? JSON.parse(raw) : null
  } catch {
    return null
  }
}

function loadDetectedCurrency() {
  try {
    return localStorage.getItem('guest-currency') || null
  } catch {
    return null
  }
}

function generateUUID() {
  if (typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID()
  }
  return ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, (c) =>
    (c ^ (crypto.getRandomValues(new Uint8Array(1))[0] & (15 >> (c / 4)))).toString(16)
  )
}

function generateGuestToken() {
  if (localStorage.getItem('auth-token')) {
    return null
  }
  let token = localStorage.getItem('guest-token')
  if (!token) {
    token = 'guest_' + generateUUID()
    localStorage.setItem('guest-token', token)
  }
  return token
}

function ensureGuestToken() {
  let token = localStorage.getItem('guest-token')
  if (!token) {
    token = 'guest_' + generateUUID()
    localStorage.setItem('guest-token', token)
  }
  return token
}

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: loadUser(),
    token: localStorage.getItem('auth-token') || null,
    loading: false,
    exchangeRate: null,
    detectedCurrency: loadDetectedCurrency(),
    guestToken: generateGuestToken(),
  }),

  getters: {
    isAuthenticated: (state) => !!state.token,
    userRole: (state) => state.user?.role?.name || null,
    userName: (state) => state.user?.name || '',
    userEmail: (state) => state.user?.email || '',
    userCurrency: (state) => state.user?.currency_preference || state.detectedCurrency || 'EGP',
    impersonating: (state) => !!localStorage.getItem('impersonation-admin'),
  },

  actions: {
    persistUser(user) {
      this.user = user
      if (user) {
        localStorage.setItem('auth-user', JSON.stringify(user))
      } else {
        localStorage.removeItem('auth-user')
      }
    },

    async login(email, password) {
      this.loading = true
      try {
        const { data } = await api.post('/api/login', { email, password })
        this.token = data.token
        this.persistUser(data.user)
        localStorage.setItem('auth-token', data.token)
        localStorage.removeItem('guest-token')
        this.fetchExchangeRate()
        return true
      } catch (error) {
        const message = error.response?.data?.message || 'Login failed'
        throw new Error(message)
      } finally {
        this.loading = false
      }
    },

    async register(name, email, password, passwordConfirmation, currencyPreference) {
      this.loading = true
      try {
        const { data } = await api.post('/api/register', {
          name,
          email,
          password,
          password_confirmation: passwordConfirmation,
          currency_preference: currencyPreference,
        })
        this.token = data.token
        this.persistUser(data.user)
        localStorage.setItem('auth-token', data.token)
        localStorage.removeItem('guest-token')
        this.fetchExchangeRate()
        return true
      } catch (error) {
        const message = error.response?.data?.message || 'Registration failed'
        throw new Error(message)
      } finally {
        this.loading = false
      }
    },

    async googleLogin(googleToken) {
      this.loading = true
      try {
        const { data } = await api.post('/api/auth/google', { credential: googleToken })
        this.token = data.token
        this.persistUser(data.user)
        localStorage.setItem('auth-token', data.token)
        localStorage.removeItem('guest-token')
        this.fetchExchangeRate()
        return true
      } catch (error) {
        const message = error.response?.data?.message || 'Google login failed'
        throw new Error(message)
      } finally {
        this.loading = false
      }
    },

    async fetchExchangeRate() {
      try {
        const { data } = await api.get('/api/exchange-rate')
        this.exchangeRate = parseFloat(data.rate) || 30
      } catch {
        this.exchangeRate = this.exchangeRate || 30
      }
    },

    detectAndSetCurrency() {
      if (this.user?.currency_preference) {
        this.detectedCurrency = this.user.currency_preference
        return this.user.currency_preference
      }
      const saved = loadDetectedCurrency()
      if (saved) {
        this.detectedCurrency = saved
        return saved
      }
      this.detectedCurrency = 'EGP'
      return 'EGP'
    },

    async fetchUser() {
      try {
        const { data } = await api.get('/api/me')
        this.persistUser(data)
        return data
      } catch (error) {
        if (error.response?.status === 401) {
          this.logout()
        }
        throw error
      }
    },

    async updateCurrency(currency) {
      const { data } = await api.put('/api/me/currency', { currency_preference: currency })
      this.persistUser(data)
      return data
    },

    async updateProfile(formData) {
      const { data } = await api.put('/api/me', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
      this.persistUser(data)
      return data
    },

    async logout() {
      try {
        await api.post('/api/logout')
      } catch {
        // ignore
      }
      this.token = null
      this.persistUser(null)
      localStorage.removeItem('auth-token')
      localStorage.removeItem('impersonation-admin')
      this.guestToken = ensureGuestToken()
    },

    async impersonate(user) {
      const { data } = await api.post(`/api/admin/users/${user.id}/impersonate`)
      const prev = {
        token: this.token,
        user: this.user,
      }
      localStorage.setItem('impersonation-admin', JSON.stringify(prev))
      this.token = data.token
      this.persistUser(data.user)
      localStorage.setItem('auth-token', data.token)
      localStorage.removeItem('guest-token')
      this.fetchExchangeRate()
      return data.user
    },

    async exitImpersonation() {
      const raw = localStorage.getItem('impersonation-admin')
      if (!raw) return false
      try {
        const prev = JSON.parse(raw)
        localStorage.removeItem('impersonation-admin')
        if (prev?.token) {
          this.token = prev.token
          this.persistUser(prev.user)
          localStorage.setItem('auth-token', prev.token)
          localStorage.removeItem('guest-token')
          this.fetchExchangeRate()
          return true
        }
      } catch {
        // ignore
      }
      return false
    },
  },
})
