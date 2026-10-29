#!/usr/bin/env python3
# Copy image+thumb from a matched product into image-less product dirs and insert DB rows.
import json, sys, os, shutil
from pathlib import Path
import subprocess

# Read match mapping: target_pid -> {match_pid, ...}
MATCH_FILE = sys.argv[1] if len(sys.argv) > 1 else '/tmp/match_good.json'
DEST_ROOT = Path('/home/ubuntu/Capital-Metal/backend/storage/app/public/products')

# DB helpers via docker
def db(sql, *args):
    # args escaped minimally; we don't interpolate user data except ints already validated
    cmd = ['docker', 'exec', 'capitalmetal_db', 'mysql', '-uroot', '-proot', '--default-character-set=utf8mb4', 'capital_metal', '-N', '-e', sql]
    r = subprocess.run(cmd, capture_output=True, text=True)
    return r.stdout, r.stderr

with open(MATCH_FILE, encoding='utf-8') as f:
    matches = json.load(f)

# For each match, fetch source product's image_url from DB
def fetch_image(pid):
    out, err = db(f"SELECT image_url FROM product_images WHERE product_id={pid} ORDER BY sort_order LIMIT 1;")
    lines = [l for l in out.strip().splitlines() if l.strip()]
    return lines[0].strip() if lines else None

done = []
skipped = []
for pid_str, info in matches.items():
    pid = int(pid_str)
    mp = int(info['match_pid'])
    src_rel = fetch_image(mp)
    if not src_rel:
        skipped.append((pid, mp, 'no source image row'))
        continue
    # src_rel like "products/102/product-15.png"
    src_img = DEST_ROOT / src_rel.split('/', 1)[1]  # strip "products/"
    src_thumb = src_img.parent / (src_img.stem + '_thumb.webp')
    if not src_img.exists():
        skipped.append((pid, mp, f'source file missing {src_img}'))
        continue
    dest_dir = DEST_ROOT / str(pid)
    dest_dir.mkdir(parents=True, exist_ok=True)
    dest_img = dest_dir / src_img.name
    dest_thumb = dest_dir / (dest_img.stem + '_thumb.webp')
    shutil.copy2(src_img, dest_img)
    if src_thumb.exists():
        shutil.copy2(src_thumb, dest_thumb)
    # Insert DB row (if not exists)
    out, err = db(f"SELECT 1 FROM product_images WHERE product_id={pid} AND image_url='products/{pid}/{dest_img.name}';")
    exists = bool(out.strip())
    if not exists:
        db(f"INSERT INTO product_images (product_id, image_url, sort_order) VALUES ({pid}, 'products/{pid}/{dest_img.name}', 0);")
    done.append((pid, mp, f'products/{pid}/{dest_img.name}'))

print('DONE matched=', len(done))
for pid, mp, url in done:
    print(f'  {pid} <- {mp}  {url}')
if skipped:
    print('SKIPPED:')
    for s in skipped:
        print('  ', s)