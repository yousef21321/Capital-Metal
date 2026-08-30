#!/bin/bash
# Backup MySQL database for flfl_design
# Runs automatically via cron job
# Usage: ./backup-db.sh [filename]

CONTAINER="flfl_db"
DATABASE="flfl_design"
ROOT_USER="root"
ROOT_PASS="root"
BACKUP_DIR="/home/ubuntu/FLFL-Design/backups"
RETENTION_DAYS=7
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="${1:-${DATABASE}_backup_${TIMESTAMP}.sql}"

mkdir -p "$BACKUP_DIR"

docker exec "$CONTAINER" mysqldump -u "$ROOT_USER" -p"$ROOT_PASS" "$DATABASE" > "$BACKUP_DIR/$FILENAME"

if [ $? -eq 0 ]; then
    echo "[$(date)] Backup saved: $FILENAME ($(du -h "$BACKUP_DIR/$FILENAME" | cut -f1))"
else
    echo "[$(date)] Backup FAILED!" >&2
    exit 1
fi

# Remove backups older than retention period
find "$BACKUP_DIR" -name "*.sql" -mtime +$RETENTION_DAYS -delete
