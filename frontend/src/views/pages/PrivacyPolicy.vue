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
                <h1 class="mb-4">سياسة الخصوصية</h1>
                <h2 class="text-body-secondary mb-4 fs-5">Privacy Policy</h2>

                <hr />

                <h2 class="fs-5">المقدمة</h2>
                <p>نحن في Cairo-Metal نلتزم بحماية خصوصيتك. تصف هذه السياسة كيفية جمع واستخدام وحماية معلوماتك الشخصية.</p>
                <p class="mb-4 text-body-secondary">At Cairo-Metal, we are committed to protecting your privacy. This policy describes how we collect, use, and protect your personal information.</p>

                <h2 class="fs-5">المعلومات التي نجمعها</h2>
                <ul>
                  <li>الاسم والبريد الإلكتروني ورقم الهاتف.</li>
                  <li>عنوان الشحن والفاتورة.</li>
                  <li>معلومات الدفع (يتم معالجتها بشكل آمن عبر PayMob).</li>
                  <li>بيانات التصفح وتفاعلك مع الموقع.</li>
                </ul>
                <p class="mb-4 text-body-secondary">Name, email, phone, shipping address, payment info (securely processed via PayMob), and browsing data.</p>

                <h2 class="fs-5">كيف نستخدم معلوماتك</h2>
                <ul>
                  <li>معالجة الطلبات والتوصيل.</li>
                  <li>التواصل معك بخصوص طلباتك.</li>
                  <li>تحسين تجربة المستخدم والموقع.</li>
                  <li>إرسال عروض ترويجية (بموافقتك).</li>
                </ul>
                <p class="mb-4 text-body-secondary">To process orders, communicate with you, improve user experience, and send promotions (with your consent).</p>

                <h2 class="fs-5">حماية البيانات</h2>
                <p>نستخدم إجراءات أمنية مشددة لحماية معلوماتك من الوصول غير المصرح به أو الاستخدام أو الإفصاح.</p>
                <p class="mb-4 text-body-secondary">We implement strict security measures to protect your information from unauthorized access or disclosure.</p>

                <h2 class="fs-5">مشاركة المعلومات</h2>
                <p>لا نشارك معلوماتك مع أطراف ثالثة إلا لغرض توصيل الطلبات أو المتطلبات القانونية.</p>
                <p class="mb-4 text-body-secondary">We do not share your information with third parties except for order delivery or legal requirements.</p>

                <h2 class="fs-5">حقوقك</h2>
                <p>لك الحق في الوصول إلى بياناتك أو تعديلها أو حذفها في أي وقت. يمكنك التواصل معنا عبر صفحة <router-link to="/pages/contact">اتصل بنا</router-link>.</p>
                <p class="text-body-secondary">You have the right to access, modify, or delete your data at any time. Contact us via our <router-link to="/pages/contact">Contact Us</router-link> page.</p>
              </CCardBody>
            </CCard>
          </CCol>
        </CRow>
      </CContainer>
    </div>
    <AppFooter />
  </div>
</template>
