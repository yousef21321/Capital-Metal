<?php

namespace App\Observers;

use App\Jobs\SyncFacebookCatalogJob;
use App\Models\Product;

class ProductObserver
{
    public function saved(Product $product): void
    {
        if (! config('services.facebook.catalog_id')) {
            return;
        }

        SyncFacebookCatalogJob::dispatch($product->id, 'upsert');
    }

    public function deleting(Product $product): void
    {
        $product->fb_variant_ids = $product->variants()->pluck('id')->all();
    }

    public function deleted(Product $product): void
    {
        if (! config('services.facebook.catalog_id')) {
            return;
        }

        SyncFacebookCatalogJob::dispatch($product->id, 'delete', $product->fb_variant_ids ?? []);
    }
}
