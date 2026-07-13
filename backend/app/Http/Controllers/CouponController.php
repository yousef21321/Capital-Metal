<?php

namespace App\Http\Controllers;

use App\Models\Coupon;
use Illuminate\Http\Request;

class CouponController extends Controller
{
    public function index()
    {
        return response()->json(Coupon::all());
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'code' => 'required|string|max:100|unique:coupons',
            'discount_type' => 'required|in:percentage,fixed',
            'discount_value' => 'required|numeric|min:0',
            'min_order_amount' => 'nullable|numeric|min:0',
            'expiry_date' => 'nullable|date',
            'usage_limit' => 'nullable|integer|min:1',
        ]);

        $coupon = Coupon::create($validated);

        return response()->json($coupon, 201);
    }

    public function verify(Request $request)
    {
        $validated = $request->validate([
            'code' => 'required|string|max:100',
            'order_total' => 'required|numeric|min:0',
        ]);

        $coupon = Coupon::where('code', $validated['code'])->first();

        if (!$coupon) {
            return response()->json(['message' => 'Invalid coupon code.'], 404);
        }

        if ($coupon->expiry_date && now()->gt($coupon->expiry_date)) {
            return response()->json(['message' => 'Coupon has expired.'], 400);
        }

        if ($coupon->usage_limit && $coupon->used_count >= $coupon->usage_limit) {
            return response()->json(['message' => 'Coupon usage limit reached.'], 400);
        }

        if ($coupon->min_order_amount && $validated['order_total'] < $coupon->min_order_amount) {
            return response()->json(['message' => 'Minimum order amount not met.'], 400);
        }

        $discount = $coupon->discount_type === 'percentage'
            ? ($validated['order_total'] * $coupon->discount_value / 100)
            : $coupon->discount_value;

        return response()->json([
            'coupon' => $coupon,
            'discount' => round($discount, 2),
        ]);
    }

    public function update(Request $request, $id)
    {
        $coupon = Coupon::findOrFail($id);

        $validated = $request->validate([
            'code' => 'required|string|max:100|unique:coupons,code,' . $id,
            'discount_type' => 'required|in:percentage,fixed',
            'discount_value' => 'required|numeric|min:0',
            'min_order_amount' => 'nullable|numeric|min:0',
            'expiry_date' => 'nullable|date',
            'usage_limit' => 'nullable|integer|min:1',
        ]);

        $coupon->update($validated);

        return response()->json($coupon);
    }

    public function destroy($id)
    {
        Coupon::findOrFail($id)->delete();

        return response()->json(['message' => 'Coupon deleted.']);
    }
}
