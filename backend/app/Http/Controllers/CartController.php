<?php

namespace App\Http\Controllers;

use App\Models\Cart;
use App\Models\CartItem;
use Illuminate\Http\Request;

class CartController extends Controller
{
    protected function cartIdentifier(Request $request): array
    {
        if ($request->user()) {
            return ['user_id' => $request->user()->id];
        }

        $token = $request->header('X-Guest-Token', $request->input('guest_token'));

        if (!$token) {
            return [];
        }

        return ['guest_token' => $token];
    }

    public function show(Request $request)
    {
        $identifier = $this->cartIdentifier($request);

        if (empty($identifier)) {
            return response()->json(['items' => []]);
        }

        $cart = Cart::with('items.product.images')
            ->where($identifier)
            ->firstOrCreate($identifier);

        return response()->json($cart);
    }

    public function addItem(Request $request)
    {
        $validated = $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity' => 'required|integer|min:1',
            'license_type' => 'nullable|in:personal,commercial,extended',
        ]);

        $identifier = $this->cartIdentifier($request);

        if (empty($identifier)) {
            return response()->json(['message' => 'Authentication required or provide a guest token.'], 401);
        }

        $cart = Cart::firstOrCreate($identifier);

        $item = $cart->items()->updateOrCreate(
            ['product_id' => $validated['product_id']],
            ['quantity' => $validated['quantity'], 'license_type' => $validated['license_type'] ?? null]
        );

        return response()->json($cart->load('items.product.images'), 201);
    }

    public function updateItem(Request $request, $itemId)
    {
        $validated = $request->validate([
            'quantity' => 'required|integer|min:1',
            'license_type' => 'nullable|in:personal,commercial,extended',
        ]);

        $identifier = $this->cartIdentifier($request);

        if (empty($identifier)) {
            return response()->json(['message' => 'Authentication required.'], 401);
        }

        $item = CartItem::whereHas('cart', function ($q) use ($identifier) {
            $q->where($identifier);
        })->findOrFail($itemId);

        $item->update($validated);

        return response()->json($item->cart->load('items.product.images'));
    }

    public function removeItem(Request $request, $itemId)
    {
        $identifier = $this->cartIdentifier($request);

        if (empty($identifier)) {
            return response()->json(['message' => 'Authentication required.'], 401);
        }

        $item = CartItem::whereHas('cart', function ($q) use ($identifier) {
            $q->where($identifier);
        })->findOrFail($itemId);

        $item->delete();

        return response()->json(['message' => 'Item removed.']);
    }

    public function clear(Request $request)
    {
        $identifier = $this->cartIdentifier($request);

        if (empty($identifier)) {
            return response()->json(['message' => 'Authentication required.'], 401);
        }

        $cart = Cart::where($identifier)->first();

        if ($cart) {
            $cart->items()->delete();
        }

        return response()->json(['message' => 'Cart cleared.']);
    }
}
