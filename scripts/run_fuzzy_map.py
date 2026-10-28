#!/usr/bin/env python3
import json, os, sys
from pathlib import Path
import difflib
try:
    import pymysql
except Exception:
    print("PyMySQL not installed in container.")
    sys.exit(1)

DB_HOST = 'db'
DB_PORT = 3306
DB_DATABASE = 'capital_metal'
DB_USER = 'root'
DB_PASSWORD = 'root'

mapping_path = Path('/work/frontend/assets/images/product_images.json') if Path('/work/frontend/assets/images/product_images.json').exists() else Path('frontend/assets/images/product_images.json')
with open(mapping_path, 'r', encoding='utf-8') as f:
    mapping = json.load(f)

conn = pymysql.connect(host=DB_HOST, port=DB_PORT, user=DB_USER, password=DB_PASSWORD, db=DB_DATABASE, charset='utf8mb4')
cur = conn.cursor()
cur.execute('SELECT id, name FROM products')
rows = cur.fetchall()
id_to_name = {str(pid): str(name) for pid, name in rows}
name_norms = {str(pid): str(name).lower() for pid, name in rows}

# Build normalized map
from difflib import SequenceMatcher

def norm(s):
    import unicodedata
    if s is None:
        return ''
    s = str(s).lower()
    s = ''.join(ch for ch in s if unicodedata.category(ch)[0] != 'C')
    return s

results = {}
for excel_name in mapping.keys():
    key_norm = norm(excel_name)
    tops = []
    for pid, name in rows:
        pid_s = str(pid)
        nm = norm(name)
        score = SequenceMatcher(None, key_norm, nm).ratio()
        tops.append((score, pid, name))
    tops.sort(reverse=True, key=lambda x: x[0])
    results[excel_name] = [ { 'score': s, 'pid': pid, 'name': nm } for s, pid, nm in tops[:5] ]

print(json.dumps(results, ensure_ascii=False, indent=2))
cur.close(); conn.close()
