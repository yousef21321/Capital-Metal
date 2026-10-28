#!/usr/bin/env python3
import json
import difflib
import sys
from pathlib import Path
import unicodedata
try:
    import pymysql
except Exception:
    pymysql = None

def normalize(s: str) -> str:
    if s is None:
        return ''
    s = str(s).lower().strip()
    s = ''.join(ch for ch in s if unicodedata.category(ch)[0] != 'C')
    return s

# Load mapping from Excel
mapping_path = Path('frontend/assets/images/product_images.json')
with open(mapping_path, 'r', encoding='utf-8') as f:
    mapping = json.load(f)

# Get DB names if possible
db_names = []
pid_name = []
if pymysql is not None:
    try:
        host = 'db'
        cur_host = host
        import pymysql
        conn = pymysql.connect(host=cur_host, user='root', password='root', database='capital_metal', port=3306, charset='utf8mb4')
        cur = conn.cursor()
        cur.execute('SELECT id, name FROM products')
        for pid, pname in cur.fetchall():
            db_names.append((pid, pname))
        conn.close()
    except Exception as e:
        print('DB fetch failed:', e, file=sys.stderr)
        db_names = []

# Build matches per Excel product
def score(p, q):
    return difflib.SequenceMatcher(None, normalize(p), normalize(q)).ratio()

candidates = {}
for excel_name, imgs in mapping.items():
    bests = []
    for pid, pname in db_names:
        s = score(excel_name, pname)
        bests.append((s, pid, pname))
    bests.sort(reverse=True)
    candidates[excel_name] = bests[:3]

print(json.dumps(candidates, ensure_ascii=False, indent=2))

# Additionally write a candidate by-id mapping template (empty) to help user customize
Path('frontend/assets/images/product_images_by_id.json').write_text
print('Done')
