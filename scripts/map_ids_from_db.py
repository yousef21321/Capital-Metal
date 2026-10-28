#!/usr/bin/env python3
import json, os
import sys
from pathlib import Path
import difflib
try:
    import pymysql
    DB_AVAILABLE = True
except Exception:
    DB_AVAILABLE = False
    print("PyMySQL not installed; attempting to install...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "--no-cache-dir", "PyMySQL"])
    import pymysql

from difflib import SequenceMatcher

mapping_path = Path('frontend/assets/images/product_images.json')
if not mapping_path.exists():
    mapping_path = Path('/work/frontend/assets/images/product_images.json') if Path('/work/frontend/assets/images/product_images.json').exists() else Path('frontend/assets/images/product_images.json')
print('Using mapping:', mapping_path)
with open(mapping_path, 'r', encoding='utf-8') as f:
    mapping = json.load(f)

host = os.environ.get('DB_HOST', 'db')
port = int(os.environ.get('DB_PORT', '3306'))
db = os.environ.get('DB_DATABASE', 'capital_metal')
user = os.environ.get('DB_USERNAME', 'root')
password = os.environ.get('DB_PASSWORD', 'root')

conn = pymysql.connect(host=host, port=port, user=user, password=password, db=db, charset='utf8mb4', autocommit=True)
cur = conn.cursor()
cur.execute('SELECT id, name FROM products')
rows = cur.fetchall()
name_by_norm = {}
for pid, pname in rows:
    name_by_norm[str(pname)].lower() if False else None
    norm = str(pname).lower().strip()
    name_by_norm[norm] = pid

# Prepare output mapping by id
out = {}
missing = []
for prod_name, imgs in mapping.items():
    if not isinstance(imgs, (list, tuple)):
        imgs = [imgs]
    norm_name = prod_name.strip().lower()
    # exact match first
    pid = name_by_norm.get(norm_name)
    if pid is None:
        # fuzzy match
        best = None
        for nm, pid_tmp in name_by_norm.items():
            score = SequenceMatcher(None, norm_name, nm).ratio()
            if best is None or score > best[0]:
                best = (score, pid_tmp, nm)
        if best and best[0] > 0.6:
            pid = best[1]
            prod_name = best[2]
        else:
            missing.append(prod_name)
            continue
    # build image paths
    paths = []
    for img in imgs:
        p = f"frontend/assets/images/{img}"
        if not Path(p).exists():
            continue
        paths.append(p)
    if not paths:
        continue
    out.setdefault(str(pid), []).extend(paths)

# Write output
out_path = Path('frontend/assets/images/product_images_by_id.json')
with open(out_path, 'w', encoding='utf-8') as f:
    json.dump(out, f, ensure_ascii=False, indent=2)
print('WROTE', out_path)
if missing:
    print('Missing for:', missing)
