<?php

namespace App\Http\Controllers;

use App\Models\Affiliate;
use App\Models\AffiliateEarning;
use Illuminate\Http\Request;

class AffiliateController extends Controller
{
    public function myProfile(Request $request)
    {
        $affiliate = Affiliate::with('earnings.order')
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$affiliate) {
            return response()->json(['message' => 'Not an affiliate.'], 404);
        }

        return response()->json($affiliate);
    }

    public function register(Request $request)
    {
        $validated = $request->validate([
            'referral_code' => 'nullable|string|max:100|unique:affiliates',
            'commission_percentage' => 'nullable|numeric|min:0|max:100',
        ]);

        $affiliate = Affiliate::create([
            'user_id' => $request->user()->id,
            'referral_code' => $validated['referral_code'] ?? 'REF-' . strtoupper(uniqid()),
            'commission_percentage' => $validated['commission_percentage'] ?? 10.00,
        ]);

        return response()->json($affiliate, 201);
    }

    public function earnings(Request $request)
    {
        $affiliate = Affiliate::where('user_id', $request->user()->id)->firstOrFail();

        $earnings = AffiliateEarning::with('order')
            ->where('affiliate_id', $affiliate->id)
            ->latest()
            ->paginate($request->per_page ?? 20);

        return response()->json($earnings);
    }
}
