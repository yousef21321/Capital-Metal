import axios from 'axios'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'https://flfl-design.com',
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
        window.location.hash = '#/pages/login'
      }
    }
    return Promise.reject(error)
  },
)

export default api
