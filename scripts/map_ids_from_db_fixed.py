#!/usr/bin/env python3
import json, os
from pathlib import Path
import difflib
try:
    import pymysql
except Exception:
    print("PyMySQL not installed. It will be installed in Docker build.")
    import subprocess
    subprocess.check_call(["python3", "-m", "pip", "install", "--no-cache-dir", "PyMySQL"])
    import pymysql

# Normalize helper
import unicodedata

def normalize(s: str) -> str:
    if s is None:
        return ''
    s = str(s).lower().strip()
    s = ''.join(ch for ch in s if unicodedata.category(ch)[0] != 'C')
    return s

DB_HOST = os.environ.get('DB_HOST','db')
DB_PORT = int(os.environ.get('DB_PORT','3306'))
DB_DATABASE = os.environ.get('DB_DATABASE','capital_metal')
DB_USER = os.environ.get('DB_USERNAME','root')
DB_PASSWORD = os.environ.get('DB_PASSWORD','root')

mapping_path = Path('frontend/assets/images/product_images.json')
if not mapping_path.exists():
    mapping_path = Path('/work/frontend/assets/images/product_images.json') if Path('/work/frontend/assets/images/product_images.json').exists() else Path('frontend/assets/images/product_images.json')

with open(mapping_path, 'r', encoding='utf-8') as mf:
    mapping = json.load(mf)

# Fetch products from DB
conn = pymysql.connect(host=DB_HOST, port=DB_PORT, user=DB_USER, password=DB_PASSWORD, db=DB_DATABASE, charset='utf8mb4', autocommit=True)
cur = conn.cursor()
cur.execute('SELECT id, name FROM products')
rows = cur.fetchall()
name_to_id = {}
for pid, pname in rows:
    norm = normalize(pname)
    name_to_id[norm] = pid

# Build mapping by id
out = {}
missing = []
import subprocess
from difflib import SequenceMatcher

for prod_name, imgs in mapping.items():
    if not isinstance(imgs, (list, tuple)):
        imgs = [imgs]
    key_norm = normalize(prod_name)
    pid = name_to_id.get(key_norm)
    if pid is None:
        best = None
        for nm, fid in name_to_id.items():
            score = SequenceMatcher(None, key_norm, nm).ratio()
            if best is None or score > best[0]:
                best = (score, fid, nm)
        if best and best[0] > 0.6:
            pid = best[1]
            prod_name = best[2]
        else:
            missing.append(prod_name)
            continue
    paths = []
    for img in imgs:
        img_path = f"frontend/assets/images/{img}"
        if Path(img_path).exists():
            paths.append(img_path)
    if not paths:
        continue
    out[str(pid)] = paths

# Save mapping_by_id.json
out_path = Path('frontend/assets/images/product_images_by_id.json')
with open(out_path, 'w', encoding='utf-8') as f:
    json.dump(out, f, ensure_ascii=False, indent=2)
print('WROTE', out_path)
if missing:
    print('Missing for:', missing)
    
