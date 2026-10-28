#!/usr/bin/env python3
import sys, os, shutil, time
from pathlib import Path
import subprocess

def main():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--images_dir", required=True)
    ap.add_argument("--backup_dir", required=False, default=None)
    args = ap.parse_args()

    images_dir = Path(args.images_dir)
    if not images_dir.exists():
        print("Images dir not found", file=sys.stderr)
        sys.exit(1)
    # Backup
    if args.backup_dir is not None:
        backup_root = Path(args.backup_dir)
        ts = time.strftime('%Y%m%d%H%M%S')
        backup_dir = backup_root / ts
        backup_dir.mkdir(parents=True, exist_ok=True)
        for p in images_dir.iterdir():
            if p.is_file():
                shutil.copy2(p, backup_dir / p.name)
        print(f"Backup created at {backup_dir}")
    # Determine ImageMagick binary
    magick = shutil.which('magick') or shutil.which('convert')
    if not magick:
        print("ImageMagick not found in container. Please provide an environment with ImageMagick.")
        sys.exit(0)
    # Re-encode files in place
    for f in sorted(images_dir.iterdir()):
        if not f.is_file():
            continue
        ext = f.suffix.lower()
        if ext in ['.jpg', '.jpeg']:
            tmp = f.with_suffix('.tmp')
            cmd = [magick, str(f), '-quality', '95', str(tmp)]
            res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            if res.returncode == 0 and tmp.exists():
                tmp.replace(f)
        elif ext == '.png':
            tmp = f.with_suffix('.tmp')
            cmd = [magick, str(f), '-strip', '-define', 'png:compression-level=9', str(tmp)]
            res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            if res.returncode == 0 and tmp.exists():
                tmp.replace(f)
        else:
            continue
    print("DONE")

if __name__ == '__main__':
    main()
