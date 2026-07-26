<?php

namespace App\Http\Controllers;

use App\Models\ShippingRate;
use Illuminate\Http\Request;

class ShippingRateController extends Controller
{
    public function index()
    {
        return response()->json(ShippingRate::orderBy('cost')->get());
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'region' => 'required|string|max:255',
            'governorate' => 'required|string|max:255|unique:shipping_rates,governorate',
            'cost' => 'required|numeric|min:0',
        ]);

        $rate = ShippingRate::create($validated);

        return response()->json($rate, 201);
    }

    public function update(Request $request, $id)
    {
        $rate = ShippingRate::findOrFail($id);

        $validated = $request->validate([
            'region' => 'sometimes|string|max:255',
            'governorate' => 'sometimes|string|max:255|unique:shipping_rates,governorate,'.$rate->id,
            'cost' => 'sometimes|numeric|min:0',
        ]);

        $rate->update($validated);

        return response()->json($rate);
    }

    public function destroy($id)
    {
        ShippingRate::findOrFail($id)->delete();

        return response()->json(['message' => 'Shipping rate deleted.']);
    }

    public function byGovernorate($governorate)
    {
        $rate = ShippingRate::where('governorate', $governorate)->first();

        if (! $rate) {
            return response()->json(['message' => 'No shipping rate found for this governorate.'], 404);
        }

        return response()->json($rate);
    }
}
