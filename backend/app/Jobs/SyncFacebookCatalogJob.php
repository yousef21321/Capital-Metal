<?php

namespace App\Jobs;

use App\Models\Product;
use App\Services\FacebookCatalogService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Foundation\Queue\Queueable;

class SyncFacebookCatalogJob implements ShouldQueue
{
    use Dispatchable, Queueable;

    public function __construct(
        public int $productId,
        public string $action,
        public array $variantIds = [],
    ) {}

    public function handle(): void
    {
        $facebook = app(FacebookCatalogService::class);

        if (! $facebook->isConfigured()) {
            return;
        }

        if ($this->action === 'delete') {
            $facebook->delete($this->productId, $this->variantIds);

            return;
        }

        $product = Product::with(['images', 'inventory', 'variants.images'])->find($this->productId);

        if ($product) {
            $facebook->upsert($product);
        }
    }
}
