<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Cart;
use App\Models\Coupon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    protected function guestToken(Request $request): ?string
    {
        return $request->header('X-Guest-Token', $request->input('guest_token'));
    }

    protected function resolveUser(Request $request): ?int
    {
        return $request->user()?->id;
    }

    protected function cartIdentifier(Request $request): array
    {
        $userId = $this->resolveUser($request);

        if ($userId) {
            return ['user_id' => $userId];
        }

        $token = $this->guestToken($request);

        if ($token) {
            return ['guest_token' => $token];
        }

        return [];
    }

    public function index(Request $request)
    {
        $query = Order::with(['items.product', 'payments', 'user']);

        $user = $request->user();

        if ($user) {
            if ($user->role->name !== 'admin') {
                $query->where('user_id', $user->id);
            }
        } else {
            $token = $this->guestToken($request);

            if ($token) {
                $query->whereNull('user_id')->where('guest_name', '!=', '');
            } else {
                return response()->json(['data' => [], 'meta' => ['current_page' => 1, 'last_page' => 1]]);
            }
        }

        if ($request->status) {
            $query->where('order_status', $request->status);
        }

        if ($request->payment_status) {
            $query->where('payment_status', $request->payment_status);
        }

        return response()->json($query->latest()->paginate($request->per_page ?? 20));
    }

    public function show($id, Request $request)
    {
        $order = Order::with([
            'items.product.images', 'payments.paymentMethod',
            'refunds', 'user', 'affiliate',
        ])->findOrFail($id);

        $user = $request->user();

        if ($user && $user->role->name === 'user' && $order->user_id !== $user->id) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        if (!$user && $order->user_id !== null) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        return response()->json($order);
    }

    public function checkout(Request $request)
    {
        $validated = $request->validate([
            'currency' => 'required|in:EGP,USD',
            'shipping_cost' => 'nullable|numeric|min:0',
            'notes' => 'nullable|string',
            'address_id' => 'nullable|exists:addresses,id',
            'coupon_code' => 'nullable|string|max:100',
            'guest_name' => 'nullable|string|max:255',
            'guest_phone' => 'nullable|string|max:50',
        ]);

        $identifier = $this->cartIdentifier($request);

        if (empty($identifier)) {
            return response()->json(['message' => 'Cart identifier required.'], 400);
        }

        $cart = Cart::with('items.product')
            ->where($identifier)
            ->first();

        if (!$cart || $cart->items->isEmpty()) {
            return response()->json(['message' => 'Cart is empty.'], 400);
        }

        $userId = $this->resolveUser($request);

        if (!$userId && empty($validated['guest_name'])) {
            return response()->json(['message' => 'Guest name is required for guest checkout.'], 422);
        }

        $orderNumber = 'ORD-' . strtoupper(uniqid());
        $subtotal = 0;
        $orderItems = [];

        foreach ($cart->items as $item) {
            $price = $validated['currency'] === 'EGP' ? $item->product->price_egp : $item->product->price_usd;
            $subtotal += $price * $item->quantity;
            $orderItems[] = [
                'product_id' => $item->product_id,
                'quantity' => $item->quantity,
                'price' => $price,
                'license_type' => $item->license_type,
            ];
        }

        $shippingCost = $validated['shipping_cost'] ?? 0;

        [$discount, $couponId] = $this->resolveCoupon(
            $validated['coupon_code'] ?? null,
            $subtotal
        );

        $totalAmount = max(0, ($subtotal + $shippingCost) - $discount);

        return DB::transaction(function () use (
            $request, $validated, $userId, $orderNumber, $subtotal,
            $shippingCost, $discount, $couponId, $totalAmount, $orderItems, $cart
        ) {
            $orderData = [
                'user_id' => $userId,
                'order_number' => $orderNumber,
                'currency' => $validated['currency'],
                'subtotal' => $subtotal,
                'shipping_cost' => $shippingCost,
                'discount' => $discount,
                'coupon_id' => $couponId,
                'total_amount' => $totalAmount,
                'payment_status' => 'pending',
                'order_status' => 'pending',
                'notes' => $validated['notes'] ?? null,
            ];

            // Guest fields
            if (!$userId) {
                $orderData['guest_name'] = $validated['guest_name'];
                $orderData['guest_phone'] = $validated['guest_phone'] ?? null;
            }

            $order = Order::create($orderData);

            foreach ($orderItems as $item) {
                $order->items()->create($item);
            }

            if ($couponId) {
                Coupon::where('id', $couponId)->increment('used_count');
            }

            $cart->items()->delete();

            return response()->json($order->load('items.product'), 201);
        });
    }

    /**
     * Validate a coupon code against an order subtotal and return
     * [discount, couponId]. Throws a validation exception on failure.
     */
    protected function resolveCoupon(?string $code, float $subtotal): array
    {
        if (!$code) {
            return [0, null];
        }

        $coupon = Coupon::where('code', $code)->first();

        if (!$coupon) {
            abort(response()->json(['message' => 'Invalid coupon code.'], 422));
        }

        if ($coupon->expiry_date && now()->gt($coupon->expiry_date)) {
            abort(response()->json(['message' => 'Coupon has expired.'], 422));
        }

        if ($coupon->usage_limit && $coupon->used_count >= $coupon->usage_limit) {
            abort(response()->json(['message' => 'Coupon usage limit reached.'], 422));
        }

        if ($coupon->min_order_amount && $subtotal < $coupon->min_order_amount) {
            abort(response()->json(['message' => 'Minimum order amount not met.'], 422));
        }

        $discount = $coupon->discount_type === 'percentage'
            ? ($subtotal * $coupon->discount_value / 100)
            : (float) $coupon->discount_value;

        $discount = min($discount, $subtotal);

        return [round($discount, 2), $coupon->id];
    }

    public function updateStatus(Request $request, $id)
    {
        $validated = $request->validate([
            'order_status' => 'sometimes|in:pending,under_review,confirmed,processing,shipped,delivered,cancelled',
            'payment_status' => 'sometimes|in:pending,paid,failed,refunded',
            'shipping_tracking_number' => 'nullable|string|max:255',
        ]);

        $order = Order::findOrFail($id);
        $order->update($validated);

        return response()->json($order->load('items.product'));
    }

    public function myOrders(Request $request)
    {
        $user = $request->user();

        if (!$user) {
            return response()->json(['data' => [], 'meta' => ['current_page' => 1, 'last_page' => 1]]);
        }

        $orders = Order::with(['items.product.images', 'payments'])
            ->where('user_id', $user->id)
            ->latest()
            ->paginate($request->per_page ?? 20);

        return response()->json($orders);
    }
}
