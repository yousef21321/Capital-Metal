<?php

namespace App\Http\Controllers;

use App\Jobs\SyncStoxProductJob;
use App\Models\Product;
use App\Models\ProductImage;
use App\Services\ImageOptimizer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $query = Product::with(['images', 'inventory', 'reviews', 'variants.images']);

        if ($request->product_type) {
            $query->where('product_type', $request->product_type);
        }

        if ($request->status === 'all') {
            // Admin: no status filter
        } elseif ($request->status) {
            $query->where('status', $request->status);
        } else {
            // Public: only show published products
            $query->where('status', 'published');
        }

        if ($request->search) {
            $query->where(function ($q) use ($request) {
                $q->where('name', 'like', "%{$request->search}%")
                    ->orWhere('slug', 'like', "%{$request->search}%")
                    ->orWhere('description', 'like', "%{$request->search}%")
                    ->orWhere('material', 'like', "%{$request->search}%")
                    ->orWhere('manufacturing_method', 'like', "%{$request->search}%");
            });
        }

        if ($request->material) {
            $query->where('material', $request->material);
        }

        if ($request->manufacturing_method) {
            $query->where('manufacturing_method', $request->manufacturing_method);
        }

        if ($request->tag) {
            $query->whereJsonContains('tags', $request->tag);
        }

        return response()->json($query->paginate($request->per_page ?? 20));
    }

    public function show($slug)
    {
        $product = Product::with([
            'images', 'inventory', 'digitalFiles', 'licenseAgreements',
            'reviews.user', 'analytics', 'variants.images',
        ])->where('slug', $slug)->firstOrFail();

        return response()->json($product);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'slug' => 'required|string|max:255|unique:products',
            'description' => 'nullable|string',
            'product_type' => 'required|in:physical,digital',
            'price_egp' => 'nullable|numeric|min:0',
            'price_usd' => 'nullable|numeric|min:0',
            'cost' => 'nullable|numeric|min:0',
            'status' => 'nullable|string|max:50',
            'publish_date' => 'nullable|date',
            'country_availability' => 'nullable|string',
            'material' => 'nullable|string|max:100',
            'manufacturing_method' => 'nullable|string|max:100',
            'type_sample' => 'nullable|string|max:100',
            'sku' => 'nullable|string|max:100',
            'images' => 'nullable|array|max:10',
            'images.*' => 'file|mimes:jpg,jpeg,png,webp,gif|max:5120',
        ]);

        $sku = $validated['sku'] ?? null;
        $imageFiles = $validated['images'] ?? [];
        unset($validated['sku'], $validated['images']);

        $product = Product::create($validated);

        if ($product->product_type === 'physical' && $sku) {
            $product->inventory()->create([
                'sku' => $sku,
                'stock_quantity' => 0,
            ]);
        }

        $storedImageUrls = [];
        $optimizer = app(ImageOptimizer::class);

        foreach ($imageFiles as $index => $file) {
            $path = $optimizer->optimizeUploadedFile($file, "products/{$product->id}");
            $product->images()->create([
                'image_url' => $path,
                'sort_order' => $index,
            ]);
            $storedImageUrls[] = $path;
        }

        if ($product->product_type === 'physical') {
            $dispatchSku = $sku ?: $product->slug;
            SyncStoxProductJob::dispatch($product->id, $dispatchSku, $storedImageUrls);
        }

        return response()->json(['product' => $product->load('images', 'inventory')], 201);
    }

    public function update(Request $request, $id)
    {
        $product = Product::findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'slug' => 'sometimes|string|max:255|unique:products,slug,'.$id,
            'description' => 'nullable|string',
            'product_type' => 'sometimes|in:physical,digital',
            'price_egp' => 'nullable|numeric|min:0',
            'price_usd' => 'nullable|numeric|min:0',
            'cost' => 'nullable|numeric|min:0',
            'status' => 'nullable|string|max:50',
            'publish_date' => 'nullable|date',
            'country_availability' => 'nullable|string',
            'material' => 'nullable|string|max:100',
            'manufacturing_method' => 'nullable|string|max:100',
            'type_sample' => 'nullable|string|max:100',
            'sku' => 'nullable|string|max:100',
        ]);

        $sku = $validated['sku'] ?? null;
        unset($validated['sku']);

        $product->update($validated);

        if ($product->product_type === 'physical' && $sku !== null) {
            $product->inventory()->updateOrCreate(
                ['product_id' => $product->id],
                ['sku' => $sku]
            );
        }

        return response()->json($product->load('images', 'inventory'));
    }

    public function destroy($id)
    {
        Product::findOrFail($id)->delete();

        return response()->json(['message' => 'Product deleted.']);
    }

    public function uploadImage(Request $request, $id)
    {
        $product = Product::findOrFail($id);

        $request->validate([
            'image' => 'required|file|mimes:jpg,jpeg,png,webp,gif|max:5120',
            'sort_order' => 'nullable|integer|min:0',
        ]);

        $optimizer = app(ImageOptimizer::class);
        $path = $optimizer->optimizeUploadedFile($request->file('image'), "products/{$product->id}");

        $image = $product->images()->create([
            'image_url' => $path,
            'sort_order' => $request->input('sort_order', 0),
        ]);

        $this->syncImagesToStox($product);

        return response()->json($image, 201);
    }

    public function reorderImages(Request $request, $id)
    {
        $product = Product::findOrFail($id);

        $request->validate([
            'image_ids' => 'required|array',
            'image_ids.*' => 'integer|exists:product_images,id',
        ]);

        foreach ($request->image_ids as $index => $imageId) {
            ProductImage::where('id', $imageId)
                ->where('product_id', $product->id)
                ->update(['sort_order' => $index]);
        }

        $this->syncImagesToStox($product);

        return response()->json(['message' => 'Images reordered.']);
    }

    public function destroyImage($id, $imageId)
    {
        $product = Product::findOrFail($id);
        $image = $product->images()->findOrFail($imageId);

        if (Storage::disk('public')->exists($image->image_url)) {
            Storage::disk('public')->delete($image->image_url);
        }

        $image->delete();

        $this->syncImagesToStox($product);

        return response()->json(['message' => 'Image deleted.']);
    }

    public function updateInventory(Request $request, $id)
    {
        $product = Product::findOrFail($id);

        $validated = $request->validate([
            'sku' => 'required|string|max:100|unique:inventory,sku,'.($product->inventory?->id ?? 'NULL').',id',
            'stock_quantity' => 'nullable|integer|min:0',
            'low_stock_alert' => 'nullable|integer|min:0',
            'warehouse_location' => 'nullable|string|max:255',
        ]);

        $inventory = $product->inventory()->updateOrCreate(
            ['product_id' => $product->id],
            $validated
        );

        return response()->json(['inventory' => $inventory]);
    }

    public function addDigitalFile(Request $request, $id)
    {
        $product = Product::findOrFail($id);

        $validated = $request->validate([
            'file_url' => 'required|string|max:500',
            'version' => 'nullable|string|max:50',
            'max_downloads' => 'nullable|integer|min:1',
            'link_expiry_days' => 'nullable|integer|min:1',
            'license_type' => 'required|in:personal,commercial,extended',
        ]);

        $file = $product->digitalFiles()->create($validated);

        return response()->json($file, 201);
    }

    private function syncImagesToStox(Product $product): void
    {
        if ($product->product_type !== 'physical' || ! $product->stox_product_id) {
            return;
        }

        SyncStoxProductJob::dispatch($product->id);
    }
}
