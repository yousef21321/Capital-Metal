<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Request;

class TesterProductController extends Controller
{
    public function index()
    {
        $products = Product::with(['designer', 'images'])
            ->where('status', 'pending_tester_review')
            ->orWhere('status', 'modification_requested')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($products);
    }

    public function approve($id)
    {
        $product = Product::findOrFail($id);
        abort_unless(in_array($product->status, ['pending_tester_review', 'modification_requested']), 422,
            'Product is not pending review.');

        $product->update([
            'status' => 'published',
            'tested_by' => request()->user()->id,
            'tested_at' => now(),
            'tester_comment' => null,
            'tester_suggested_price_egp' => null,
            'tester_suggested_price_usd' => null,
        ]);

        return response()->json(['message' => 'Product approved and published.']);
    }

    public function returnWithFeedback(Request $request, $id)
    {
        $product = Product::findOrFail($id);
        abort_unless(in_array($product->status, ['pending_tester_review', 'modification_requested']), 422,
            'Product is not pending review.');

        $data = $request->validate([
            'suggested_price_egp' => 'nullable|numeric|min:0',
            'suggested_price_usd' => 'nullable|numeric|min:0',
            'comment'             => 'nullable|string|max:1000',
        ]);

        $product->update([
            'status' => 'modification_requested',
            'tested_by' => $request->user()->id,
            'tested_at' => now(),
            'tester_suggested_price_egp' => $data['suggested_price_egp'] ?? null,
            'tester_suggested_price_usd' => $data['suggested_price_usd'] ?? null,
            'tester_comment' => $data['comment'] ?? null,
        ]);

        return response()->json(['message' => 'Product returned with feedback.']);
    }

    public function pendingCount()
    {
        $count = Product::where('status', 'pending_tester_review')->count();
        return response()->json(['count' => $count]);
    }
}
