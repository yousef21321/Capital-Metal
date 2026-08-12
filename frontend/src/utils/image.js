export function imageUrl(path) {
  if (!path) return ''
  return `/storage/${path}`
}

export function thumbImageUrl(image) {
  if (!image) return ''
  const thumb = image.image_url_thumb || image.thumb_url
  if (thumb) return imageUrl(thumb)
  return imageUrl(image.image_url)
}

export function imageSrcSet(image, { thumb = 480, full = 1200 } = {}) {
  const fullUrl = imageUrl(image?.image_url)
  if (!fullUrl) return ''
  const thumbUrl = image?.image_url_thumb ? imageUrl(image.image_url_thumb) : null
  if (!thumbUrl || thumbUrl === fullUrl) return fullUrl
  return `${thumbUrl} ${thumb}w, ${fullUrl} ${full}w`
}
