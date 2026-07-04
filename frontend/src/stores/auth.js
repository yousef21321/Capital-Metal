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

function generateGuestToken() {
  let token = localStorage.getItem('guest-token')
  if (!token) {
    token = 'guest_' + crypto.randomUUID()
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
    guestToken: generateGuestToken(),
  }),

  getters: {
    isAuthenticated: (state) => !!state.token,
    userRole: (state) => state.user?.role?.name || null,
    userName: (state) => state.user?.name || '',
    userEmail: (state) => state.user?.email || '',
    userCurrency: (state) => state.user?.currency_preference || 'EGP',
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
          currency_preference: currencyPreference || 'EGP',
        })
        this.token = data.token
        this.persistUser(data.user)
        localStorage.setItem('auth-token', data.token)
        this.fetchExchangeRate()
        return true
      } catch (error) {
        const message = error.response?.data?.message || 'Registration failed'
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

    async updateCurrency(currency) {
      const { data } = await api.put('/api/me/currency', { currency_preference: currency })
      this.persistUser(data)
      return data
    },

    async fetchUser() {
      if (!this.token) return null
      try {
        const { data } = await api.get('/api/me')
        this.persistUser(data)
        return data
      } catch {
        this.logout()
        return null
      }
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
    },
  },
})
