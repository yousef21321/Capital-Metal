#!/usr/bin/env python3
import os
from pathlib import Path
import shutil
import subprocess

SRC_JSON = Path('/home/ubuntu/Capital-Metal/frontend/assets/images/product_images.json')
if not SRC_JSON.exists():
    SRC_JSON = Path('/work/frontend/assets/images/product_images.json')

# Load mapping
import json
with open(SRC_JSON, 'r', encoding='utf-8') as f:
    mapping = json.load(f)

DEST_ROOT = Path('/home/ubuntu/Capital-Metal/backend/storage/app/public/products')
DEST_ROOT.mkdir(parents=True, exist_ok=True)
SRC_ROOT = Path('/home/ubuntu/Capital-Metal')

updated = 0
missing = []
for pid, imgs in mapping.items():
    prod_dir = DEST_ROOT/str(pid)
    prod_dir.mkdir(parents=True, exist_ok=True)
    new_images = []
    if not isinstance(imgs, list):
        imgs = [imgs]
    for idx, img_rel in enumerate(imgs):
        src = SRC_ROOT/img_rel
        if not src.exists():
            missing.append(str(img_rel))
            continue
        basename = src.name
        dst = prod_dir/basename
        shutil.copy2(src, dst)
        # thumb generation: try PIL, else use ImageMagick
        name_wo_ext = os.path.splitext(basename)[0]
        thumb_name = f"{name_wo_ext}_thumb.webp"
        thumb_dst = prod_dir/thumb_name
        thumb_created = False
        # Try PIL
        try:
            from PIL import Image
            with Image.open(dst) as im:
                im_thumb = im.copy()
                im_thumb.thumbnail((256,256))
                im_thumb.save(thumb_dst, format='WEBP', quality=85)
                thumb_created = True
        except Exception:
            pass
        if not thumb_created:
            magick = shutil.which('magick') or shutil.which('convert')
            if magick:
                res = subprocess.run([magick, str(dst), '-resize', '256x256', str(thumb_dst)], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                if res.returncode == 0:
                    thumb_created = True
        if not thumb_created:
            # fallback: touch empty thumb to indicate
            thumb_dst.parent.mkdir(parents=True, exist_ok=True)
            with open(thumb_dst, 'wb') as f:
                pass
        new_images.append({
            'image_url': f"/storage/products/{pid}/{basename}",
            'image_url_thumb': f"/storage/products/{pid}/{thumb_name}",
            'sort_order': idx
        })
        updated += 1
    # write back per product as mapping of id to list of image URLs
    mapping[str(pid)] = [d['image_url'] for d in new_images]

# Write updated mapping (absolute URLs)
with open(SRC_JSON, 'w', encoding='utf-8') as f:
    json.dump(mapping, f, ensure_ascii=False, indent=2)
print('Moved images and thumbnails. Updated', updated, 'images.')
if missing:
    print('Missing sources:', missing[:10], '...')
