#!/usr/bin/env python3
import sys, json, os
from pathlib import Path
import argparse
import difflib
try:
    import pymysql
except Exception:
    print("PyMySQL not installed. It will be installed in Docker build.")
    import subprocess
    subprocess.check_call([sys.executable, '-m', 'pip', 'install', '--no-cache-dir', 'PyMySQL'])
    import pymysql

from openpyxl import load_workbook
import unicodedata


def normalize(s: str) -> str:
    if s is None:
        return ''
    s = str(s).lower().strip()
    s = ''.join(ch for ch in s if unicodedata.category(ch)[0] != 'C')
    s = s.replace('  ', ' ')
    return s


def read_mapping(mapping_path):
    with open(mapping_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    return data


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--mapping', required=True, help='path to product_images.json')
    ap.add_argument('--images_dir', required=True, help='path to images dir')
    ap.add_argument('--db_host', default='db')
    ap.add_argument('--db_port', type=int, default=3306)
    ap.add_argument('--db_database', default='capital_metal')
    ap.add_argument('--db_user', default='root')
    ap.add_argument('--db_password', default='root')
    ap.add_argument('--dry_run', action='store_true')
    ap.add_argument('--log', default='price_upload_images.log')
    args = ap.parse_args()

    mapping_path = args.mapping
    images_dir = Path(args.images_dir)
    if not images_dir.exists():
        print('Images dir not found', file=sys.stderr)
        sys.exit(1)

    mapping = read_mapping(mapping_path)

    # Build image list per product from mapping
    # Open connection
    conn = pymysql.connect(host=args.db_host, port=args.db_port, user=args.db_user, password=args.db_password, db=args.db_database, charset='utf8mb4', autocommit=True)
    cur = conn.cursor()

    # Fetch products: id, name
    cur.execute('SELECT id, name FROM products')
    rows = cur.fetchall()
    name_to_id = {}
    id_to_name = {}
    for pid, pname in rows:
        n = normalize(pname)
        name_to_id[n] = pid
        id_to_name[pid] = pname

    # Helper to safe_insert
    def image_path_for(filename):
        return f"frontend/assets/images/{filename}"

    # Prepare actions
    inserts = []
    duplicates = []
    for product_name, imgs in mapping.items():
        if not isinstance(imgs, list):
            imgs = [imgs]
        norm_name = normalize(product_name)
        pid = name_to_id.get(norm_name)
        if pid is None:
            # try fuzzy match
            best = None
            for nm, fid in name_to_id.items():
                score = difflib.SequenceMatcher(None, norm_name, nm).ratio()
                if best is None or score > best[0]:
                    best = (score, fid, nm)
            if best and best[0] > 0.6:
                pid = best[1]
                product_name = best[2]
            else:
                print(f"No product matched for: {product_name}")
                continue
        if not imgs:
            continue
        # For each image filename, insert if not exists
        for idx, img in enumerate(imgs):
            image_path = image_path_for(img)
            # skip if image file doesn't exist
            if not (images_dir / img).exists():
                print(f"Image file not found: {img}")
                continue
            # check if already present
            cur.execute("SELECT 1 FROM product_images WHERE product_id=%s AND image_path=%s", (pid, image_path))
            if cur.fetchone():
                continue
            # prepare insert
            inserts.append((pid, image_path, idx))

    print(f"Planned inserts: {len(inserts)}")
    with open(args.log, 'a', encoding='utf-8') as logf:
        logf.write(f"Dry_run={args.dry_run}\n")
        for pid, path, order in inserts:
            logf.write(f'ProductID {pid}, Image {path}, order {order}\n')
        if args.dry_run:
            print("DRY RUN: would insert images for products.")
            return

        # perform inserts
        for pid, path, order in inserts:
            cur.execute("INSERT INTO product_images (product_id, image_path, sort_order) VALUES (%s, %s, %s)", (pid, path, order))
        conn.commit()
        logf.write('Inserts committed.\n')
        print("DONE")

    cur.close()
    conn.close()

if __name__ == '__main__':
    main()
