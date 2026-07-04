import { h, resolveComponent } from 'vue'
import { createRouter, createWebHashHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

import DefaultLayout from '@/layouts/DefaultLayout'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: DefaultLayout,
    redirect: '/dashboard',
    meta: { requiresAuth: true },
    children: [
      {
        path: '/dashboard',
        name: 'Dashboard',
        component: () => import('@/views/dashboard/Dashboard.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: '/products',
        name: 'Products',
        component: () => import('@/views/ecommerce/Products.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: '/admin/products',
        name: 'AdminProducts',
        component: () => import('@/views/ecommerce/AdminProducts.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: '/cart',
        name: 'Cart',
        component: () => import('@/views/ecommerce/Cart.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: '/checkout',
        name: 'Checkout',
        component: () => import('@/views/ecommerce/Checkout.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: '/orders',
        name: 'Orders',
        component: () => import('@/views/ecommerce/Orders.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: '/wishlist',
        name: 'Wishlist',
        component: () => import('@/views/ecommerce/Wishlist.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: '/saved-cards',
        name: 'SavedCards',
        component: () => import('@/views/ecommerce/SavedCards.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: '/tickets',
        name: 'Tickets',
        component: () => import('@/views/tickets/TicketList.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: '/tickets/create',
        name: 'TicketCreate',
        component: () => import('@/views/tickets/TicketCreate.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: '/tickets/:id',
        name: 'TicketDetail',
        component: () => import('@/views/tickets/TicketDetail.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: '/tickets/available',
        name: 'DesignerQueue',
        component: () => import('@/views/tickets/DesignerQueue.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: '/tickets/negotiations',
        name: 'ReviewQueue',
        component: () => import('@/views/tickets/ReviewQueue.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: '/tickets/qa-queue',
        name: 'QAQueue',
        component: () => import('@/views/tickets/QAQueue.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: '/admin/approvals',
        name: 'AdminApprovals',
        component: () => import('@/views/tickets/AdminApprovals.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: '/designer/products/create',
        name: 'DesignerProductCreate',
        component: () => import('@/views/tickets/DesignerProductCreate.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: '/plans',
        name: 'Plans',
        component: () => import('@/views/tickets/Plans.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: '/theme',
        name: 'Theme',
        redirect: '/theme/typography',
      },
      {
        path: '/theme/colors',
        name: 'Colors',
        component: () => import('@/views/theme/Colors.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: '/theme/typography',
        name: 'Typography',
        component: () => import('@/views/theme/Typography.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: '/base',
        name: 'Base',
        component: {
          render() {
            return h(resolveComponent('router-view'))
          },
        },
        redirect: '/base/breadcrumbs',
        meta: { requiresAuth: true },
        children: [
          {
            path: '/base/accordion',
            name: 'Accordion',
            component: () => import('@/views/base/Accordion.vue'),
          },
          {
            path: '/base/breadcrumbs',
            name: 'Breadcrumbs',
            component: () => import('@/views/base/Breadcrumbs.vue'),
          },
          {
            path: '/base/cards',
            name: 'Cards',
            component: () => import('@/views/base/Cards.vue'),
          },
          {
            path: '/base/carousels',
            name: 'Carousels',
            component: () => import('@/views/base/Carousels.vue'),
          },
          {
            path: '/base/chips',
            name: 'Chips',
            component: () => import('@/views/base/Chips.vue'),
          },
          {
            path: '/base/collapses',
            name: 'Collapses',
            component: () => import('@/views/base/Collapses.vue'),
          },
          {
            path: '/base/list-groups',
            name: 'List Groups',
            component: () => import('@/views/base/ListGroups.vue'),
          },
          {
            path: '/base/navs',
            name: 'Navs',
            component: () => import('@/views/base/Navs.vue'),
          },
          {
            path: '/base/paginations',
            name: 'Paginations',
            component: () => import('@/views/base/Paginations.vue'),
          },
          {
            path: '/base/placeholders',
            name: 'Placeholders',
            component: () => import('@/views/base/Placeholders.vue'),
          },
          {
            path: '/base/popovers',
            name: 'Popovers',
            component: () => import('@/views/base/Popovers.vue'),
          },
          {
            path: '/base/progress',
            name: 'Progress',
            component: () => import('@/views/base/Progress.vue'),
          },
          {
            path: '/base/spinners',
            name: 'Spinners',
            component: () => import('@/views/base/Spinners.vue'),
          },
          {
            path: '/base/tables',
            name: 'Tables',
            component: () => import('@/views/base/Tables.vue'),
          },
          {
            path: '/base/tabs',
            name: 'Tabs',
            component: () => import('@/views/base/Tabs.vue'),
          },
          {
            path: '/base/tooltips',
            name: 'Tooltips',
            component: () => import('@/views/base/Tooltips.vue'),
          },
        ],
      },
      {
        path: '/buttons',
        name: 'Buttons',
        component: {
          render() {
            return h(resolveComponent('router-view'))
          },
        },
        redirect: '/buttons/standard-buttons',
        meta: { requiresAuth: true },
        children: [
          {
            path: '/buttons/standard-buttons',
            name: 'Button Component',
            component: () => import('@/views/buttons/Buttons.vue'),
          },
          {
            path: '/buttons/dropdowns',
            name: 'Dropdowns',
            component: () => import('@/views/buttons/Dropdowns.vue'),
          },
          {
            path: '/buttons/button-groups',
            name: 'Button Groups',
            component: () => import('@/views/buttons/ButtonGroups.vue'),
          },
        ],
      },
      {
        path: '/forms',
        name: 'Forms',
        component: {
          render() {
            return h(resolveComponent('router-view'))
          },
        },
        redirect: '/forms/form-control',
        meta: { requiresAuth: true },
        children: [
          {
            path: '/forms/form-control',
            name: 'Form Control',
            component: () => import('@/views/forms/FormControl.vue'),
          },
          {
            path: '/forms/select',
            name: 'Select',
            component: () => import('@/views/forms/Select.vue'),
          },
          {
            path: '/forms/checks-radios',
            name: 'Checks & Radios',
            component: () => import('@/views/forms/ChecksRadios.vue'),
          },
          {
            path: '/forms/chip-input',
            name: 'Chip Input',
            component: () => import('@/views/forms/ChipInput.vue'),
          },
          {
            path: '/forms/range',
            name: 'Range',
            component: () => import('@/views/forms/Range.vue'),
          },
          {
            path: '/forms/input-group',
            name: 'Input Group',
            component: () => import('@/views/forms/InputGroup.vue'),
          },
          {
            path: '/forms/floating-labels',
            name: 'Floating Labels',
            component: () => import('@/views/forms/FloatingLabels.vue'),
          },
          {
            path: '/forms/layout',
            name: 'Layout',
            component: () => import('@/views/forms/Layout.vue'),
          },
          {
            path: '/forms/validation',
            name: 'Validation',
            component: () => import('@/views/forms/Validation.vue'),
          },
        ],
      },
      {
        path: '/charts',
        name: 'Charts',
        component: () => import('@/views/charts/Charts.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: '/icons',
        name: 'Icons',
        component: {
          render() {
            return h(resolveComponent('router-view'))
          },
        },
        redirect: '/icons/coreui-icons',
        meta: { requiresAuth: true },
        children: [
          {
            path: '/icons/coreui-icons',
            name: 'CoreUI Icons',
            component: () => import('@/views/icons/CoreUIIcons.vue'),
          },
          {
            path: '/icons/brands',
            name: 'Brands',
            component: () => import('@/views/icons/Brands.vue'),
          },
          {
            path: '/icons/flags',
            name: 'Flags',
            component: () => import('@/views/icons/Flags.vue'),
          },
        ],
      },
      {
        path: '/notifications',
        name: 'Notifications',
        component: {
          render() {
            return h(resolveComponent('router-view'))
          },
        },
        redirect: '/notifications/alerts',
        meta: { requiresAuth: true },
        children: [
          {
            path: '/notifications/alerts',
            name: 'Alerts',
            component: () => import('@/views/notifications/Alerts.vue'),
          },
          {
            path: '/notifications/badges',
            name: 'Badges',
            component: () => import('@/views/notifications/Badges.vue'),
          },
          {
            path: '/notifications/modals',
            name: 'Modals',
            component: () => import('@/views/notifications/Modals.vue'),
          },
          {
            path: '/notifications/toasts',
            name: 'Toasts',
            component: () => import('@/views/notifications/Toasts.vue'),
          },
        ],
      },
      {
        path: '/widgets',
        name: 'Widgets',
        component: () => import('@/views/widgets/Widgets.vue'),
        meta: { requiresAuth: true },
      },
    ],
  },
  {
    path: '/pages',
    redirect: '/pages/404',
    name: 'Pages',
    component: {
      render() {
        return h(resolveComponent('router-view'))
      },
    },
    children: [
      {
        path: '404',
        name: 'Page404',
        component: () => import('@/views/pages/Page404'),
      },
      {
        path: '500',
        name: 'Page500',
        component: () => import('@/views/pages/Page500'),
      },
      {
        path: 'login',
        name: 'Login',
        component: () => import('@/views/pages/Login'),
        meta: { guest: true },
      },
      {
        path: 'register',
        name: 'Register',
        component: () => import('@/views/pages/Register'),
        meta: { guest: true },
      },
      {
        path: 'payment/callback',
        name: 'PaymentCallback',
        component: () => import('@/views/pages/PaymentCallback'),
      },
      {
        path: 'refund-policy',
        name: 'RefundPolicy',
        component: () => import('@/views/pages/RefundPolicy'),
      },
      {
        path: 'privacy-policy',
        name: 'PrivacyPolicy',
        component: () => import('@/views/pages/PrivacyPolicy'),
      },
      {
        path: 'shipping-policy',
        name: 'ShippingPolicy',
        component: () => import('@/views/pages/ShippingPolicy'),
      },
      {
        path: 'contact',
        name: 'ContactUs',
        component: () => import('@/views/pages/ContactUs'),
      },
    ],
  },
]

const router = createRouter({
  history: createWebHashHistory(import.meta.env.BASE_URL),
  routes,
  scrollBehavior() {
    return { top: 0 }
  },
})

router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()

  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next({ path: '/pages/login' })
  } else if (to.meta.guest && authStore.isAuthenticated) {
    next({ path: '/dashboard' })
  } else {
    next()
  }
})

export default router
