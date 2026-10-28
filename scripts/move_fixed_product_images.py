#!/usr/bin/env python3
import json, os
from pathlib import Path
import shutil
from PIL import Image

# mapping file (IDs -> list of image src relative paths)
MAPPING_PATH = Path('/home/ubuntu/Capital-Metal/frontend/assets/images/product_images_by_id.json')
if not MAPPING_PATH.exists():
    MAPPING_PATH = Path('/work/frontend/assets/images/product_images_by_id.json')

def main():
    if not MAPPING_PATH.exists():
        print('Mapping by id not found', file=sys.stderr)
        return
    with open(MAPPING_PATH, 'r', encoding='utf-8') as f:
        mapping = json.load(f)
    dest_root = Path('/home/ubuntu/Capital-Metal/backend/storage/app/public/products')
    moves = 0
    thumbnails = 0
    for pid_str, imgs in mapping.items():
        pid = int(pid_str)
        dest_dir = dest_root / str(pid)
        dest_dir.mkdir(parents=True, exist_ok=True)
        # ensure imgs is a list
        if not isinstance(imgs, (list, tuple)):
            imgs = [imgs]
        new_images = []
        for idx, img_rel in enumerate(imgs):
            src = Path('/home/ubuntu/Capital-Metal') / img_rel
            if not src.exists():
                print(f'Source not found: {src}', flush=True)
                continue
            dst = dest_dir / src.name
            shutil.copy2(src, dst)
            # thumbnail
            base = dst.stem
            thumb_dst = dest_dir / f"{base}_thumb.webp"
            try:
                with Image.open(dst) as im:
                    im_thumb = im.copy()
                    im_thumb.thumbnail((256,256))
                    im_thumb.save(thumb_dst, format='WEBP', quality=85)
            except Exception:
                # fallback: create empty thumb
                thumb_dst.parent.mkdir(parents=True, exist_ok=True)
                with open(thumb_dst, 'wb') as f:
                    f.write(b'')
            new_images.append({
                'image_url': f"/storage/products/{pid}/{dst.name}",
                'image_url_thumb': f"/storage/products/{pid}/{thumb_dst.name}",
                'sort_order': idx
            })
            moves += 1
            thumbnails += 1
        # update mapping to point to new URLs
        mapping[str(pid)] = [d['image_url'] for d in new_images]

    # write updated mapping (relative to /storage)
    with open(MAPPING_PATH, 'w', encoding='utf-8') as f:
        json.dump(mapping, f, ensure_ascii=False, indent=2)
    print('DONE moves=', moves, 'thumbs=', thumbnails)

if __name__ == '__main__':
    main()
