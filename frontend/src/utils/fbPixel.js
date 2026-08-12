const PIXEL_ID = import.meta.env.VITE_FACEBOOK_PIXEL_ID || ''

let started = false

function ensureFbq() {
  if (window.fbq) return window.fbq

  const fbq = function (...args) {
    fbq.callMethod ? fbq.callMethod.apply(fbq, args) : fbq.queue.push(args)
  }

  window._fbq = window.fbq = fbq
  fbq.push = fbq
  fbq.loaded = true
  fbq.version = '2.0'
  fbq.queue = []

  return fbq
}

export function fbPixelInit() {
  if (!PIXEL_ID || started) return
  started = true

  const fbq = ensureFbq()
  fbq('init', PIXEL_ID)
  fbq('track', 'PageView')

  const script = document.createElement('script')
  script.async = true
  script.src = 'https://connect.facebook.net/en_US/fbevents.js'
  document.head.appendChild(script)
}

export function fbTrack(event, params = {}) {
  if (!PIXEL_ID) return
  const fbq = window.fbq
  if (fbq) fbq('track', event, params)
}

export default {
  init: fbPixelInit,
  track: fbTrack,
  viewContent: (params) => fbTrack('ViewContent', params),
  addToCart: (params) => fbTrack('AddToCart', params),
  initiateCheckout: (params) => fbTrack('InitiateCheckout', params),
  purchase: (params) => fbTrack('Purchase', params),
  search: (params) => fbTrack('Search', params),
}