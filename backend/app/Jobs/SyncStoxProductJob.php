<?php

namespace App\Jobs;

use App\Models\Product;
use App\Services\StoxService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Foundation\Queue\Queueable;

class SyncStoxProductJob implements ShouldQueue
{
    use Dispatchable, Queueable;

    public function __construct(
        public int $productId,
        public ?string $sku = null,
        public array $imagePaths = [],
    ) {}

    public function handle(): void
    {
        $product = Product::with('images', 'inventory')->find($this->productId);

        if (! $product || $product->product_type !== 'physical') {
            return;
        }

        $stox = app(StoxService::class);

        if (! $stox->isConfigured()) {
            return;
        }

        $sku = $this->sku ?: ($product->inventory?->sku ?: $product->slug);

        $paths = $this->imagePaths;
        if (empty($paths)) {
            $paths = $product->images()->orderBy('sort_order')->pluck('image_url')->toArray();
        }
        $imageUrls = array_map(fn ($p) => $stox->buildImageUrl($p), $paths);

        $result = $stox->createProduct(
            name: $product->name ?: $product->slug,
            sku: $sku,
            description: $product->description,
            images: $imageUrls,
        );

        if ($result && isset($result['id'])) {
            $product->update(['stox_product_id' => $result['id']]);
        } elseif (! $result) {
            $fallbackSku = strtoupper(str_replace(' ', '-', $product->slug)).'-'.$product->id;
            $result = $stox->createProduct(
                name: $product->name ?: $product->slug,
                sku: $fallbackSku,
                description: $product->description,
                images: $imageUrls,
            );
            if ($result && isset($result['id'])) {
                $product->update(['stox_product_id' => $result['id']]);
            }
        }
    }
}
