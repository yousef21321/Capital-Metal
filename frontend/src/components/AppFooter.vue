<template>
  <CFooter class="px-4">
    <div>
      <span class="fw-semibold">FLFL_Design</span>
      <span class="ms-1">&copy; {{ new Date().getFullYear() }} All rights reserved.</span>
    </div>
    <div class="d-flex gap-3 ms-auto small">
      <router-link to="/pages/privacy-policy" class="text-decoration-none">سياسة الخصوصية</router-link>
      <router-link to="/pages/refund-policy" class="text-decoration-none">سياسة الاسترجاع</router-link>
      <router-link to="/pages/shipping-policy" class="text-decoration-none">سياسة الشحن</router-link>
      <router-link to="/pages/contact" class="text-decoration-none">اتصل بنا</router-link>
      <span class="text-body-secondary">|</span>
      <span>info@flfldesign.com</span>
      <span>+20 101 234 5678</span>
    </div>
  </CFooter>
</template>
