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


def read_prices_from_excel(excel_path):
    wb = load_workbook(excel_path, data_only=True)
    sheet = wb.active
    # Try to parse: Name in column A (1), Price likely in column C (3)
    prices = {}
    max_r = sheet.max_row
    for r in range(2, max_r+1):
        name_cell = sheet.cell(row=r, column=1).value
        price_cell = sheet.cell(row=r, column=3).value  # assume C is price
        if name_cell is None or price_cell is None:
            continue
        try:
            price = float(price_cell)
        except Exception:
            continue
        key = normalize(str(name_cell))
        prices[key] = price
    return prices


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--mapping', required=True, help='path to product_images.json')
    ap.add_argument('--excel', required=True, help='path to Excel with prices')
    ap.add_argument('--db_host', default='db')
    ap.add_argument('--db_port', type=int, default=3306)
    ap.add_argument('--db_database', default='capital_metal')
    ap.add_argument('--db_user', default='root')
    ap.add_argument('--db_password', default='root')
    ap.add_argument('--dry_run', action='store_true')
    ap.add_argument('--log', default='price_upload.log')
    args = ap.parse_args()

    mapping_path = args.mapping
    excel_path = args.excel

    # Load mapping: product name -> [image_files]
    with open(mapping_path, 'r', encoding='utf-8') as mf:
        price_map = json.load(mf)

    # Load prices from Excel
    price_by_norm_name = read_prices_from_excel(excel_path)

    # DB connection
    conn = pymysql.connect(host=args.db_host, port=args.db_port, user=args.db_user, password=args.db_password, db=args.db_database, charset='utf8mb4', autocommit=True)
    cur = conn.cursor()

    # Build product name to id map from DB for exact matching
    cur.execute('SELECT id, name FROM products')
    rows = cur.fetchall()
    name_to_id = {}
    for pid, pname in rows:
        name_to_id[normalize(pname)] = pid

    # Prepare updates via fuzzy matching if needed
    updates = []
    log_lines = []
    names_seen = set()
    for key_norm, price in price_by_norm_name.items():
        pid = name_to_id.get(key_norm)
        if pid is None:
            # fuzzy match against all names
            # Build list of (score, pid, full_name, norm)
            best = None
            for full, fid in rows:
                full_norm = normalize(full)
                score = difflib.SequenceMatcher(None, key_norm, full_norm).ratio()
                if best is None or score > best[0]:
                    best = (score, fid, full_norm)
            if best and best[0] > 0.6:
                pid = best[1]
                log_lines.append(f'Fuzzy matched {key_norm} to {best[2]} (score={best[0]:.2f}) -> id {pid}')
            else:
                log_lines.append(f'No product matched for name: {key_norm}')
                continue
        updates.append((price, pid, key_norm))
        names_seen.add(key_norm)

    with open(args.log, 'a', encoding='utf-8') as logf:
        logf.write(f"Dry_run={args.dry_run}\n")
        for price, pid, pname in updates:
            logf.write(f'Map: {pname} -> id {pid}, price {price}\n')
        for line in log_lines:
            logf.write(line + '\n')

        if args.dry_run:
            print('DRY RUN: would update', len(updates), 'products')
            for price, pid, pname in updates:
                print(f'Would set product {pid} price_egp={price}')
            print('Done (dry)')
            return

        # Execute updates
        for price, pid, pname in updates:
            cur.execute('UPDATE products SET price_egp = %s WHERE id = %s', (price, pid))
        logf.write('Updates committed.\n')
        print('DONE')

    cur.close()
    conn.close()

if __name__ == '__main__':
    main()
