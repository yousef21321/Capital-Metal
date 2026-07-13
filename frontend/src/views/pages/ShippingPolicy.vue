<script setup>
import AppHeader from '@/components/AppHeader.vue'
import AppFooter from '@/components/AppFooter.vue'
</script>

<template>
  <div class="d-flex flex-column min-vh-100">
    <AppHeader />
    <div class="body flex-grow-1">
      <CContainer>
        <CRow class="justify-content-center py-5">
          <CCol :md="10" :lg="8">
            <CCard class="mb-4 shadow-sm">
              <CCardBody class="p-4 p-md-5">
                <h1 class="mb-4">سياسة الشحن والتوصيل</h1>
                <h5 class="text-body-secondary mb-4">Shipping &amp; Delivery Policy</h5>

                <hr />

                <h5>نطاق التوصيل</h5>
                <p>نقوم بالتوصيل إلى جميع محافظات جمهورية مصر العربية. لا يتوفر الشحن الدولي حالياً.</p>
                <p class="mb-4 text-body-secondary">We deliver to all governorates of Egypt. International shipping is not available at this time.</p>

                <h5>مدة التوصيل</h5>
                <ul>
                  <li><strong>القاهرة الكبرى:</strong> 2-4 أيام عمل.</li>
                  <li><strong>المحافظات:</strong> 4-7 أيام عمل.</li>
                  <li><strong>المحافظات الحدودية:</strong> 7-14 يوم عمل.</li>
                </ul>
                <p class="mb-4 text-body-secondary">
                  Greater Cairo: 2-4 business days. Governorates: 4-7 business days. Border governorates: 7-14 business days.
                </p>

                <h5>رسوم الشحن</h5>
                <ul>
                  <li>القاهرة والجيزة: 30-50 جنيه مصري.</li>
                  <li>المحافظات الأخرى: 50-80 جنيه مصري.</li>
                  <li>الطلبات فوق 1000 جنيه: شحن مجاني.</li>
                </ul>
                <p class="mb-4 text-body-secondary">
                  Cairo/Giza: 30-50 EGP. Other governorates: 50-80 EGP. Free shipping on orders over 1000 EGP.
                </p>

                <h5>تتبع الطلب</h5>
                <p>بعد تأكيد الشحن، سيتم إرسال رابط تتبع الطلب عبر البريد الإلكتروني ورقم الهاتف المسجلين لديك.</p>
                <p class="mb-4 text-body-secondary">After shipment confirmation, a tracking link will be sent via your registered email and phone number.</p>

                <h5>تأخير التوصيل</h5>
                <p>في حالة تأخير الطلب عن المدة المذكورة، يرجى التواصل معنا عبر صفحة <router-link to="/pages/contact">اتصل بنا</router-link>.</p>
                <p class="text-body-secondary">If your order is delayed, please contact us via our <router-link to="/pages/contact">Contact Us</router-link> page.</p>
              </CCardBody>
            </CCard>
          </CCol>
        </CRow>
      </CContainer>
    </div>
    <AppFooter />
  </div>
</template>
