<?php

namespace App\Http\Controllers;

use App\Jobs\SyncStoxProductJob;
use App\Models\Product;
use App\Models\ProductImage;
use App\Models\MainCategory;
use App\Services\ImageOptimizer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $query = Product::with(['images', 'inventory', 'reviews', 'variants.images', 'mainCategory']);

        if ($request->main_category_id) {
            $query->where('main_category_id', $request->main_category_id);
        }

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
            'reviews.user', 'analytics', 'variants.images', 'mainCategory',
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
            'main_category_id' => 'nullable|exists:main_categories,id',
            'price_egp' => 'nullable|numeric|min:0',
            'price_usd' => 'nullable|numeric|min:0',
            'fake_price_egp' => 'nullable|numeric|min:0',
            'fake_price_usd' => 'nullable|numeric|min:0',
            'cost' => 'nullable|numeric|min:0',
            'status' => 'nullable|string|max:50',
            'publish_date' => 'nullable|date',
            'country_availability' => 'nullable|string',
            'material' => 'nullable|string|max:100',
            'manufacturing_method' => 'nullable|string|max:100',
            'type_sample' => 'nullable|string|max:100',
            'star_rating' => 'nullable|numeric|min:0|max:5',
            'sold_count' => 'nullable|integer|min:0',
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
            'main_category_id' => 'nullable|exists:main_categories,id',
            'price_egp' => 'nullable|numeric|min:0',
            'price_usd' => 'nullable|numeric|min:0',
            'fake_price_egp' => 'nullable|numeric|min:0',
            'fake_price_usd' => 'nullable|numeric|min:0',
            'cost' => 'nullable|numeric|min:0',
            'status' => 'nullable|string|max:50',
            'publish_date' => 'nullable|date',
            'country_availability' => 'nullable|string',
            'material' => 'nullable|string|max:100',
            'manufacturing_method' => 'nullable|string|max:100',
            'type_sample' => 'nullable|string|max:100',
            'star_rating' => 'nullable|numeric|min:0|max:5',
            'sold_count' => 'nullable|integer|min:0',
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

    public function template()
    {
        $headers = ['id','name','slug','product_type','main_category','description','price_egp','price_usd','fake_price_egp','fake_price_usd','cost','status','publish_date','country_availability','material','manufacturing_method','type_sample','star_rating','sold_count','sku'];

        $example = [
            '', 'Sample Product', 'sample-product', 'physical', '', 'Product description', '100', '3.33', '', '', '50', 'published', '', '', 'steel', '', '', '4.5', '0', 'SKU-001',
        ];

        $out = fopen('php://temp', 'r+');
        fputcsv($out, $headers);
        fputcsv($out, $example);
        rewind($out);
        $csv = stream_get_contents($out);
        fclose($out);

        return response($csv, 200, [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Content-Disposition' => 'attachment; filename="products-template.csv"',
        ]);
    }

    public function import(Request $request)
    {
        $request->validate([
            'file' => 'required|file|max:10240',
        ]);

        $file = $request->file('file');
        $path = $file->getRealPath();
        $handle = fopen($path, 'r');
        if (! $handle) {
            return response()->json(['message' => 'Unable to read file.'], 422);
        }

        $headers = fgetcsv($handle);
        if (! $headers) {
            fclose($handle);
            return response()->json(['message' => 'Empty file.'], 422);
        }
        $headers = array_map(fn ($h) => trim(strtolower((string) $h)), $headers);

        $created = 0;
        $updated = 0;
        $errors = [];

        $rowNumber = 1;
        while (($row = fgetcsv($handle)) !== false) {
            $rowNumber++;
            if (count(array_filter($row, fn ($v) => trim((string) $v) !== '')) === 0) {
                continue;
            }
            $data = [];
            foreach ($headers as $i => $h) {
                $data[$h] = isset($row[$i]) ? trim((string) $row[$i]) : null;
            }

            if (empty($data['name'] ?? '')) {
                $errors[] = "Row {$rowNumber}: name is required.";
                continue;
            }

            $slug = $data['slug'] ?? '';
            if ($slug === '') {
                $slug = $this->slugifyText($data['name']);
            }

            $product = null;
            if (! empty($data['id'])) {
                $product = Product::find($data['id']);
            }
            if (! $product && $slug !== '') {
                $product = Product::where('slug', $slug)->first();
            }

            $mainCategoryId = null;
            if (! empty($data['main_category'] ?? null)) {
                $cat = MainCategory::where('slug', $data['main_category'] ?? '')
                    ->orWhere('name', $data['main_category'] ?? '')
                    ->first();
                $mainCategoryId = $cat?->id;
            }

            $payload = [
                'name' => $data['name'],
                'slug' => $slug,
                'product_type' => in_array($data['product_type'] ?? '', ['physical','digital']) ? ($data['product_type'] ?? 'physical') : 'physical',
                'description' => $data['description'] ?? null,
                'main_category_id' => $mainCategoryId,
                'price_egp' => ($data['price_egp'] ?? '') !== '' ? ($data['price_egp'] ?? null) : null,
                'price_usd' => ($data['price_usd'] ?? '') !== '' ? ($data['price_usd'] ?? null) : null,
                'fake_price_egp' => ($data['fake_price_egp'] ?? '') !== '' ? ($data['fake_price_egp'] ?? null) : null,
                'fake_price_usd' => ($data['fake_price_usd'] ?? '') !== '' ? ($data['fake_price_usd'] ?? null) : null,
                'cost' => ($data['cost'] ?? '') !== '' ? ($data['cost'] ?? null) : 0,
                'status' => ($data['status'] ?? '') !== '' ? ($data['status'] ?? 'published') : 'published',
                'publish_date' => ($data['publish_date'] ?? '') !== '' ? ($data['publish_date'] ?? null) : null,
                'country_availability' => $data['country_availability'] ?? null,
                'material' => $data['material'] ?? null,
                'manufacturing_method' => $data['manufacturing_method'] ?? null,
                'type_sample' => $data['type_sample'] ?? null,
                'star_rating' => ($data['star_rating'] ?? '') !== '' ? ($data['star_rating'] ?? 0) : 0,
                'sold_count' => ($data['sold_count'] ?? '') !== '' ? ($data['sold_count'] ?? 0) : 0,
            ];

            $sku = $data['sku'] ?? '';

            if ($product) {
                $product->update($payload);
                $updated++;
            } else {
                $product = Product::create($payload);
                $created++;
            }

            if ($product->product_type === 'physical' && $sku !== '') {
                $product->inventory()->updateOrCreate(
                    ['product_id' => $product->id],
                    ['sku' => $sku]
                );
            }
        }

        fclose($handle);

        return response()->json([
            'created' => $created,
            'updated' => $updated,
            'errors' => $errors,
        ]);
    }

    public function bulkUpdate(Request $request)
    {
        $data = $request->validate([
            'ids' => 'required|array',
            'ids.*' => 'integer|exists:products,id',
            'fields' => 'required|array',
        ]);

        $count = 0;
        foreach ($data['ids'] as $id) {
            $product = Product::findOrFail($id);
            $fields = $data['fields'];

            if (isset($fields['main_category']) && $fields['main_category'] !== '') {
                $cat = MainCategory::where('slug', $fields['main_category'])
                    ->orWhere('name', $fields['main_category'])->first();
                if ($cat) $fields['main_category_id'] = $cat->id;
                unset($fields['main_category']);
            }

            $sku = $fields['sku'] ?? null;
            unset($fields['sku']);

            $product->update($fields);

            if ($sku !== null && $product->product_type === 'physical') {
                $product->inventory()->updateOrCreate(
                    ['product_id' => $product->id],
                    ['sku' => $sku]
                );
            }
            $count++;
        }

        return response()->json(['updated' => $count]);
    }

    public function export()
    {
        $products = Product::with(['inventory', 'mainCategory'])->get();
        $headers = ['id','name','slug','product_type','main_category','description','price_egp','price_usd','fake_price_egp','fake_price_usd','cost','status','publish_date','country_availability','material','manufacturing_method','type_sample','star_rating','sold_count','sku'];

        $out = fopen('php://temp', 'r+');
        fputcsv($out, $headers);
        foreach ($products as $p) {
            fputcsv($out, [
                $p->id,
                $p->name,
                $p->slug,
                $p->product_type,
                $p->mainCategory?->slug ?? $p->mainCategory?->name ?? '',
                str_replace(["\n","\r"], ' ', (string) $p->description),
                $p->price_egp,
                $p->price_usd,
                $p->fake_price_egp,
                $p->fake_price_usd,
                $p->cost,
                $p->status,
                $p->publish_date,
                $p->country_availability,
                $p->material,
                $p->manufacturing_method,
                $p->type_sample,
                $p->star_rating,
                $p->sold_count,
                $p->inventory?->sku ?? '',
            ]);
        }
        rewind($out);
        $csv = stream_get_contents($out);
        fclose($out);

        return response($csv, 200, [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Content-Disposition' => 'attachment; filename="products-export.csv"',
        ]);
    }

    private function slugifyText(string $value): string
    {
        $value = strtolower(trim($value));
        $value = preg_replace('/[^a-z0-9]+/', '-', $value);
        return trim($value, '-');
    }

    private function syncImagesToStox(Product $product): void
    {
        if ($product->product_type !== 'physical' || ! $product->stox_product_id) {
            return;
        }

        SyncStoxProductJob::dispatch($product->id);
    }
}
