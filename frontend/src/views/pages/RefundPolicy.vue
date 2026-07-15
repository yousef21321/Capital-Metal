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
                <h1 class="mb-4">سياسة الاسترجاع والاستبدال</h1>
                <h2 class="text-body-secondary mb-4 fs-5">Refund &amp; Return Policy</h2>

                <hr />

                <h2 class="fs-5">المدة المسموح بها للإرجاع</h2>
                <p>يمكنك إرجاع المنتجات خلال 14 يومًا من تاريخ استلام الطلب. يجب أن تكون المنتجات في حالتها الأصلية وغير مستخدمة.</p>
                <p class="mb-4">You may return products within 14 days of receiving your order. Items must be unused and in original condition.</p>

                <h2 class="fs-5">شروط الإرجاع</h2>
                <ul>
                  <li>المنتج في عبوته الأصلية.</li>
                  <li>إيصال الشراء أو فاتورة الطلب.</li>
                  <li>المنتج غير مستخدم أو تالف.</li>
                  <li>المنتجات الرقمية (Digital Products) غير قابلة للإرجاع بعد التحميل.</li>
                </ul>
                <p class="mb-4 text-body-secondary">Item must be in original packaging with receipt. Digital products are non-refundable after download.</p>

                <h2 class="fs-5">كيفية تقديم طلب إرجاع</h2>
                <p>تواصل معنا عبر صفحة <router-link to="/pages/contact">اتصل بنا</router-link> أو عبر البريد الإلكتروني support@flfldesign.com وسنقوم بإرشادك خلال الخطوات.</p>
                <p class="mb-4 text-body-secondary">Contact us via our <router-link to="/pages/contact">Contact Us</router-link> page or email support@flfldesign.com for guidance.</p>

                <h2 class="fs-5">المبالغ المستردة</h2>
                <p>سيتم رد المبلغ خلال 5-10 أيام عمل بعد استلام المنتج وفحصه. يتم الرد عبر نفس وسيلة الدفع المستخدمة في الشراء.</p>
                <p class="mb-4 text-body-secondary">Refunds are processed within 5-10 business days after receiving and inspecting the item. Refunds are issued to the original payment method.</p>

                <h2 class="fs-5">الاستبدال</h2>
                <p>في حالة وجود عيب في المنتج، يمكن استبداله خلال 7 أيام من الاستلام. يتحمل متجر FLFL Design تكاليف الشحن في هذه الحالة.</p>
                <p class="text-body-secondary">If the product is defective, exchanges are accepted within 7 days. FLFL Design covers shipping costs for defective items.</p>
              </CCardBody>
            </CCard>
          </CCol>
        </CRow>
      </CContainer>
    </div>
    <AppFooter />
  </div>
</template>
