#!/usr/bin/env python3
import json
from pathlib import Path
# We'll map IDs 86..111 to the 26 images by order as discussed
ids = list(range(86, 112))  # 26 ids
images = [
  'frontend/assets/images/2026.jpeg',
  'frontend/assets/images/product-2.png',
  'frontend/assets/images/product-3.png',
  'frontend/assets/images/product-4.jpeg',
  'frontend/assets/images/item.png',
  'frontend/assets/images/product-6.png',
  'frontend/assets/images/product-7.png',
  'frontend/assets/images/product-8.png',
  'frontend/assets/images/product-9.png',
  'frontend/assets/images/product-10.jpeg',
  'frontend/assets/images/product-11.jpg',
  'frontend/assets/images/product-12.jpeg',
  'frontend/assets/images/product-13.png',
  'frontend/assets/images/product-14.png',
  'frontend/assets/images/product-15.png',
  'frontend/assets/images/product-16.png',
  'frontend/assets/images/product-17.png',
  'frontend/assets/images/product-18.jpeg',
  'frontend/assets/images/product-19.png',
  'frontend/assets/images/product-20.jpeg',
  'frontend/assets/images/item-1.png',
  'frontend/assets/images/product-22.png',
  'frontend/assets/images/product-23.png',
  'frontend/assets/images/product-24.png',
  'frontend/assets/images/product-25.png',
  'frontend/assets/images/product-26.png',
]
mapping = {}
for i, pid in enumerate(ids):
    img = images[i]
    mapping[str(pid)] = [img]
# Write to file used by uploader
out_path = Path('/work/frontend/assets/images/product_images_by_id.json') if Path('/work/frontend/assets/images/product_images_by_id.json').exists() else Path('frontend/assets/images/product_images_by_id.json')
out_path.parent.mkdir(parents=True, exist_ok=True)
with open(out_path, 'w', encoding='utf-8') as f:
    json.dump(mapping, f, ensure_ascii=False, indent=2)
print('WROTE mapping_by_id.json to', out_path)
