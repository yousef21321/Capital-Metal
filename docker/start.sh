#!/bin/sh

echo "=== Capital-Metal Starting ==="

if [ ! -f "vendor/autoload.php" ]; then
    echo "[1] Installing dependencies..."
    composer install --no-interaction --optimize-autoloader --no-security-blocking
fi

if ! composer show laravel/sanctum 2>/dev/null; then
    echo "[2] Installing Sanctum..."
    composer require laravel/sanctum --no-interaction --no-security-blocking
fi

if ! composer show dompdf/dompdf 2>/dev/null; then
    echo "[3] Installing DomPDF..."
    composer require dompdf/dompdf --no-interaction --no-security-blocking
fi

echo "[4] Publishing Sanctum config..."
php artisan vendor:publish --tag=sanctum-config --force 2>/dev/null || true

echo "[5] Generating app key..."
php artisan key:generate --force 2>/dev/null || true

echo "[6] Running migrations..."
php artisan migrate --force

echo "[7] Running seeders..."
php artisan db:seed --force 2>/dev/null || true

echo "[8] Starting queue worker..."
php artisan queue:work --sleep=3 --tries=3 --daemon &
QUEUE_PID=$!
echo "  Queue worker started (PID: $QUEUE_PID)"

echo "[9] Starting Laravel server..."
php artisan serve --host=0.0.0.0 --port=8000
