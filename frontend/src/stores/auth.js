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

function generateUUID() {
  if (typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID()
  }
  return ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, (c) =>
    (c ^ (crypto.getRandomValues(new Uint8Array(1))[0] & (15 >> (c / 4)))).toString(16)
  )
}

function generateGuestToken() {
  let token = localStorage.getItem('guest-token')
  if (!token) {
    token = 'guest_' + generateUUID()
    localStorage.setItem('guest-token', token)
  }
  return token
}

async function detectViaGPS() {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) return reject('no geolocation')
    navigator.geolocation.getCurrentPosition(
      async (position) => {
        try {
          const res = await fetch(
            `https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${position.coords.latitude}&longitude=${position.coords.longitude}&localityLanguage=en`
          )
          const data = await res.json()
          const countryCode = data?.countryCode?.toLowerCase()
          resolve(countryCode === 'eg' ? 'EGP' : 'USD')
        } catch {
          reject('reverse-geocode failed')
        }
      },
      () => reject('permission denied or timeout'),
      { enableHighAccuracy: true, timeout: 5000 }
    )
  })
}

export async function detectCurrency() {
  try {
    const currency = await detectViaGPS()
    return currency
  } catch {
    // fallback to IP-based detection
  }
  try {
    const res = await fetch('https://ip-api.com/json/')
    const data = await res.json()
    const countryCode = data?.countryCode?.toLowerCase()
    return countryCode === 'eg' ? 'EGP' : 'USD'
  } catch {
    return 'EGP'
  }
}

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: loadUser(),
    token: localStorage.getItem('auth-token') || null,
    loading: false,
    exchangeRate: null,
    detectedCurrency: null,
    guestToken: generateGuestToken(),
  }),

  getters: {
    isAuthenticated: (state) => !!state.token,
    userRole: (state) => state.user?.role?.name || null,
    userName: (state) => state.user?.name || '',
    userEmail: (state) => state.user?.email || '',
    userCurrency: (state) => state.user?.currency_preference || state.detectedCurrency || 'EGP',
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
        const detected = await detectCurrency()
        this.detectedCurrency = detected
        if (detected !== (data.user?.currency_preference || 'EGP')) {
          try { await this.updateCurrency(detected) } catch {}
        }
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
        const detected = currencyPreference || await detectCurrency()
        const { data } = await api.post('/api/register', {
          name,
          email,
          password,
          password_confirmation: passwordConfirmation,
          currency_preference: detected,
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

    async detectAndSetCurrency() {
      const currency = await detectCurrency()
      this.detectedCurrency = currency
      if (this.user && currency !== this.user.currency_preference) {
        try { await this.updateCurrency(currency) } catch {}
      }
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
