#!/usr/bin/env node
// Complete the product image move: copy images into products/{id}/ and generate thumbs
const fs = require('fs');
const path = require('path');
const sharp = require('/home/ubuntu/Capital-Metal/frontend/node_modules/sharp');

const SRC_DIR = '/home/ubuntu/Capital-Metal/frontend/assets/images';
const DEST_ROOT = '/home/ubuntu/Capital-Metal/backend/storage/app/public/products';

// id -> [source filenames]
const mapping = require('/home/ubuntu/Capital-Metal/frontend/assets/images/product_images_by_id.json');

(async () => {
  let moved = 0, thumbs = 0, missing = [];
  for (const [pidStr, imgs] of Object.entries(mapping)) {
    const pid = pidStr;
    const destDir = path.join(DEST_ROOT, pid);
    fs.mkdirSync(destDir, { recursive: true });
    const list = Array.isArray(imgs) ? imgs : [imgs];
    for (const fname of list) {
      const src = path.join(SRC_DIR, fname);
      if (!fs.existsSync(src)) { missing.push(fname); continue; }
      const dst = path.join(destDir, fname);
      fs.copyFileSync(src, dst);
      moved++;
      // thumbnail {name}_thumb.webp  (match ImageOptimizer.thumbnailPath)
      const base = path.parse(fname).name;
      const thumbDst = path.join(destDir, `${base}_thumb.webp`);
      try {
        const im = sharp(src);
        const meta = await im.metadata();
        await im.resize(480, 480, { fit: 'inside' })
          .webp({ quality: 75 })
          .toFile(thumbDst);
        thumbs++;
      } catch (e) {
        // fallback empty file to indicate presence
        fs.writeFileSync(thumbDst, Buffer.alloc(0));
        console.error(`thumb fail for ${fname}: ${e.message}`);
      }
    }
  }
  console.log(`DONE moved=${moved} thumbs=${thumbs} missing=${missing.length}`);
  if (missing.length) console.log('MISSING:', missing.join(', '));
})().catch(e => { console.error(e); process.exit(1); });
