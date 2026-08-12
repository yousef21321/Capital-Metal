<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Payment;
use App\Services\LemonSqueezyService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class PaymentController extends Controller
{
    public function __construct(
        protected ?LemonSqueezyService $lemonsqueezy = null,
    ) {}

    public function index(Request $request)
    {
        $query = Payment::with('order', 'paymentMethod');

        if ($request->user()->role->name !== 'admin') {
            $query->whereHas('order', function ($q) use ($request) {
                $q->where('user_id', $request->user()->id);
            });
        }

        return response()->json($query->latest()->paginate($request->per_page ?? 20));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'order_id' => 'required|exists:orders,id',
            'payment_method_id' => 'nullable|exists:payment_methods,id',
            'transaction_id' => 'nullable|string|max:255',
            'amount' => 'nullable|numeric|min:0',
            'currency' => 'nullable|in:EGP,USD',
            'payment_status' => 'nullable|in:pending,paid,failed,refunded',
        ]);

        $order = Order::findOrFail($validated['order_id']);

        if ($request->user()->role->name !== 'admin' && $order->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        $payment = Payment::create($validated);

        if (($validated['payment_status'] ?? null) === 'paid') {
            $order->update(['payment_status' => 'paid']);
        }

        return response()->json($payment->load('paymentMethod'), 201);
    }

    public function status(Request $request)
    {
        $orderId = $request->query('order_id');

        if (! $orderId) {
            return response()->json(['message' => 'order_id is required.'], 422);
        }

        $order = Order::with('payments')->find($orderId);

        // PayMob passes its own order id (paymob_order_id) in the redirect URL,
        // while LemonSqueezy passes the internal order id. Resolve both.
        if (! $order) {
            $payment = Payment::where('paymob_order_id', (string) $orderId)->first();
            $order = $payment?->order ? $payment->order->load('payments') : null;
        }

        if (! $order) {
            return response()->json(['message' => 'Order not found.'], 404);
        }

        $latestPayment = $order->payments()->latest('id')->first();

        // If order is still "processing", the webhook may not have arrived yet.
        // For LemonSqueezy (USD) orders, query their API directly.
        if ($order->payment_status === 'processing' && $order->currency === 'USD' && $latestPayment?->paymob_order_id) {
            $this->checkLemonSqueezyStatus($order, $latestPayment);
            $order->refresh();
            $latestPayment->refresh();
        }

        return response()->json([
            'order_id' => $order->id,
            'order_number' => $order->order_number,
            'payment_status' => $order->payment_status,
            'latest_payment_status' => $latestPayment?->payment_status,
        ]);
    }

    protected function checkLemonSqueezyStatus(Order $order, Payment $payment): void
    {
        try {
            if (! $this->lemonsqueezy) {
                return;
            }

            $storeId = config('services.lemonsqueezy.store_id');

            // The checkout API has no status field; query the orders API instead.
            // The customer can change their email at checkout, so don't filter by
            // email — match the most recent order with our exact amount instead.
            $response = \Illuminate\Support\Facades\Http::withToken(config('services.lemonsqueezy.api_key'))
                ->acceptJson()
                ->get('https://api.lemonsqueezy.com/v1/orders', [
                    'filter[store_id]' => $storeId,
                    'page[size]' => 50,
                ]);

            if (! $response->successful()) {
                Log::warning('LemonSqueezy order lookup failed', ['status' => $response->status()]);
                return;
            }

            $amountCents = (int) round((float) $payment->amount * 100);
            $orders = $response->json('data', []);

            // Orders are returned newest-first; match the first one with our amount.
            $matched = null;
            foreach ($orders as $lsOrder) {
                $attributes = $lsOrder['attributes'] ?? [];
                if ((int) ($attributes['total'] ?? 0) === $amountCents) {
                    $matched = $attributes;
                    break;
                }
            }

            if (! $matched) {
                Log::debug('LemonSqueezy order not matched via API', [
                    'order_id' => $order->id,
                    'email' => $customerEmail,
                    'amount_cents' => $amountCents,
                ]);
                return;
            }

            $lsStatus = $matched['status'] ?? null;

            if ($lsStatus === 'paid') {
                $payment->update(['payment_status' => 'paid']);
                $order->update([
                    'payment_status' => 'paid',
                    'order_status' => 'confirmed',
                ]);
                Log::info('LemonSqueezy payment confirmed via API', ['order_id' => $order->id]);
            } elseif (in_array($lsStatus, ['cancelled', 'expired', 'failed', 'fraudulent'])) {
                $payment->update(['payment_status' => 'failed']);
                $order->update([
                    'payment_status' => 'failed',
                    'order_status' => 'pending',
                ]);
                Log::info('LemonSqueezy payment confirmed as failed via API', [
                    'order_id' => $order->id,
                    'status' => $lsStatus,
                ]);
            }
        } catch (\Exception $e) {
            Log::error('LemonSqueezy status check error', [
                'order_id' => $order->id,
                'error' => $e->getMessage(),
            ]);
        }
    }
}
