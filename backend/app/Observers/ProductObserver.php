<?php

namespace App\Observers;

use App\Jobs\SyncFacebookCatalogJob;
use App\Jobs\BroadcastNewProductNotification;
use App\Models\Product;

class ProductObserver
{
    public function created(Product $product): void
    {
        $this->queueNewProductNotification($product);
    }

    public function updated(Product $product): void
    {
        if ($product->wasChanged('status') && $product->status === 'published') {
            $this->queueNewProductNotification($product);
        }
    }

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

    private function queueNewProductNotification(Product $product): void
    {
        if ($product->status !== 'published' || $product->new_product_notification_queued_at) {
            return;
        }

        $product->updateQuietly(['new_product_notification_queued_at' => now()]);
        BroadcastNewProductNotification::dispatch($product->id)
            ->afterCommit()
            ->delay(now()->addSeconds(5));
    }
}
