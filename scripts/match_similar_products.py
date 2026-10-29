#!/usr/bin/env python3
# Match products without images to similar-named products that have images.
# Reads product list from a UTF-8 dump (id<TAB>name<TAB>has_img), outputs JSON mapping.
import sys, json, re, unicodedata
from difflib import SequenceMatcher

DUMP = sys.argv[1] if len(sys.argv) > 1 else '/tmp/products_status.txt'

def normalize(s: str) -> str:
    if not s:
        return ''
    # Arabic-Indic digits -> Latin
    s = s.replace('٠','0').replace('١','1').replace('٢','2').replace('٣','3').replace('٤','4') \
         .replace('٥','5').replace('٦','6').replace('٧','7').replace('٨','8').replace('٩','9')
    # Persian digits
    s = s.replace('۰','0').replace('۱','1').replace('۲','2').replace('۳','3').replace('۴','4') \
         .replace('۵','5').replace('۶','6').replace('۷','7').replace('۸','8').replace('۹','9')
    # normalize Arabic letters
    s = s.replace('أ','ا').replace('إ','ا').replace('آ','ا').replace('ٱ','ا')
    s = s.replace('ة','ه').replace('ى','ي')
    s = re.sub(r'[\u064B-\u0652]', '', s)  # tashkeel
    s = s.lower()
    # keep only arabic letters, latin alnum, spaces; drop punctuation
    s = re.sub(r'[^\w\u0600-\u06FF\s]', '', s, flags=re.UNICODE)
    s = re.sub(r'\s+', ' ', s).strip()
    return s

products = []  # (id, name, has_img)
with open(DUMP, encoding='utf-8') as f:
    lines = f.read().strip().splitlines()
for line in lines[1:]:  # skip header
    parts = line.split('\t')
    if len(parts) < 3:
        continue
    pid = int(parts[0])
    name = parts[1]
    has_img = parts[2].strip() == '1'
    products.append((pid, name, has_img))

with_img = [(pid, name) for pid, name, hi in products if hi]
norm_with_img = [(pid, normalize(name)) for pid, name in with_img]

results = {}
for pid, name, hi in products:
    if hi:
        continue
    n = normalize(name)
    best = None
    best_score = 0.0
    for pid2, n2 in norm_with_img:
        score = SequenceMatcher(None, n, n2).ratio()
        if score > best_score:
            best_score = score
            best = (pid2, n2)
    results[pid] = {
        'name': name,
        'match_pid': best[0] if best else None,
        'match_name': dict((p, nm) for p, nm in with_img).get(best[0]) if best else None,
        'score': round(best_score, 3)
    }

print(json.dumps(results, ensure_ascii=False, indent=2))