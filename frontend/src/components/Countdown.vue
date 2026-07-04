<script setup>
import { ref, onMounted, onBeforeUnmount, computed } from 'vue'

const props = defineProps({
  deadline: { type: [String, Number, Date], default: null },
  active: { type: Boolean, default: true },
})

const now = ref(Date.now())
let timer = null

onMounted(() => {
  timer = setInterval(() => {
    now.value = Date.now()
  }, 1000)
})

onBeforeUnmount(() => {
  if (timer) clearInterval(timer)
})

const target = computed(() => {
  if (!props.deadline) return 0
  return new Date(props.deadline).getTime()
})

const remaining = computed(() => {
  return Math.max(0, target.value - now.value)
})

const isOverdue = computed(() => props.active && remaining.value === 0 && target.value > 0)

const parts = computed(() => {
  const total = Math.floor(remaining.value / 1000)
  const days = Math.floor(total / 86400)
  const hours = Math.floor((total % 86400) / 3600)
  const minutes = Math.floor((total % 3600) / 60)
  const seconds = total % 60
  return { days, hours, minutes, seconds }
})

const pad = (n) => String(n).padStart(2, '0')
</script>

<template>
  <div v-if="target" class="d-flex align-items-center gap-2">
    <CIcon :icon="isOverdue ? 'cil-clock-history' : 'cil-clock'" :class="isOverdue ? 'text-danger' : 'text-warning'" />
    <template v-if="isOverdue">
      <span class="badge text-bg-danger">Overdue</span>
    </template>
    <template v-else>
      <div class="d-flex align-items-center gap-1 font-monospace">
        <span v-if="parts.days > 0" class="badge text-bg-secondary">{{ parts.days }}d</span>
        <span class="badge text-bg-dark">{{ pad(parts.hours) }}</span>
        <span class="text-body-secondary">:</span>
        <span class="badge text-bg-dark">{{ pad(parts.minutes) }}</span>
        <span class="text-body-secondary">:</span>
        <span class="badge text-bg-dark">{{ pad(parts.seconds) }}</span>
      </div>
    </template>
  </div>
  <span v-else class="text-body-secondary small">No deadline set</span>
</template>
