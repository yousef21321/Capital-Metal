#!/usr/bin/env python3
import json, os, sys
from pathlib import Path
import difflib
try:
    import pymysql
except Exception:
    print("PyMySQL not installed. Installing...")
    import subprocess
    subprocess.check_call([sys.executable, '-m', 'pip', 'install', '--no-cache-dir', 'PyMySQL'])
    import pymysql

DB_HOST = os.environ.get('DB_HOST','db')
DB_PORT = int(os.environ.get('DB_PORT','3306'))
DB_DATABASE = os.environ.get('DB_DATABASE','capital_metal')
DB_USER = os.environ.get('DB_USERNAME','root')
DB_PASSWORD = os.environ.get('DB_PASSWORD','root')

mapping_path = Path('/work/frontend/assets/images/product_images.json') if Path('/work/frontend/assets/images/product_images.json').exists() else Path('frontend/assets/images/product_images.json')
with open(mapping_path, 'r', encoding='utf-8') as f:
    mapping = json.load(f)

# Connect to DB
conn = pymysql.connect(host=DB_HOST, port=DB_PORT, user=DB_USER, password=DB_PASSWORD, db=DB_DATABASE, charset='utf8mb4', autocommit=True)
cur = conn.cursor()
cur.execute('SELECT id, name FROM products')
rows = cur.fetchall()
name_to_pid = {str(name).lower(): pid for pid, name in rows}
# also a list for fuzzy matching
names = [(pid, str(name)) for pid, name in rows]

# normalization helper
import unicodedata

def normalize(s: str) -> str:
    if s is None:
        return ''
    s = str(s).lower().strip()
    s = ''.join(ch for ch in s if unicodedata.category(ch)[0] != 'C')
    return s

out = {}
missing = []
for excel_name, imgs in mapping.items():
    if not isinstance(imgs, (list, tuple)):
        imgs = [imgs]
    key_norm = normalize(excel_name)
    pid = None
    # exact match first
    if key_norm in name_to_pid:
        pid = name_to_pid[key_norm]
    else:
        # fuzzy search over all product names
        best = None
        best_pid = None
        for pid_i, full_name in rows:
            full_norm = normalize(str(full_name))
            score = difflib.SequenceMatcher(None, key_norm, full_norm).ratio()
            if best is None or score > best:
                best = score
                best_pid = pid_i
        if best is not None and best > 0.6:
            pid = best_pid
        else:
            missing.append(excel_name)
            continue
    # Build image list
    paths = []
    for img in imgs:
        p = Path('/work/frontend/assets/images')/img
        if p.exists():
            paths.append(str(p))
    if not paths:
        continue
    out[str(pid)] = paths

out_path = Path('/work/frontend/assets/images/product_images_by_id.json')
with open(out_path, 'w', encoding='utf-8') as f:
    json.dump(out, f, ensure_ascii=False, indent=2)
print('WROTE', out_path)
if missing:
    print('Missing for:', missing)
