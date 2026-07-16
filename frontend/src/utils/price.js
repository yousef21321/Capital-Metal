import { useAuthStore } from '@/stores/auth'

export function formatPrice(amount, decimals = 2) {
  const auth = useAuthStore()
  const val = parseFloat(amount || 0)
  const currency = auth.userCurrency || 'EGP'
  if (currency === 'USD') {
    const rate = auth.exchangeRate || 30
    return `${(val / rate).toFixed(decimals)} USD`
  }
  return `${val.toFixed(decimals)} EGP`
}

export function formatProductPrice(product) {
  if (!product) return 'Free'
  const auth = useAuthStore()
  const currency = auth.userCurrency || 'EGP'
  const rate = auth.exchangeRate || 30

  if (currency === 'USD') {
    if (parseFloat(product.price_usd) > 0) {
      return `${parseFloat(product.price_usd).toFixed(2)} USD`
    }
    if (parseFloat(product.price_egp) > 0) {
      return `${(parseFloat(product.price_egp) / rate).toFixed(2)} USD`
    }
    return 'Free'
  }

  if (parseFloat(product.price_egp) > 0) {
    return `${parseFloat(product.price_egp).toFixed(2)} EGP`
  }
  if (parseFloat(product.price_usd) > 0) {
    return `${(parseFloat(product.price_usd) * rate).toFixed(2)} EGP`
  }
  return 'Free'
}

export function convertPrice(egpAmount) {
  const auth = useAuthStore()
  const amount = parseFloat(egpAmount || 0)
  if (auth.userCurrency === 'USD') {
    const rate = auth.exchangeRate || 30
    return parseFloat((amount / rate).toFixed(2))
  }
  return parseFloat(amount.toFixed(2))
}
