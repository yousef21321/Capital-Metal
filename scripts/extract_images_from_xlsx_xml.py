#!/usr/bin/env python3
import sys, os, json, re, zipfile, shutil, xml.etree.ElementTree as ET

def slugify(s: str) -> str:
    s = s.strip().lower()
    s = re.sub(r'[^a-z0-9]+', '-', s)
    s = re.sub(r'-+', '-', s)
    s = s.strip('-')
    return s or 'item'

def read_product_names_from_xlsx(xlsx_path):
    # Parse xl/sharedStrings.xml and xl/worksheets/sheet1.xml to extract A-column values
    ns = '{http://schemas.openxmlformats.org/spreadsheetml/2006/main}'
    with zipfile.ZipFile(xlsx_path, 'r') as z:
        # read shared strings
        sst = z.read('xl/sharedStrings.xml') if 'xl/sharedStrings.xml' in z.namelist() else b''
        strings = []
        if sst:
            root = ET.fromstring(sst)
            for si in root.iter(ns + 'si'):
                parts = []
                for t in si.iter(ns + 't'):
                    parts.append(t.text or '')
                strings.append(''.join(parts))
        # read sheet1
        sheet_xml = None
        if 'xl/worksheets/sheet1.xml' in z.namelist():
            sheet_xml = z.read('xl/worksheets/sheet1.xml')
        if sheet_xml is None:
            return []
        sheet_root = ET.fromstring(sheet_xml)
        sheet_ns = {'ns': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}
        sheetData = sheet_root.find('ns:sheetData', sheet_ns)
        product_names = []
        if sheetData is None:
            return []
        for row in sheetData.findall('ns:row', sheet_ns):
            # find first cell in this row with column A (r attribute starting with 'A')
            a_cell = None
            for c in row.findall('ns:c', sheet_ns):
                r_attr = c.attrib.get('r','')
                if r_attr.startswith('A'):
                    a_cell = c
                    break
            if a_cell is None:
                # try to find any first cell in row
                first = row.find('ns:c', sheet_ns)
                a_cell = first
            val = ''
            if a_cell is not None:
                t = a_cell.attrib.get('t')
                v = a_cell.find('ns:v', sheet_ns)
                if v is not None:
                    if t == 's':
                        idx = int(v.text)
                        if idx < len(strings):
                            val = strings[idx]
                    else:
                        val = v.text or ''
            product_names.append(val.strip())
        return product_names


def main():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--xlsx", required=True)
    ap.add_argument("--target", required=True)
    ap.add_argument("--mapping", required=True)
    args = ap.parse_args()

    xlsx_path = args.xlsx
    target_dir = args.target
    mapping_path = args.mapping
    tmp_dir = "/tmp/cairo_xlsx_media"
    os.makedirs(target_dir, exist_ok=True)
    if os.path.exists(tmp_dir):
        shutil.rmtree(tmp_dir)
    os.makedirs(tmp_dir, exist_ok=True)

    # Extract images from xlsx to tmp_dir
    with zipfile.ZipFile(xlsx_path, 'r') as z:
        for name in z.namelist():
            if name.startswith("xl/media/"):
                filename = os.path.basename(name)
                if not filename:
                    continue
                with z.open(name) as src, open(os.path.join(tmp_dir, filename), 'wb') as dst:
                    dst.write(src.read())

    product_names = read_product_names_from_xlsx(xlsx_path)
    image_files = sorted([f for f in os.listdir(tmp_dir) if os.path.isfile(os.path.join(tmp_dir, f))])

    mapping = {}
    existing = set(os.listdir(target_dir))

    for idx, img in enumerate(image_files):
        key = product_names[idx].strip() if idx < len(product_names) and product_names[idx].strip() else f"Product {idx+1}"
        slug = slugify(key)
        src = os.path.join(tmp_dir, img)
        ext = os.path.splitext(img)[1].lower()
        candidate = slug + ext
        unique = candidate
        n = 1
        while unique in existing:
            unique = f"{slug}-{n}{ext}"
            n += 1
        dst = os.path.join(target_dir, unique)
        shutil.copy2(src, dst)
        existing.add(unique)
        mapping.setdefault(key, []).append(unique)

    with open(mapping_path, "w", encoding="utf-8") as mf:
        json.dump(mapping, mf, ensure_ascii=False, indent=2)

    print("DONE")

if __name__ == '__main__':
    main()
