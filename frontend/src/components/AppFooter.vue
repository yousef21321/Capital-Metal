<template>
  <CFooter class="px-4">
    <div>
      <span class="fw-semibold">FLFL_Design</span>
      <span class="ms-1">&copy; {{ new Date().getFullYear() }} {{ $t('footer.all_rights') }}</span>
    </div>
    <div class="d-flex gap-3 ms-auto small">
      <router-link to="/pages/privacy-policy" class="text-decoration-none">{{ $t('footer.privacy_policy') }}</router-link>
      <router-link to="/pages/refund-policy" class="text-decoration-none">{{ $t('footer.refund_policy') }}</router-link>
      <router-link to="/pages/shipping-policy" class="text-decoration-none">{{ $t('footer.shipping_policy') }}</router-link>
      <router-link to="/pages/contact" class="text-decoration-none">{{ $t('footer.contact_us') }}</router-link>
      <span class="text-body-secondary">|</span>
      <span>info@flfldesign.com</span>
    </div>
  </CFooter>
</template>
