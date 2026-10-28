FROM python:3.11-slim
RUN apt-get update -y && apt-get install -y --no-install-recommends imagemagick ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /work
COPY . /work
RUN python -m pip install --no-cache-dir pillow openpyxl PyMySQL
CMD ["python3", "scripts/upgrade_images.py", "--images_dir", "frontend/assets/images", "--backup_dir", "backups/images"]
