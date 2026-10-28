<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use App\Models\Order;
use App\Models\Payment;
use App\Models\User;
use App\Services\LemonSqueezyService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class LemonSqueezyController extends Controller
{
    public function __construct(
        protected LemonSqueezyService $lemonsqueezy
    ) {}

    public function initiatePayment(Request $request)
    {
        $validated = $request->validate([
            'order_id' => 'required|exists:orders,id',
        ]);

        $user = $request->user() ?? auth('sanctum')->user();
        $guestToken = $request->header('X-Guest-Token', $request->input('guest_token'));
        $order = Order::findOrFail($validated['order_id']);

        if ($user) {
            if ($order->user_id !== $user->id) {
                return response()->json(['message' => 'Forbidden.'], 403);
            }
        } else {
            if ($order->user_id !== null
                || $order->guest_token === null
                || $order->guest_token !== $guestToken) {
                return response()->json(['message' => 'Forbidden.'], 403);
            }
        }

        if ($order->payment_status === 'paid') {
            return response()->json(['message' => 'Order is already paid.'], 422);
        }

        if ($order->currency !== 'USD') {
            return response()->json(['message' => 'LemonSqueezy is only for USD orders.'], 422);
        }

        $order->load('items.product');
        $firstItem = $order->items->first();
        $variantId = $firstItem?->product?->lemonsqueezy_variant_id
            ?? $this->lemonsqueezy->getDefaultVariantId();

        if (! $variantId) {
            return response()->json(['message' => 'No LemonSqueezy variant configured. Contact support.'], 422);
        }

        // Order total is already in USD (EGP ÷ exchange rate at checkout).
        $amountUsd = (float) $order->total_amount;

        try {
            $customerEmail = $user->email
                ?? $order->guest_email
                ?? sprintf('guest-%s@capital-metal.first-link-logistics.com', strtolower($order->order_number));

            $result = $this->lemonsqueezy->createCheckout(
                variantId: $variantId,
                orderId: $order->id,
                orderNumber: $order->order_number,
                amount: $amountUsd,
                customerEmail: $customerEmail,
                customerName: $user->name ?? $order->guest_name ?? 'Guest',
                redirectUrl: config('services.lemonsqueezy.redirect_url')
            );

            $order->update(['payment_status' => 'processing']);

            Payment::create([
                'order_id' => $order->id,
                'amount' => $amountUsd,
                'currency' => 'USD',
                'payment_status' => 'pending',
                'paymob_order_id' => $result['checkout_id'],
                'created_at' => now(),
            ]);

            Log::info('LemonSqueezy payment initiated', [
                'order_id' => $order->id,
                'checkout_id' => $result['checkout_id'],
            ]);

            return response()->json([
                'payment_url' => $result['url'],
            ]);
        } catch (\Exception $e) {
            Log::error('LemonSqueezy checkout failed', [
                'order_id' => $order->id,
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'message' => 'Failed to initiate payment: ' . $e->getMessage(),
            ], 500);
        }
    }

    public function webhook(Request $request)
    {
        $signature = $request->header('X-Signature');
        $rawBody = $request->getContent();
        $payload = $request->all();

        Log::debug('LemonSqueezy webhook received', ['payload' => $payload]);

        if (! $this->lemonsqueezy->verifyWebhook($rawBody, $signature)) {
            Log::warning('LemonSqueezy webhook signature verification failed');
            return response()->json(['message' => 'Invalid signature.'], 403);
        }

        $eventName = $payload['meta']['event_name'] ?? '';

        if ($eventName === 'order_created') {
            $this->handleOrderCreated($payload);
        }

        return response()->json(['message' => 'OK']);
    }

    protected function handleOrderCreated(array $payload): void
    {
        $customData = $payload['meta']['custom_data'] ?? $payload['data']['attributes']['custom_data'] ?? [];
        $orderId = $customData['order_id'] ?? null;
        $status = $payload['data']['attributes']['status'] ?? '';

        if (! $orderId) {
            Log::warning('LemonSqueezy webhook missing order_id in custom_data');
            return;
        }

        $order = Order::find($orderId);
        if (! $order) {
            Log::warning('LemonSqueezy webhook: order not found', ['order_id' => $orderId]);
            return;
        }

        $isPaid = $status === 'paid';
        $payment = Payment::where('order_id', $orderId)
            ->where('payment_status', 'pending')
            ->latest()
            ->first();

        if ($payment) {
            $payment->update([
                'transaction_id' => (string) ($payload['data']['id'] ?? ''),
                'payment_status' => $isPaid ? 'paid' : 'failed',
            ]);
        }

        $order->update([
            'payment_status' => $isPaid ? 'paid' : 'failed',
            'order_status' => $isPaid ? 'confirmed' : 'pending',
        ]);

        Log::info('LemonSqueezy order processed', [
            'order_id' => $orderId,
            'lemonsqueezy_order_id' => $payload['data']['id'] ?? '',
            'status' => $status,
            'paid' => $isPaid,
        ]);

        if ($isPaid && $order->user_id) {
            $this->notifyUser($order->user_id, 'payment.success', 'Payment received via LemonSqueezy', [
                'order_id' => $order->id,
                'order_number' => $order->order_number,
            ]);
        }
    }

    protected function notifyUser(int $userId, string $type, string $title, array $data = []): void
    {
        Notification::create([
            'user_id' => $userId,
            'type' => $type,
            'title' => $title,
            'data' => $data,
        ]);
    }
}
