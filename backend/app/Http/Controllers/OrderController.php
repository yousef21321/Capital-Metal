<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Cart;
use App\Models\Coupon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\PersonalAccessToken;
use ZipArchive;

class OrderController extends Controller
{
    protected function guestToken(Request $request): ?string
    {
        return $request->header('X-Guest-Token', $request->input('guest_token'));
    }

    protected function resolveUser(Request $request): ?int
    {
        $userId = $request->user()?->id;

        if (!$userId) {
            $token = $request->bearerToken();
            if ($token) {
                $accessToken = PersonalAccessToken::findToken($token);
                $userId = $accessToken?->tokenable?->id;
            }
        }

        return $userId;
    }

    protected function cartIdentifier(Request $request): array
    {
        $userId = $this->resolveUser($request);

        if ($userId) {
            return ['user_id' => $userId];
        }

        $guestToken = $this->guestToken($request);

        if ($guestToken) {
            return ['guest_token' => $guestToken];
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
            'payment_method_id' => 'nullable|exists:payment_methods,id',
            'guest_name' => 'nullable|string|max:255',
            'guest_phone' => 'nullable|string|max:50',
            'guest_governorate' => 'nullable|string|max:100',
            'guest_city' => 'nullable|string|max:100',
            'guest_address_line' => 'required_with:guest_name|string|max:255',
            'guest_postal_code' => 'nullable|string|max:20',
        ]);

        $userId = $this->resolveUser($request);

        if (!$userId && !$this->guestToken($request)) {
            return response()->json(['message' => 'Authentication required. Please login or provide guest details.'], 401);
        }

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
            $guestToken = $this->guestToken($request);

            $orderData = [
                'user_id' => $userId,
                'guest_token' => $guestToken,
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
                $orderData['guest_name'] = $validated['guest_name'] ?? null;
                $orderData['guest_phone'] = $validated['guest_phone'] ?? null;
                $orderData['guest_governorate'] = $validated['guest_governorate'] ?? null;
                $orderData['guest_city'] = $validated['guest_city'] ?? null;
                $orderData['guest_address_line'] = $validated['guest_address_line'] ?? null;
                $orderData['guest_postal_code'] = $validated['guest_postal_code'] ?? null;
            }

            $order = Order::create($orderData);

            foreach ($orderItems as $item) {
                $order->items()->create($item);
            }

            if (($validated['payment_method_id'] ?? null) == 2) {
                $order->payments()->create([
                    'payment_method_id' => 2,
                    'amount' => $totalAmount,
                    'currency' => $validated['currency'],
                    'payment_status' => 'pending',
                ]);
                $order->update(['payment_status' => 'pending']);
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

    public function destroy($id)
    {
        $order = Order::with('items', 'payments')->findOrFail($id);
        $order->items()->delete();
        $order->payments()->delete();
        $order->delete();

        return response()->json(['message' => 'Order deleted.']);
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

    public function downloadItem($orderId, $itemId, Request $request)
    {
        $order = Order::with('items.product.digitalFiles')->findOrFail($orderId);

        $userId = $this->resolveUser($request);
        $guestToken = $this->guestToken($request);

        $ownsOrder = false;
        if ($userId && $order->user_id === $userId) {
            $ownsOrder = true;
        } elseif ($guestToken && $order->guest_token === $guestToken) {
            $ownsOrder = true;
        }

        if (!$ownsOrder) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        if ($order->payment_status !== 'paid') {
            return response()->json(['message' => 'Payment required.'], 402);
        }

        $item = $order->items()->where('id', $itemId)->first();

        if (!$item) {
            return response()->json(['message' => 'Item not found in this order.'], 404);
        }

        $product = $item->product;
        $digitalFiles = $product->digitalFiles;

        if ($digitalFiles->count() > 1) {
            $zipPath = storage_path("app/public/downloads/order-{$orderId}-item-{$itemId}.zip");

            if (!File::exists($zipPath)) {
                $zip = new ZipArchive();
                if ($zip->open($zipPath, ZipArchive::CREATE | ZipArchive::OVERWRITE) === true) {
                    foreach ($digitalFiles as $df) {
                        $filePath = Storage::disk('public')->path($df->file_url);
                        if (File::exists($filePath)) {
                            $zip->addFile($filePath, basename($df->file_url));
                        }
                    }
                    $zip->close();
                }
            }

            return response()->download($zipPath, $product->name . '.zip')->deleteFileAfterSend(true);
        }

        $filePath = $product->design_file_path;

        if ($digitalFiles->count() === 1) {
            $filePath = $digitalFiles->first()->file_url;
        }

        if (!$filePath || !Storage::disk('public')->exists($filePath)) {
            return response()->json(['message' => 'File not available.'], 404);
        }

        return Storage::disk('public')->download($filePath);
    }

    public function myOrders(Request $request)
    {
        $userId = $this->resolveUser($request);
        $guestToken = $this->guestToken($request);

        $orders = Order::with(['items.product.images', 'items.product.digitalFiles', 'payments'])
            ->when($userId, fn($q) => $q->where('user_id', $userId))
            ->when(!$userId && $guestToken, fn($q) => $q->where('guest_token', $guestToken))
            ->when(!$userId && !$guestToken, fn($q) => $q->whereRaw('1 = 0'))
            ->latest()
            ->paginate($request->per_page ?? 20);

        return response()->json($orders);
    }
}
