<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Payment;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
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
}
