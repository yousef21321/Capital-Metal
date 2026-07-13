<?php

namespace App\Http\Controllers;

use App\Models\HeroImage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class HeroController extends Controller
{
    public function index()
    {
        return response()->json(HeroImage::orderBy('sort_order')->get());
    }

    public function store(Request $request)
    {
        $request->validate([
            'image' => 'required|file|mimes:jpg,jpeg,png,webp,gif|max:5120',
            'sort_order' => 'nullable|integer|min:0',
        ]);

        $path = $request->file('image')->store('hero', 'public');

        $heroImage = HeroImage::create([
            'image_url' => $path,
            'sort_order' => $request->input('sort_order', 0),
        ]);

        return response()->json($heroImage, 201);
    }

    public function destroy($id)
    {
        $heroImage = HeroImage::findOrFail($id);

        if (Storage::disk('public')->exists($heroImage->image_url)) {
            Storage::disk('public')->delete($heroImage->image_url);
        }

        $heroImage->delete();

        return response()->json(['message' => 'Hero image deleted.']);
    }
}
