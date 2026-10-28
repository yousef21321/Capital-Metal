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

mapping_path = Path('frontend/assets/images/product_images.json')
print('Using mapping:', mapping_path)
with open(mapping_path, 'r', encoding='utf-8') as f:
    mapping = json.load(f)

# Connect to DB
try:
    conn = pymysql.connect(host=DB_HOST, port=DB_PORT, user=DB_USER, password=DB_PASSWORD, db=DB_DATABASE, charset='utf8mb4', autocommit=True)
    cur = conn.cursor()
    cur.execute('SELECT id, name FROM products')
    rows = cur.fetchall()
except Exception as e:
    print(f'DB connection failed: {e}', file=sys.stderr)
    sys.exit(1)

# Build maps
name_to_id = {}
for pid, pname in rows:
    name_to_id[str(pname).lower().strip()] = pid

from difflib import SequenceMatcher

def norm(s):
    import unicodedata
    if s is None:
        return ''
    s = str(s).lower().strip()
    s = ''.join(ch for ch in s if unicodedata.category(ch)[0] != 'C')
    return s

output = {}
for excel_name in mapping.keys():
    key_norm = norm(excel_name)
    bests = []
    for pname, pid in rows:
        nm = norm(pname)
        score = SequenceMatcher(None, key_norm, nm).ratio()
        bests.append((score, pid, pname))
    bests.sort(reverse=True, key=lambda x: x[0])
    top5 = bests[:5]
    output[excel_name] = [{"score": s, "pid": pid, "name": pname} for s, pid, pname in top5]

print(json.dumps(output, ensure_ascii=False, indent=2))

cur.close()
conn.close()
