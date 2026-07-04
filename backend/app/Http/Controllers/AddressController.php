<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class AddressController extends Controller
{
    public function index(Request $request)
    {
        return response()->json($request->user()->addresses);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'full_name' => 'nullable|string|max:150',
            'phone' => 'nullable|string|max:20',
            'country' => 'nullable|string|max:100',
            'governorate' => 'nullable|string|max:100',
            'city' => 'nullable|string|max:100',
            'address_line' => 'nullable|string',
            'postal_code' => 'nullable|string|max:20',
            'is_default' => 'nullable|boolean',
        ]);

        if ($validated['is_default'] ?? false) {
            $request->user()->addresses()->update(['is_default' => false]);
        }

        $address = $request->user()->addresses()->create($validated);

        return response()->json($address, 201);
    }

    public function update(Request $request, $id)
    {
        $address = $request->user()->addresses()->findOrFail($id);

        $validated = $request->validate([
            'full_name' => 'nullable|string|max:150',
            'phone' => 'nullable|string|max:20',
            'country' => 'nullable|string|max:100',
            'governorate' => 'nullable|string|max:100',
            'city' => 'nullable|string|max:100',
            'address_line' => 'nullable|string',
            'postal_code' => 'nullable|string|max:20',
            'is_default' => 'nullable|boolean',
        ]);

        if ($validated['is_default'] ?? false) {
            $request->user()->addresses()->where('id', '!=', $id)->update(['is_default' => false]);
        }

        $address->update($validated);

        return response()->json($address);
    }

    public function destroy(Request $request, $id)
    {
        $request->user()->addresses()->findOrFail($id)->delete();

        return response()->json(['message' => 'Address deleted.']);
    }
}
