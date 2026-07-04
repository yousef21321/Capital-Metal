<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class PaymobService
{
    protected string $apiKey;
    protected string $merchantId;
    protected string $integrationId;
    protected string $iframeId;
    protected string $hmac;
    protected string $baseUrl;

    public function __construct()
    {
        $this->apiKey = config('services.paymob.api_key');
        $this->merchantId = config('services.paymob.merchant_id');
        $this->integrationId = config('services.paymob.integration_id');
        $this->iframeId = config('services.paymob.iframe_id');
        $this->hmac = config('services.paymob.hmac');
        $this->baseUrl = 'https://accept.paymob.com/api';
    }

    public function getAuthToken(): string
    {
        $this->ensureConfigured();

        $response = Http::post("{$this->baseUrl}/auth/tokens", [
            'api_key' => $this->apiKey,
        ]);

        $response->throw();
        $body = $response->json();

        return $body['token'];
    }

    protected function ensureConfigured(): void
    {
        if (empty($this->apiKey) || empty($this->integrationId) || empty($this->iframeId)) {
            throw new \RuntimeException(
                'Paymob is not configured. Set PAYMOB_API_KEY, PAYMOB_INTEGRATION_ID, and PAYMOB_IFRAME_ID in your .env.'
            );
        }
    }

    public function tokenizeCard(string $holderName, string $cardNumber, string $expiryMonth, string $expiryYear, string $cvv): array
    {
        if (empty($this->apiKey) || empty($this->merchantId)) {
            throw new \RuntimeException(
                'Paymob is not configured. Set PAYMOB_API_KEY and PAYMOB_MERCHANT_ID in your .env to save cards.'
            );
        }

        $response = Http::post("{$this->baseUrl}/commerce/tokenization", [
            'api_key' => $this->apiKey,
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

    public function chargeSavedCard(string $authToken, int $amountCents, string $currency, int $paymobOrderId, array $billingData, string $cardToken): array
    {
        $paymentKey = $this->getPaymentKey($authToken, $amountCents, $currency, $paymobOrderId, $billingData);

        $response = Http::post("{$this->baseUrl}/acceptance/post_pay", [
            'source' => [
                'identifier' => $cardToken,
                'subtype' => 'CARD',
            ],
            'payment_token' => $paymentKey,
        ]);

        $response->throw();

        return $response->json();
    }

    public function createOrder(string $token, float $amountCents, string $currency = 'EGP', ?int $merchantOrderId = null, array $items = []): array
    {
        $payload = [
            'auth_token' => $token,
            'delivery_needed' => false,
            'amount_cents' => (int) round($amountCents),
            'currency' => $currency,
            'items' => $items,
        ];

        if ($merchantOrderId) {
            $payload['merchant_order_id'] = $merchantOrderId;
        }

        $response = Http::post("{$this->baseUrl}/ecommerce/orders", $payload);
        $response->throw();

        return $response->json();
    }

    public function getPaymentKey(string $token, int $amountCents, string $currency, int $paymobOrderId, array $billingData): string
    {
        $payload = [
            'auth_token' => $token,
            'amount_cents' => $amountCents,
            'expiration' => 3600,
            'order_id' => $paymobOrderId,
            'billing_data' => $billingData,
            'currency' => $currency,
            'integration_id' => (int) $this->integrationId,
            'lock_order_when_paid' => false,
        ];

        $response = Http::post("{$this->baseUrl}/acceptance/payments/payment_keys", $payload);
        $response->throw();

        return $response->json()['token'];
    }

    public function getIframeUrl(string $paymentToken): string
    {
        return "https://accept.paymob.com/api/acceptance/iframes/{$this->iframeId}?payment_token={$paymentToken}";
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
            $computedHmac = $this->calculateHmac($data['obj']);

            if ($computedHmac !== ($data['hmac'] ?? null)) {
                Log::warning('PayMob HMAC mismatch', [
                    'expected' => $data['hmac'] ?? null,
                    'computed' => $computedHmac,
                ]);
                return null;
            }

            return $data['obj'];
        }

        return null;
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

        $txnId = $id;
        $txnId = $this->padLeftZeros($txnId);

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
