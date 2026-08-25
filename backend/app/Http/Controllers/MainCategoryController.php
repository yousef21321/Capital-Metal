<?php

namespace App\Http\Controllers;

use App\Models\MainCategory;
use Illuminate\Http\Request;

class MainCategoryController extends Controller
{
    public function index()
    {
        $categories = MainCategory::withCount('products')->orderBy('sort_order')->orderBy('name')->get();

        return response()->json($categories);
    }

    public function show($slug)
    {
        $category = MainCategory::with([
            'products' => function ($q) {
                $q->where('status', 'published')->with(['images', 'variants.images']);
            },
            'products.inventory',
        ])->where('slug', $slug)->firstOrFail();

        return response()->json($category);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'slug' => 'required|string|max:255|unique:main_categories',
            'description' => 'nullable|string',
            'image' => 'nullable|file|mimes:jpg,jpeg,png,webp,gif|max:5120',
            'is_active' => 'nullable|boolean',
            'sort_order' => 'nullable|integer|min:0',
        ]);

        $imagePath = null;
        if ($request->hasFile('image')) {
            $file = $request->file('image');
            $path = $file->store('main-categories', 'public');
            $imagePath = $path;
        }

        unset($validated['image']);
        $validated['image_url'] = $imagePath;

        $category = MainCategory::create($validated);

        return response()->json($category, 201);
    }

    public function update(Request $request, $id)
    {
        $category = MainCategory::findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'slug' => 'sometimes|string|max:255|unique:main_categories,slug,'.$id,
            'description' => 'nullable|string',
            'image' => 'nullable|file|mimes:jpg,jpeg,png,webp,gif|max:5120',
            'is_active' => 'nullable|boolean',
            'sort_order' => 'nullable|integer|min:0',
        ]);

        if ($request->hasFile('image')) {
            if ($category->image_url && \Storage::disk('public')->exists($category->image_url)) {
                \Storage::disk('public')->delete($category->image_url);
            }
            $validated['image_url'] = $request->file('image')->store('main-categories', 'public');
        }

        unset($validated['image']);
        $category->update($validated);

        return response()->json($category);
    }

    public function destroy($id)
    {
        $category = MainCategory::findOrFail($id);

        if ($category->image_url && \Storage::disk('public')->exists($category->image_url)) {
            \Storage::disk('public')->delete($category->image_url);
        }

        $category->delete();

        return response()->json(['message' => 'Category deleted.']);
    }
}
