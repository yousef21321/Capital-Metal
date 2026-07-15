<template>
  <CFooter class="px-3 px-md-4 flex-column text-center text-md-start">
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-center align-items-md-start w-100 gap-2">
      <div class="footer-brand">
        <span class="fw-semibold">FLFL_Design</span>
        <span class="ms-1">&copy; {{ new Date().getFullYear() }} {{ $t('footer.all_rights') }}</span>
      </div>
      <div class="d-flex flex-wrap justify-content-center gap-2 gap-md-3 small footer-links">
        <router-link to="/pages/privacy-policy" class="text-decoration-none">{{ $t('footer.privacy_policy') }}</router-link>
        <router-link to="/pages/refund-policy" class="text-decoration-none">{{ $t('footer.refund_policy') }}</router-link>
        <router-link to="/pages/shipping-policy" class="text-decoration-none">{{ $t('footer.shipping_policy') }}</router-link>
        <router-link to="/pages/contact" class="text-decoration-none">{{ $t('footer.contact_us') }}</router-link>
      </div>
    </div>
  </CFooter>
</template>
