<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/api'
import { useToastStore } from '@/stores/toast'

const router = useRouter()
const toast = useToastStore()
const categories = ref([])
const loading = ref(true)

async function fetchCategories() {
  loading.value = true
  try {
    const { data } = await api.get('/api/main-categories')
    categories.value = data.filter(c => c.is_active)
  } catch (e) {
    toast.error('Failed to load categories.')
  } finally {
    loading.value = false
  }
}

function viewCategory(slug) {
  router.push(`/main-categories/${slug}`)
}

onMounted(fetchCategories)
</script>

<template>
  <div class="main-categories-page">
    <div class="categories-header mb-4">
      <h3 class="mb-1 fw-bold">
        <CIcon icon="cil-grid" class="me-2 text-primary" />Categories
      </h3>
      <p class="text-body-secondary mb-0">Browse products by category.</p>
    </div>

    <div v-if="loading" class="text-center py-5">
      <div class="loading-spinner">
        <CSpinner color="primary" />
      </div>
    </div>

    <div v-else-if="!categories.length" class="text-center py-5 empty-state">
      <div class="empty-icon-wrapper mb-3">
        <CIcon icon="cil-grid" size="3xl" />
      </div>
      <h4 class="fw-semibold">No categories available</h4>
      <p class="text-body-secondary">Check back later for new categories.</p>
    </div>

    <CRow v-else class="g-4 categories-grid">
      <CCol v-for="(cat, index) in categories" :key="cat.id" sm="6" lg="4" xl="3" class="category-col">
        <CCard class="category-card h-100" @click="viewCategory(cat.slug)">
          <div class="category-img-wrapper">
            <img
              v-if="cat.image_url"
              :src="`/storage/${cat.image_url}`"
              :alt="cat.name"
              class="category-img"
              loading="lazy"
              width="400"
              height="240"
            />
            <div v-else class="category-img-fallback">
              <CIcon icon="cil-grid" size="3xl" class="fallback-icon" />
            </div>
            <div class="category-overlay">
              <span class="overlay-text">
                <CIcon icon="cil-arrow-right" class="me-1" /> View Products
              </span>
            </div>
          </div>
          <CCardBody class="d-flex flex-column">
            <CCardTitle class="category-name mb-1">{{ cat.name }}</CCardTitle>
            <p class="category-desc text-body-secondary small flex-grow-1">
              {{ cat.description || 'Browse products in this category' }}
            </p>
            <div class="d-flex justify-content-between align-items-center mt-auto pt-2">
              <CBadge color="primary" class="category-count rounded-pill">
                {{ cat.products_count || 0 }} products
              </CBadge>
              <CIcon icon="cil-chevron-right" class="category-arrow" />
            </div>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>
  </div>
</template>

<style scoped>
.main-categories-page {
  animation: fadeUp 0.5s ease-out;
}

.categories-header {
  animation: fadeUp 0.5s ease-out 0.1s both;
}

.loading-spinner {
  padding: 3rem;
}

.empty-state {
  animation: fadeUp 0.6s ease-out;
}

.empty-icon-wrapper {
  display: inline-flex;
  padding: 1.2rem;
  border-radius: 20px;
  background: rgba(184, 19, 0, 0.06);
  color: var(--cui-primary, #b81300);
}

.categories-grid {
  animation: fadeUp 0.5s ease-out 0.2s both;
}

.category-col {
  animation: fadeUp 0.5s ease-out both;
}

.category-col:nth-child(1) { animation-delay: 0.1s; }
.category-col:nth-child(2) { animation-delay: 0.15s; }
.category-col:nth-child(3) { animation-delay: 0.2s; }
.category-col:nth-child(4) { animation-delay: 0.25s; }
.category-col:nth-child(5) { animation-delay: 0.3s; }
.category-col:nth-child(6) { animation-delay: 0.35s; }
.category-col:nth-child(7) { animation-delay: 0.4s; }
.category-col:nth-child(8) { animation-delay: 0.45s; }

.category-card {
  cursor: pointer;
  border: none;
  border-radius: 16px;
  overflow: hidden;
  background: var(--glass-bg);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid var(--glass-border);
  transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.category-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 24px 64px rgba(0, 0, 0, 0.1);
}

.category-card .card-body {
  padding: 0.9rem 1rem;
}

.category-img-wrapper {
  position: relative;
  height: 200px;
  overflow: hidden;
  background: var(--cui-tertiary-bg);
}

.category-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.7s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.category-card:hover .category-img {
  transform: scale(1.15);
}

.category-img-fallback {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, rgba(184, 19, 0, 0.04), rgba(51, 153, 255, 0.04));
}

.fallback-icon {
  color: var(--cui-primary, #b81300);
  opacity: 0.3;
}

.category-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: all 0.3s ease;
  backdrop-filter: blur(2px);
}

.category-card:hover .category-overlay {
  opacity: 1;
}

.overlay-text {
  color: #fff;
  font-weight: 600;
  font-size: 0.85rem;
  padding: 0.5rem 1.2rem;
  border-radius: 50px;
  background: rgba(255, 255, 255, 0.15);
  border: 1px solid rgba(255, 255, 255, 0.25);
  backdrop-filter: blur(4px);
  transform: translateY(10px);
  transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.category-card:hover .overlay-text {
  transform: translateY(0);
}

.category-name {
  font-size: 1rem;
  font-weight: 700;
  cursor: pointer;
  transition: color 0.2s ease;
  line-height: 1.35;
}

.category-card:hover .category-name {
  color: var(--cui-primary, #b81300);
}

.category-desc {
  font-size: 0.78rem;
  line-height: 1.5;
  opacity: 0.75;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.category-count {
  font-size: 0.7rem;
  font-weight: 600;
  letter-spacing: 0.02em;
  padding: 0.3rem 0.7rem;
}

.category-arrow {
  color: var(--cui-body-color);
  opacity: 0.3;
  transition: all 0.25s ease;
}

.category-card:hover .category-arrow {
  opacity: 1;
  color: var(--cui-primary, #b81300);
  transform: translateX(3px);
}

@keyframes fadeUp {
  from { opacity: 0; transform: translateY(30px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>
