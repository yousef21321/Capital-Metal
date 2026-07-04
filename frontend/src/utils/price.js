import { useAuthStore } from '@/stores/auth'

export function formatPrice(egpAmount, decimals = 2) {
  const auth = useAuthStore()
  const amount = parseFloat(egpAmount || 0)
  if (auth.userCurrency === 'USD') {
    const rate = auth.exchangeRate || 30
    return `${(amount / rate).toFixed(decimals)} ${auth.userCurrency}`
  }
  return `${amount.toFixed(decimals)} ${auth.userCurrency}`
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
