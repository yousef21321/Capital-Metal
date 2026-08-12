let flyerId = 0

function cartTarget() {
  return document.querySelector('.floating-cart.cart-fly-zone') || document.querySelector('.cart-fly-zone')
}

function bumpCart() {
  const link = document.querySelector('.floating-cart')?.querySelector('.cart-fly-link')
    || document.querySelector('.cart-fly-link')
  if (!link) return
  link.classList.remove('cart-bump')
  void link.offsetWidth
  link.classList.add('cart-bump')
}

export function flyToCart(opts = {}) {
  const from = opts.from || null
  const imageSrc = opts.imageSrc || null

  const zone = cartTarget()
  if (!zone) return

  const target = zone.getBoundingClientRect()
  const start = from
    ? from.getBoundingClientRect()
    : {
        left: window.innerWidth / 2,
        top: window.innerHeight / 2,
        width: 0,
        height: 0,
      }

  const flyer = document.createElement('div')
  flyer.className = 'cart-flyer'
  flyer.dataset.flyer = String(flyerId++)

  if (imageSrc) {
    const img = document.createElement('img')
    img.src = imageSrc
    img.alt = ''
    flyer.appendChild(img)
  } else {
    flyer.innerHTML = '<span class="cart-flyer-icon">🛒</span>'
  }

  const startStyleLeft = start.left + start.width / 2
  const startStyleTop = start.top + start.height / 2
  flyer.style.left = `${startStyleLeft}px`
  flyer.style.top = `${startStyleTop}px`

  document.body.appendChild(flyer)

  requestAnimationFrame(() => {
    requestAnimationFrame(() => {
      flyer.style.left = `${target.left + target.width / 2}px`
      flyer.style.top = `${target.top + target.height / 2}px`
      flyer.style.transform = 'translate(-50%, -50%) scale(0.08)'
      flyer.style.opacity = '0.45'
    })
  })

  setTimeout(() => {
    flyer.remove()
    bumpCart()
  }, 760)
}