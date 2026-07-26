<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class PaymobService
{
    protected string $secretKey;

    protected string $publicKey;

    protected string $merchantId;

    protected string $integrationId;

    protected string $iframeId;

    protected string $hmac;

    protected string $baseUrl;

    public function __construct()
    {
        $this->secretKey = config('services.paymob.api_key');
        $this->publicKey = config('services.paymob.public_key');
        $this->merchantId = config('services.paymob.merchant_id');
        $this->integrationId = config('services.paymob.integration_id');
        $this->iframeId = config('services.paymob.iframe_id');
        $this->hmac = config('services.paymob.hmac');
        $this->baseUrl = 'https://accept.paymob.com';
    }

    protected function ensureConfigured(): void
    {
        if (empty($this->secretKey) || empty($this->integrationId)) {
            throw new \RuntimeException(
                'Paymob is not configured. Set PAYMOB_API_KEY and PAYMOB_INTEGRATION_ID in your .env.'
            );
        }
    }

    protected function authHeaders(): array
    {
        return [
            'Authorization' => "Token {$this->secretKey}",
            'Content-Type' => 'application/json',
        ];
    }

    public function createIntention(int $amountCents, string $currency, array $billingData, array $items = [], ?string $notificationUrl = null, ?string $redirectionUrl = null): array
    {
        $this->ensureConfigured();

        $payload = [
            'amount' => $amountCents,
            'currency' => $currency,
            'payment_methods' => [(int) $this->integrationId],
            'items' => $items ?: [
                [
                    'name' => 'Payment',
                    'amount' => $amountCents,
                    'description' => 'Payment for order',
                    'quantity' => 1,
                ],
            ],
            'billing_data' => $billingData,
        ];

        if ($notificationUrl) {
            $payload['notification_url'] = $notificationUrl;
        }

        if ($redirectionUrl) {
            $payload['redirection_url'] = $redirectionUrl;
        }

        $response = Http::withHeaders($this->authHeaders())
            ->post("{$this->baseUrl}/v1/intention", $payload);

        $response->throw();

        return $response->json();
    }

    public function getCheckoutUrl(string $clientSecret): string
    {
        return "{$this->baseUrl}/unifiedcheckout/?publicKey={$this->publicKey}&clientSecret={$clientSecret}";
    }

    public function tokenizeCard(string $holderName, string $cardNumber, string $expiryMonth, string $expiryYear, string $cvv): array
    {
        if (empty($this->secretKey) || empty($this->merchantId)) {
            throw new \RuntimeException(
                'Paymob is not configured. Set PAYMOB_API_KEY and PAYMOB_MERCHANT_ID in your .env to save cards.'
            );
        }

        $response = Http::post("{$this->baseUrl}/api/commerce/tokenization", [
            'api_key' => $this->secretKey,
            'merchant_id' => (int) $this->merchantId,
            'cardholder_name' => $holderName,
            'card_number' => preg_replace('/\s+/', '', $cardNumber),
            'card_expiry_month' => $expiryMonth,
            'card_expiry_year' => $expiryYear,
            'card_cvv' => $cvv,
        ]);

        $response->throw();

        $body = $response->json();

        if (empty($body['token'])) {
            throw new \RuntimeException('Paymob did not return a card token.');
        }

        return [
            'token' => $body['token'],
            'card_subtype' => $body['card_subtype'] ?? 'CARD',
            'masked_pan' => $body['masked_pan'] ?? $body['masked_card_number'] ?? null,
        ];
    }

    public function chargeSavedCard(int $amountCents, string $currency, string $clientSecret, array $billingData, string $cardToken): array
    {
        $response = Http::withHeaders($this->authHeaders())
            ->post("{$this->baseUrl}/v1/intention/{$clientSecret}/charge", [
                'source' => [
                    'identifier' => $cardToken,
                    'subtype' => 'CARD',
                ],
                'payment_method' => (int) $this->integrationId,
            ]);

        $response->throw();

        return $response->json();
    }

    public function buildBillingData(array $data): array
    {
        return [
            'apartment' => $data['apartment'] ?? 'N/A',
            'email' => $data['email'] ?? '',
            'floor' => $data['floor'] ?? 'N/A',
            'first_name' => $data['first_name'] ?? '',
            'street' => $data['street'] ?? 'N/A',
            'building' => $data['building'] ?? 'N/A',
            'phone_number' => $data['phone_number'] ?? '',
            'shipping_method' => $data['shipping_method'] ?? 'PKG',
            'postal_code' => $data['postal_code'] ?? 'N/A',
            'city' => $data['city'] ?? 'N/A',
            'country' => $data['country'] ?? 'EG',
            'last_name' => $data['last_name'] ?? '',
            'state' => $data['state'] ?? 'N/A',
        ];
    }

    public function processCallback(array $data): ?array
    {
        $hmacType = $data['type'] ?? null;

        if ($hmacType === 'TRANSACTION') {
            $obj = $data['obj'] ?? [];

            if (! empty($this->hmac) && isset($data['hmac'])) {
                $computedHmac = $this->calculateHmac($obj);

                if ($computedHmac !== $data['hmac']) {
                    Log::warning('PayMob HMAC mismatch', [
                        'expected' => $data['hmac'],
                        'computed' => $computedHmac,
                    ]);

                    return null;
                }
            }

            return $obj;
        }

        return $data['obj'] ?? $data;
    }

    public function calculateHmac(array $obj): string
    {
        $amountCents = $obj['amount_cents'] ?? 0;
        $createdAt = $obj['created_at'] ?? '';
        $currency = $obj['currency'] ?? '';
        $errorOccurred = $obj['error_occurred'] ?? false;
        $hasParentTransaction = isset($obj['parent_transaction_id']) ? $obj['parent_transaction_id'] : '';
        $id = $obj['id'] ?? 0;
        $integrationId = $obj['integration_id'] ?? 0;
        $isAuth = $obj['is_auth'] ?? false;
        $isCapture = $obj['is_capture'] ?? false;
        $isRefunded = $obj['is_refunded'] ?? false;
        $isStandalonePayment = $obj['is_standalone_payment'] ?? false;
        $is3DSecure = $obj['is_3d_secure'] ?? false;
        $isVoid = $obj['is_void'] ?? false;
        $orderId = $obj['order'] ?? $obj['order_id'] ?? 0;
        $owner = $obj['owner'] ?? 0;
        $pending = $obj['pending'] ?? false;
        $sourceDataPan = $obj['source_data']['pan'] ?? '';
        $sourceDataType = $obj['source_data']['type'] ?? '';
        $sourceDataSubType = $obj['source_data']['sub_type'] ?? '';
        $success = $obj['success'] ?? false;

        $txnId = $this->padLeftZeros($id);
        $orderId = $this->padLeftZeros($orderId);
        $sourceDataPan = $this->padLeftZeros($sourceDataPan);
        $cleanedCreatedAt = str_replace([':', '.'], '', $createdAt);

        $data = "{$amountCents}{$cleanedCreatedAt}{$currency}{$errorOccurred}{$hasParentTransaction}{$txnId}{$integrationId}{$isAuth}{$isCapture}{$isRefunded}{$isStandalonePayment}{$is3DSecure}{$isVoid}{$orderId}{$owner}{$pending}{$sourceDataPan}{$sourceDataType}{$sourceDataSubType}{$success}";

        return hash_hmac('SHA512', $data, $this->hmac);
    }

    protected function padLeftZeros(mixed $value, int $length = 7): string
    {
        return str_pad((string) $value, $length, '0', STR_PAD_LEFT);
    }
}
