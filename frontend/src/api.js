import axios from 'axios'

const api = axios.create({
baseURL: import.meta.env.VITE_API_URL || 'https://capital-metal.first-link-logistics.com',
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json',
  },
})

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('auth-token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }

  const guestToken = localStorage.getItem('guest-token')
  if (guestToken) {
    config.headers['X-Guest-Token'] = guestToken
  }

  // Cloudflare caches API GET responses (e.g. /api/cart) by URL for 31 days,
  // which returns stale/empty carts. Add a unique query param so the CDN
  // cache never matches and every GET hits the fresh backend response.
  if (config.method?.toLowerCase() === 'get') {
    config.params = {
      ...(config.params || {}),
      _: Date.now(),
    }
  }

  return config
})

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      const isAuthRoute = error.config?.url?.includes('/api/me')
        || error.config?.url?.includes('/api/logout')
        || error.config?.url?.includes('/api/wishlist')
        || error.config?.url?.includes('/api/checkout')
        || error.config?.url?.includes('/api/orders')
      if (isAuthRoute) {
        localStorage.removeItem('auth-token')
        const currentPath = window.location.pathname + window.location.search
        window.location.href = '/pages/login?redirect=' + encodeURIComponent(currentPath)
      }
    }
    return Promise.reject(error)
  },
)

export default api
