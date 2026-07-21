import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import api from '@/api'

export const useCartStore = defineStore('cart', () => {
  const items = ref([])
  const count = computed(() => items.value.reduce((sum, i) => sum + i.quantity, 0))
  const loading = ref(false)

  async function fetchCart() {
    try {
      const { data } = await api.get('/api/cart')
      items.value = data.items || []
    } catch (e) {
      items.value = []
    }
  }

  async function addItem(productId, quantity = 1, variantId = null) {
    loading.value = true
    try {
      const payload = { product_id: productId, quantity }
      if (variantId) payload.variant_id = variantId
      const { data } = await api.post('/api/cart/items', payload)
      items.value = data.items || []
      return true
    } catch (e) {
      throw e
    } finally {
      loading.value = false
    }
  }

  async function updateItem(itemId, quantity) {
    try {
      const { data } = await api.put(`/api/cart/items/${itemId}`, { quantity })
      items.value = data.items || []
    } catch (e) {
      console.error(e)
    }
  }

  async function removeItem(itemId) {
    try {
      await api.delete(`/api/cart/items/${itemId}`)
      items.value = items.value.filter((i) => i.id !== itemId)
    } catch (e) {
      console.error(e)
    }
  }

  async function clear() {
    try {
      await api.delete('/api/cart')
      items.value = []
    } catch (e) {
      console.error(e)
    }
  }

  return { items, count, loading, fetchCart, addItem, updateItem, removeItem, clear }
})
