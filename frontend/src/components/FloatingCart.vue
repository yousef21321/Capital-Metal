<script setup>
import { useCartStore } from '@/stores/cart'

const cart = useCartStore()
</script>

<template>
  <RouterLink to="/cart" class="floating-cart cart-fly-zone cart-fly-link" aria-label="Cart">
    <CIcon icon="cil-cart" size="lg" class="floating-cart-icon" />
    <CBadge
      v-if="cart.count > 0"
      color="danger"
      shape="rounded-pill"
      class="floating-cart-badge"
    >
      {{ cart.count }}
    </CBadge>
  </RouterLink>
</template>