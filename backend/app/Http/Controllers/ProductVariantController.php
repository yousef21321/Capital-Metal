<?php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Models\ProductVariant;
use App\Models\ProductVariantImage;
use App\Services\ImageOptimizer;
use App\Services\StoxService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

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
            'fake_price_egp' => 'nullable|numeric|min:0',
            'fake_price_usd' => 'nullable|numeric|min:0',
            'cost' => 'nullable|numeric|min:0',
            'sku' => 'nullable|string|max:100',
            'material' => 'nullable|string|max:100',
            'manufacturing_method' => 'nullable|string|max:100',
            'stock_quantity' => 'nullable|integer|min:0',
            'star_rating' => 'nullable|numeric|min:0|max:5',
            'sold_count' => 'nullable|integer|min:0',
            'is_active' => 'nullable|boolean',
        if (! isset($validated['sort_order'])) {
            $validated['sort_order'] = $maxSort + 1;
        }

        $variant = $product->variants()->create($validated);

        $this->syncVariantToStox($variant, $product);

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
            'fake_price_egp' => 'nullable|numeric|min:0',
            'fake_price_usd' => 'nullable|numeric|min:0',
            'cost' => 'nullable|numeric|min:0',
            'sku' => 'nullable|string|max:100',
            'material' => 'nullable|string|max:100',
            'manufacturing_method' => 'nullable|string|max:100',
            'stock_quantity' => 'nullable|integer|min:0',
            'star_rating' => 'nullable|numeric|min:0|max:5',
            'sold_count' => 'nullable|integer|min:0',
            'is_active' => 'nullable|boolean',
            'sort_order' => 'nullable|integer|min:0',
        ]);

        $variant->update($validated);

        $this->syncVariantToStox($variant, $product);

        return response()->json($variant->load('images'));
    }

    public function destroy(Product $product, $variantId)
    {
        $variant = $product->variants()->findOrFail($variantId);

        foreach ($variant->images as $image) {
            if (Storage::disk('public')->exists($image->image_url)) {
                Storage::disk('public')->delete($image->image_url);
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

        if (Storage::disk('public')->exists($image->image_url)) {
            Storage::disk('public')->delete($image->image_url);
        }

        $image->delete();

        return response()->json(['message' => 'Image deleted.']);
    }

    private function syncVariantToStox(ProductVariant $variant, Product $product): void
    {
        if ($product->product_type !== 'physical') {
            return;
        }

        /** @var StoxService $stox */
        $stox = app(StoxService::class);

        if (! $stox->isConfigured()) {
            return;
        }

        $sku = $variant->sku ?: strtoupper($product->slug.'-'.$variant->name);

        $imagePaths = $variant->images->pluck('image_url')->toArray();
        $imageUrls = array_map(fn ($path) => $stox->buildImageUrl($path), $imagePaths);

        $result = $stox->createProduct(
            name: $product->name.' - '.$variant->name,
            sku: $sku,
            description: $variant->description ?: $product->description,
            images: $imageUrls,
        );

        if ($result && isset($result['id'])) {
            $variant->update(['stox_product_id' => $result['id']]);
        } elseif (! $result) {
            $fallbackSku = strtoupper($product->slug.'-'.$variant->name).'-'.$variant->id;
            $result = $stox->createProduct(
                name: $product->name.' - '.$variant->name,
                sku: $fallbackSku,
                description: $variant->description ?: $product->description,
                images: $imageUrls,
            );
            if ($result && isset($result['id'])) {
                $variant->update(['stox_product_id' => $result['id']]);
            }
        }
    }
}
