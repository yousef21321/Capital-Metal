<?php

namespace App\Http\Controllers;

use App\Models\Setting;
use Illuminate\Http\Request;

class ExchangeRateController extends Controller
{
    public function show()
    {
        $rate = Setting::getValue('egp_to_usd_rate', '30.00');
        return response()->json([
            'rate' => (float) $rate,
            'currency' => 'EGP',
            'target' => 'USD',
        ]);
    }

    public function update(Request $request)
    {
        $request->validate([
            'rate' => 'required|numeric|min:0.01',
        ]);

        Setting::setValue('egp_to_usd_rate', $request->rate);

        return response()->json([
            'rate' => (float) $request->rate,
            'message' => 'Exchange rate updated.',
        ]);
    }
}
