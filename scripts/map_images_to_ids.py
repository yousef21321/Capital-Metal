#!/usr/bin/env python3
import sys, json
from pathlib import Path
import difflib
import subprocess

DB_HOST = 'db'
DB_DATABASE = 'capital_metal'
DB_USER = 'root'
DB_PASSWORD = 'root'

MAPPING_PATH = Path('/work/frontend/assets/images/product_images.json') if Path('/work/frontend/assets/images/product_images.json').exists() else Path('frontend/assets/images/product_images.json')

# Attempt to fetch DB product list via mysql client; if not possible, fall back to reading existing files
try:
    import pymysql
    DB_AVAILABLE = True
except Exception:
    DB_AVAILABLE = False

# Load mapping
with open(MAPPING_PATH, 'r', encoding='utf-8') as f:
    mapping = json.load(f)

products = []  # list of (id, name, norm_name)
name_to_id = {}

def normalize(s: str) -> str:
    import unicodedata
    if s is None:
        return ''
    s = str(s).lower().strip()
    s = ''.join(ch for ch in s if unicodedata.category(ch)[0] != 'C')
    return s

# Try to fetch from DB if pymysql available and db reachable
if DB_AVAILABLE:
    try:
        import pymysql
        conn = pymysql.connect(host=DB_HOST, port=3306, user=DB_USER, password=DB_PASSWORD, db=DB_DATABASE, charset='utf8mb4', autocommit=True)
        cur = conn.cursor()
        cur.execute('SELECT id, name FROM products')
        for pid, pname in cur.fetchall():
            norm = normalize(pname)
            products.append((pid, pname, norm))
            name_to_id[norm] = pid
        cur.close()
        conn.close()
    except Exception as e:
        print(f"DB fetch failed: {e}", file=sys.stderr)
        products = []

# If DB fetch failed or empty, try to load from current known list by matching mapping keys to locally-known names
if not products:
    # Fallback: try to read titles from mapping keys and assign fake IDs sequentially
    pid = 1
    for prod_name in mapping.keys():
        norm = normalize(prod_name)
        products.append((pid, prod_name, norm))
        name_to_id[norm] = pid
        pid += 1

# Build ID -> images
out = {}
missing = []
for prod_name, imgs in mapping.items():
    if not isinstance(imgs, list):
        imgs = [imgs]
    norm = normalize(prod_name)
    pid = name_to_id.get(norm)
    if pid is None:
        # fuzzy match against known products
        best = None
        for p_norm, p_id in name_to_id.items():
            score = difflib.SequenceMatcher(None, norm, p_norm).ratio()
            if best is None or score > best[0]:
                best = (score, p_id, p_norm)
        if best and best[0] > 0.6:
            pid = best[1]
            prod_name = best[2]
        else:
            missing.append(prod_name)
            continue
    # Resolve image list
    valid = []
    for img in imgs:
        img_path = f"frontend/assets/images/{img}"
        if Path(img_path).exists():
            valid.append(img_path)
    if valid:
        out[str(pid)] = valid

# Write mapping by id
out_path = Path('/work/frontend/assets/images/product_images_by_id.json') if Path('/work/frontend/assets/images/product_images_by_id.json').exists() else Path('frontend/assets/images/product_images_by_id.json')
out_path.parent.mkdir(parents=True, exist_ok=True)
with open(out_path, 'w', encoding='utf-8') as f:
    json.dump(out, f, ensure_ascii=False, indent=2)
print(json.dumps(out, ensure_ascii=False, indent=2))
if missing:
    print("Missing mappings for:", missing, file=sys.stderr)
