<?php

namespace App\Http\Controllers;

use App\Models\Setting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;

class ExchangeRateController extends Controller
{
    public function show()
    {
        $rate = Cache::remember('live_egp_to_usd_rate', now()->addHours(1), function () {
            return $this->fetchLiveRate();
        });

        return response()->json([
            'rate' => (float) $rate,
            'currency' => 'EGP',
            'target' => 'USD',
        ]);
    }

    protected function fetchLiveRate(): string
    {
        try {
            $response = Http::timeout(5)->get('https://open.er-api.com/v6/latest/USD');

            if ($response->successful()) {
                $data = $response->json();
                $egpRate = $data['rates']['EGP'] ?? null;

                if ($egpRate && is_numeric($egpRate)) {
                    Setting::setValue('egp_to_usd_rate', (string) $egpRate);

                    return (string) $egpRate;
                }
            }
        } catch (\Exception $e) {
            // Fall through to DB rate
        }

        return Setting::getValue('egp_to_usd_rate', '30.00');
    }

    public function update(Request $request)
    {
        $request->validate([
            'rate' => 'required|numeric|min:0.01',
        ]);

        Setting::setValue('egp_to_usd_rate', $request->rate);

        Cache::forget('live_egp_to_usd_rate');

        return response()->json([
            'rate' => (float) $request->rate,
            'message' => 'Exchange rate updated.',
        ]);
    }
}
