<?php

namespace App\Services;

use Illuminate\Http\Client\RequestException;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class LemonSqueezyService
{
    protected string $apiKey;
    protected string $storeId;

    public function __construct()
    {
        $this->apiKey = config('services.lemonsqueezy.api_key');
        $this->storeId = config('services.lemonsqueezy.store_id');
    }

    protected function api(): \Illuminate\Http\Client\PendingRequest
    {
        return Http::withToken($this->apiKey)
            ->baseUrl('https://api.lemonsqueezy.com/v1')
            ->acceptJson()
            ->contentType('application/vnd.api+json');
    }

    public function getDefaultVariantId(): ?string
    {
        return config('services.lemonsqueezy.default_variant_id') ?: null;
    }

    public function createCheckout(
        string $variantId,
        int $orderId,
        string $orderNumber,
        float $amount,
        string $customerEmail,
        ?string $customerName = null,
        ?string $redirectUrl = null
    ): array {
        $amountCents = (int) round($amount * 100);
        $redirectUrl ??= config('services.lemonsqueezy.redirect_url');

        Log::debug('LemonSqueezy createCheckout', [
            'order_id' => $orderId,
            'amount_cents' => $amountCents,
            'store_id' => $this->storeId,
            'variant_id' => $variantId,
        ]);

        $response = $this->api()->post('/checkouts', [
            'data' => [
                'type' => 'checkouts',
                'attributes' => [
                    'custom_price' => $amountCents,
                    'test_mode' => true,
                    'checkout_data' => [
                        'email' => $customerEmail,
                        'name' => $customerName ?? '',
                        'custom' => [
                            'order_id' => (string) $orderId,
                            'order_number' => $orderNumber,
                        ],
                    ],
                    'product_options' => [
                        'enabled_variants' => [(int) $variantId],
                        'redirect_url' => $redirectUrl . '?order_id=' . $orderId,
                    ],
                    'checkout_options' => [
                        'embed' => false,
                    ],
                ],
                'relationships' => [
                    'store' => [
                        'data' => [
                            'type' => 'stores',
                            'id' => (string) $this->storeId,
                        ],
                    ],
                    'variant' => [
                        'data' => [
                            'type' => 'variants',
                            'id' => (string) $variantId,
                        ],
                    ],
                ],
            ],
        ]);

        $result = $response->throw()->json();
        $checkoutUrl = $result['data']['attributes']['url'] ?? null;
        $checkoutId = $result['data']['id'] ?? null;

        Log::debug('LemonSqueezy checkout created', [
            'checkout_id' => $checkoutId,
            'url' => $checkoutUrl,
        ]);

        return [
            'checkout_id' => $checkoutId,
            'url' => $checkoutUrl,
        ];
    }

    public function verifyWebhook(string $rawBody, string $signature): bool
    {
        $secret = config('services.lemonsqueezy.webhook_secret');
        if (! $secret) {
            Log::warning('LemonSqueezy webhook secret not configured, skipping verification');
            return true;
        }

        $computed = hash_hmac('sha256', $rawBody, $secret);
        return hash_equals($computed, $signature);
    }
}
