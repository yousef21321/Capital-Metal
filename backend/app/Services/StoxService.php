<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class StoxService
{
    protected string $token;

    protected string $baseUrl = 'https://merchants.stox-eg.com/api';

    public function __construct()
    {
        $this->token = config('services.stox.token', '');
    }

    public function isConfigured(): bool
    {
        return ! empty($this->token);
    }

    public function createProduct(string $name, string $sku, ?string $description = null, array $images = []): ?array
    {
        if (! $this->isConfigured()) {
            Log::warning('Stox is not configured. Set STOX_TOKEN in your .env.');

            return null;
        }

        $payload = [
            'name' => $name,
            'sku' => $sku,
            'description' => $description ?? '',
            'brand' => null,
            'color' => null,
            'expires' => null,
            'category_id' => null,
        ];

        if (! empty($images)) {
            $payload['images'] = $images;
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => "Bearer {$this->token}",
                'Accept' => 'application/json',
            ])->timeout(30)->post("{$this->baseUrl}/products/store", $payload);

            $body = $response->json();

            if ($response->successful() && ($body['success'] ?? false)) {
                return $body['data'] ?? null;
            }

            Log::error('Stox product creation failed', [
                'status' => $response->status(),
                'response' => $body,
                'payload' => $payload,
            ]);

            return null;
        } catch (\Exception $e) {
            Log::error('Stox API error', [
                'message' => $e->getMessage(),
                'payload' => $payload,
            ]);

            return null;
        }
    }

    public function createOrder(array $orderData): ?array
    {
        if (! $this->isConfigured()) {
            Log::warning('Stox is not configured. Set STOX_TOKEN in your .env.');

            return null;
        }

        $payload = [
            'orders' => [$orderData],
        ];

        try {
            $response = Http::withHeaders([
                'Authorization' => "Bearer {$this->token}",
                'Accept' => 'application/json',
            ])->timeout(30)->post("{$this->baseUrl}/orders/store", $payload);

            $body = $response->json();

            if ($response->successful() && ($body['success'] ?? false)) {
                return $body;
            }

            Log::error('Stox order creation failed', [
                'status' => $response->status(),
                'response' => $body,
                'payload' => $payload,
            ]);

            return null;
        } catch (\Exception $e) {
            Log::error('Stox order API error', [
                'message' => $e->getMessage(),
                'payload' => $payload,
            ]);

            return null;
        }
    }

    public function getAreas(): array
    {
        return Cache::remember('stox_areas', 3600, function () {
            try {
                $response = Http::withHeaders([
                    'Authorization' => "Bearer {$this->token}",
                    'Accept' => 'application/json',
                ])->timeout(15)->get("{$this->baseUrl}/areas");

                $body = $response->json();

                if ($response->successful() && isset($body['data'])) {
                    return $body['data'];
                }
            } catch (\Exception $e) {
                Log::error('Stox areas fetch failed', ['message' => $e->getMessage()]);
            }

            return [];
        });
    }

    public function resolveAreaId(?string $city, ?string $governorate = null): ?int
    {
        if (! $city && ! $governorate) {
            return null;
        }

        $areas = $this->getAreas();

        if (empty($areas)) {
            return null;
        }

        if ($city) {
            $normalizedCity = strtolower(trim($city));
            foreach ($areas as $area) {
                $areaName = strtolower(trim($area['en_name'] ?? $area['name'] ?? ''));
                if ($areaName === $normalizedCity || str_contains($areaName, $normalizedCity) || str_contains($normalizedCity, $areaName)) {
                    return (int) $area['id'];
                }
            }
        }

        if ($governorate) {
            $normalizedGov = strtolower(trim($governorate));
            foreach ($areas as $area) {
                $areaName = strtolower(trim($area['en_name'] ?? $area['name'] ?? ''));
                if ($areaName === $normalizedGov || str_contains($areaName, $normalizedGov) || str_contains($normalizedGov, $areaName)) {
                    return (int) $area['id'];
                }
            }
        }

        return null;
    }

    public function mapPaymentType(?int $paymentMethodId): string
    {
        $codId = config('services.stox.cod_payment_method_id', 2);

        return $paymentMethodId == $codId ? 'COD' : 'CC';
    }

    public function buildImageUrl(string $path): string
    {
        if (str_starts_with($path, 'http')) {
            return $path;
        }

        $baseUrl = config('app.url', 'https://capital-metal.first-link-logistics.com');

        return "{$baseUrl}/storage/{$path}";
    }
}
