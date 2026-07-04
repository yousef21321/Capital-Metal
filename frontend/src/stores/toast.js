import { ref } from 'vue'
import { defineStore } from 'pinia'

export const useToastStore = defineStore('toast', () => {
  const toasts = ref([])
  let nextId = 1

  function show(message, { title = '', color = 'success', autohide = true, delay = 3000 } = {}) {
    const id = nextId++
    toasts.value.push({ id, message, title, color, autohide, delay, visible: true })

    if (autohide) {
      setTimeout(() => remove(id), delay)
    }
    return id
  }

  function success(message, title = 'Success') {
    return show(message, { title, color: 'success' })
  }

  function error(message, title = 'Error') {
    return show(message, { title, color: 'danger', delay: 5000 })
  }

  function info(message, title = 'Info') {
    return show(message, { title, color: 'info' })
  }

  function remove(id) {
    const toast = toasts.value.find((t) => t.id === id)
    if (toast) {
      toast.visible = false
      setTimeout(() => {
        toasts.value = toasts.value.filter((t) => t.id !== id)
      }, 300)
    }
  }

  return { toasts, show, success, error, info, remove }
})
