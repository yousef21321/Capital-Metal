<?php

namespace App\Http\Controllers;

use App\Models\Cart;
use App\Models\CartItem;
use Illuminate\Http\Request;

class CartController extends Controller
{
    public function show(Request $request)
    {
        $cart = Cart::with('items.product.images')
            ->where('user_id', $request->user()->id)
            ->firstOrCreate(['user_id' => $request->user()->id]);

        return response()->json($cart);
    }

    public function addItem(Request $request)
    {
        $validated = $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity' => 'required|integer|min:1',
            'license_type' => 'nullable|in:personal,commercial,extended',
        ]);

        $cart = Cart::firstOrCreate(['user_id' => $request->user()->id]);

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

        $item = CartItem::whereHas('cart', function ($q) use ($request) {
            $q->where('user_id', $request->user()->id);
        })->findOrFail($itemId);

        $item->update($validated);

        return response()->json($item->cart->load('items.product.images'));
    }

    public function removeItem(Request $request, $itemId)
    {
        $item = CartItem::whereHas('cart', function ($q) use ($request) {
            $q->where('user_id', $request->user()->id);
        })->findOrFail($itemId);

        $item->delete();

        return response()->json(['message' => 'Item removed.']);
    }

    public function clear(Request $request)
    {
        $cart = Cart::where('user_id', $request->user()->id)->first();

        if ($cart) {
            $cart->items()->delete();
        }

        return response()->json(['message' => 'Cart cleared.']);
    }
}
