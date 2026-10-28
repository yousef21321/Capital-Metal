#!/usr/bin/env python3
import json, os
from pathlib import Path
import difflib
try:
    import pymysql
    DB_AVAILABLE = True
except Exception:
    DB_AVAILABLE = False

from difflib import SequenceMatcher

def main():
    mapping_path = Path('frontend/assets/images/product_images.json')
    if not mapping_path.exists():
        print('Mapping file not found')
        return
    with open(mapping_path, 'r', encoding='utf-8') as f:
        mapping = json.load(f)
    # DB connection
    host = os.environ.get('DB_HOST','db')
    port = int(os.environ.get('DB_PORT','3306'))
    database = os.environ.get('DB_DATABASE','capital_metal')
    user = os.environ.get('DB_USERNAME','root')
    password = os.environ.get('DB_PASSWORD','root')

    candidates = {}
    if not DB_AVAILABLE:
        print('DB not available in this environment')
        # Fall back to printing fuzzy matches to local list (no DB). We'll print just mapping keys.
        for prod in mapping.keys():
            candidates[prod] = []
        print(json.dumps(candidates, ensure_ascii=False, indent=2))
        return

    conn = pymysql.connect(host=host, port=port, user=user, password=password, db=database, charset='utf8mb4', autocommit=True)
    cur = conn.cursor()
    cur.execute('SELECT id, name FROM products')
    rows = cur.fetchall()
    pid_to_name = {str(pid): pname for pid, pname in rows}
    norm_name_map = {str(pid): pname for pid, pname in rows}
    # Build dict of normalized name -> id
    name_to_id = {}
    for pid, pname in rows:
        name_to_id[str(pname).lower().strip()] = pid
    # For each mapping key, compute top 5 matches
    for prod_name in mapping.keys():
        key_norm = prod_name.strip().lower()
        tops = []
        for pname, pid in pid_to_name.items():
            norm = str(pname).strip().lower()
            score = SequenceMatcher(None, key_norm, norm).ratio()
            tops.append((score, pid, pname))
        tops.sort(reverse=True, key=lambda x: x[0])
        tops = tops[:5]
        candidates[prod_name] = tops
    print(json.dumps(candidates, ensure_ascii=False, indent=2))

if __name__ == '__main__':
    main()
