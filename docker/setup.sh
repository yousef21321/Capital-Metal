#!/bin/bash

echo "=== FLFL Design Setup ==="

echo "[1] Installing Composer dependencies..."
composer install --no-interaction --optimize-autoloader

echo "[2] Installing Laravel Sanctum..."
composer require laravel/sanctum --no-interaction

echo "[3] Installing DOMPDF..."
composer require barryvdh/laravel-dompdf --no-interaction

echo "[4] Generating app key (if needed)..."
php artisan key:generate --force

echo "[5] Running migrations..."
php artisan migrate --force

echo "[6] Running database seeders..."
php artisan db:seed --force

echo "[7] Starting application..."
php artisan serve --host=0.0.0.0 --port=8000
