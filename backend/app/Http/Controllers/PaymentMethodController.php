<?php

namespace App\Http\Controllers;

use App\Models\PaymentMethod;

class PaymentMethodController extends Controller
{
    public function index()
    {
        return response()->json(PaymentMethod::where('is_active', true)->get());
    }
}
