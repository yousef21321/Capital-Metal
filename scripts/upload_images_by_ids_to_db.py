#!/usr/bin/env python3
import json
from pathlib import Path
import sys
try:
    import pymysql
except Exception:
    print("PyMySQL not installed. Installing...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "--no-cache-dir", "PyMySQL"])
    import pymysql
import os

def main():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('--mapping_by_id', required=True,
                    help='path to product_images_by_id.json (id -> [image paths])')
    ap.add_argument('--db_host', default='db')
    ap.add_argument('--db_port', type=int, default=3306)
    ap.add_argument('--db_database', default='capital_metal')
    ap.add_argument('--db_user', default='root')
    ap.add_argument('--db_password', default='root')
    ap.add_argument('--images_dir', default='frontend/assets/images')
    ap.add_argument('--dry_run', action='store_true')
    ap.add_argument('--log', default='upload_images_by_id.log')
    args = ap.parse_args()

    mapping_path = Path(args.mapping_by_id)
    if not mapping_path.exists():
        print('Mapping file not found', file=sys.stderr)
        sys.exit(1)
    with open(mapping_path, 'r', encoding='utf-8') as f:
        mapping_by_id = json.load(f)

    # Connect to DB
    conn = pymysql.connect(host=args.db_host, port=args.db_port, user=args.db_user, password=args.db_password, db=args.db_database, charset='utf8mb4', autocommit=True)
    cur = conn.cursor()

    inserts = []
    log_lines = []

    for pid_str, images in mapping_by_id.items():
        pid = int(pid_str)
        if not isinstance(images, list):
            images = [images]
        for idx, img_path in enumerate(images):
            # ensure file exists
            p = Path(img_path)
            if not p.exists():
                log_lines.append(f'Image not found: {img_path}')
                continue
            # check existence
            cur.execute('SELECT 1 FROM product_images WHERE product_id=%s AND image_url=%s', (pid, img_path))
            if cur.fetchone():
                continue
            inserts.append((pid, img_path, idx))

    with open(args.log, 'a', encoding='utf-8') as logf:
        logf.write(f'Dry_run={args.dry_run}\n')
        for pid, path, order in inserts:
            logf.write(f'INSERT product_id={pid}, path={path}, order={order}\n')
        if args.dry_run:
            print('DRY RUN: would insert', len(inserts), 'rows')
            for pid, path, order in inserts:
                print(f'Would insert into product_images: ({pid}, {path}, {order})')
            return
        for pid, path, order in inserts:
            cur.execute('INSERT INTO product_images (product_id, image_url, sort_order) VALUES (%s, %s, %s)', (pid, path, order))
        conn.commit()
        logf.write('Inserts committed.\n')
        print('DONE')

    cur.close()
    conn.close()

if __name__ == '__main__':
    main()
