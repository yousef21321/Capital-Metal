<?php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Models\ProductVariant;
use App\Models\ProductVariantImage;
use App\Services\ImageOptimizer;
use Illuminate\Http\Request;

class ProductVariantController extends Controller
{
    public function index(Product $product)
    {
        $variants = $product->variants()->with('images')->get();
        return response()->json($variants);
    }

    public function store(Request $request, Product $product)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price_egp' => 'required|numeric|min:0',
            'price_usd' => 'nullable|numeric|min:0',
            'cost' => 'nullable|numeric|min:0',
            'sku' => 'nullable|string|max:100',
            'material' => 'nullable|string|max:100',
            'manufacturing_method' => 'nullable|string|max:100',
            'stock_quantity' => 'nullable|integer|min:0',
            'is_active' => 'nullable|boolean',
            'sort_order' => 'nullable|integer|min:0',
        ]);

        $maxSort = $product->variants()->max('sort_order') ?? -1;
        if (!isset($validated['sort_order'])) {
            $validated['sort_order'] = $maxSort + 1;
        }

        $variant = $product->variants()->create($validated);

        return response()->json($variant->load('images'), 201);
    }

    public function update(Request $request, Product $product, $variantId)
    {
        $variant = $product->variants()->findOrFail($variantId);

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'price_egp' => 'sometimes|numeric|min:0',
            'price_usd' => 'nullable|numeric|min:0',
            'cost' => 'nullable|numeric|min:0',
            'sku' => 'nullable|string|max:100',
            'material' => 'nullable|string|max:100',
            'manufacturing_method' => 'nullable|string|max:100',
            'stock_quantity' => 'nullable|integer|min:0',
            'is_active' => 'nullable|boolean',
            'sort_order' => 'nullable|integer|min:0',
        ]);

        $variant->update($validated);

        return response()->json($variant->load('images'));
    }

    public function destroy(Product $product, $variantId)
    {
        $variant = $product->variants()->findOrFail($variantId);

        foreach ($variant->images as $image) {
            if (\Illuminate\Support\Facades\Storage::disk('public')->exists($image->image_url)) {
                \Illuminate\Support\Facades\Storage::disk('public')->delete($image->image_url);
            }
        }

        $variant->delete();

        return response()->json(['message' => 'Variant deleted.']);
    }

    public function uploadImage(Request $request, Product $product, $variantId)
    {
        $variant = $product->variants()->findOrFail($variantId);

        $request->validate([
            'image' => 'required|file|mimes:jpg,jpeg,png,webp,gif|max:5120',
            'sort_order' => 'nullable|integer|min:0',
        ]);

        $optimizer = app(ImageOptimizer::class);
        $path = $optimizer->optimizeUploadedFile($request->file('image'), "products/{$product->id}/variants/{$variant->id}");

        $maxSort = $variant->images()->max('sort_order') ?? -1;
        $image = $variant->images()->create([
            'image_url' => $path,
            'sort_order' => $request->input('sort_order', $maxSort + 1),
        ]);

        return response()->json($image, 201);
    }

    public function reorderImages(Request $request, Product $product, $variantId)
    {
        $variant = $product->variants()->findOrFail($variantId);

        $request->validate([
            'image_ids' => 'required|array',
            'image_ids.*' => 'integer|exists:product_variant_images,id',
        ]);

        foreach ($request->image_ids as $index => $imageId) {
            ProductVariantImage::where('id', $imageId)
                ->where('variant_id', $variant->id)
                ->update(['sort_order' => $index]);
        }

        return response()->json(['message' => 'Images reordered.']);
    }

    public function destroyImage(Product $product, $variantId, $imageId)
    {
        $variant = $product->variants()->findOrFail($variantId);
        $image = $variant->images()->findOrFail($imageId);

        if (\Illuminate\Support\Facades\Storage::disk('public')->exists($image->image_url)) {
            \Illuminate\Support\Facades\Storage::disk('public')->delete($image->image_url);
        }

        $image->delete();

        return response()->json(['message' => 'Image deleted.']);
    }
}
