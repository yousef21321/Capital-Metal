<script setup>
import { useToastStore } from '@/stores/toast'

const toastStore = useToastStore()
</script>

<template>
  <CToaster placement="top-end" class="p-3">
    <CToast
      v-for="toast in toastStore.toasts"
      :key="toast.id"
      :autohide="toast.autohide"
      :delay="toast.delay"
      :visible="toast.visible"
      @close="toastStore.remove(toast.id)"
    >
      <CToastHeader :class="`text-white bg-${toast.color}`" closeButton>
        <CIcon :icon="toast.color === 'danger' ? 'cil-warning' : 'cil-check-circle'" class="me-2" />
        <strong class="me-auto">{{ toast.title }}</strong>
      </CToastHeader>
      <CToastBody>{{ toast.message }}</CToastBody>
    </CToast>
  </CToaster>
</template>
