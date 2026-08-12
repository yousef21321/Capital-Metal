<?php

namespace App\Services;

use App\Models\Product;
use App\Models\ProductVariant;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Http;

class FacebookCatalogService
{
    public function isConfigured(): bool
    {
        return config('services.facebook.catalog_id')
            && config('services.facebook.access_token');
    }

    public function upsert(Product $product): void
    {
        if (! $this->isConfigured() || $product->status !== 'published') {
            return;
        }

        $activeVariants = $product->variants->where('is_active', true);

        if ($activeVariants->isNotEmpty()) {
            foreach ($activeVariants as $variant) {
                $this->request('UPDATE', $this->buildVariantData($product, $variant));
            }

            return;
        }

        $this->request('UPDATE', $this->buildProductData($product));
    }

    public function delete(int $productId, array $variantIds = []): void
    {
        if (! $this->isConfigured()) {
            return;
        }

        $requests = [['method' => 'DELETE', 'data' => ['id' => (string) $productId]]];

        foreach ($variantIds as $variantId) {
            $requests[] = ['method' => 'DELETE', 'data' => ['id' => "product-{$productId}-{$variantId}"]];
        }

        $this->send($requests);
    }

    private function buildProductData(Product $product): array
    {
        [$price, $currency] = $this->priceFor($product->price_egp, $product->price_usd);

        return [
            'data' => $this->itemData(
                id: (string) $product->id,
                itemGroupId: null,
                name: $product->name,
                description: $product->description,
                link: url('/products/'.$product->slug),
                imageUrls: $this->imageUrls($product->images),
                price: $price,
                currency: $currency,
                sku: $product->inventory?->sku,
                stock: $product->inventory?->stock_quantity,
                productType: $product->product_type,
            ),
        ];
    }

    private function buildVariantData(Product $product, ProductVariant $variant): array
    {
        [$price, $currency] = $this->priceFor($variant->price_egp, $variant->price_usd);

        return [
            'data' => $this->itemData(
                id: "product-{$product->id}-{$variant->id}",
                itemGroupId: (string) $product->id,
                name: $variant->name ?: $product->name,
                description: $variant->description ?: $product->description,
                link: url('/products/'.$product->slug),
                imageUrls: $this->imageUrls($variant->images, $product->images),
                price: $price,
                currency: $currency,
                sku: $variant->sku,
                stock: $variant->stock_quantity,
                productType: $product->product_type,
            ),
        ];
    }

    private function itemData(
        string $id,
        ?string $itemGroupId,
        string $name,
        ?string $description,
        string $link,
        array $imageUrls,
        $price,
        string $currency,
        ?string $sku,
        $stock,
        string $productType,
    ): array {
        $amount = is_numeric($price) ? number_format((float) $price, 2, '.', '') : '0.00';

        $data = [
            'id' => $id,
            'title' => $name,
            'description' => $this->cleanDescription($description, $name),
            'link' => $link,
            'price' => "{$amount} {$currency}",
            'condition' => 'new',
            'availability' => $this->availability($productType, $stock),
            'brand' => config('app.name', 'FLFL Design'),
            'product_type' => $productType,
        ];

        if ($itemGroupId !== null) {
            $data['item_group_id'] = $itemGroupId;
        }
        if (! empty($imageUrls)) {
            $data['image_link'] = $imageUrls[0];
        }
        if (count($imageUrls) > 1) {
            $data['additional_image_link'] = $imageUrls;
        }
        if (! empty($sku)) {
            $data['mpn'] = $sku;
        }

        return $data;
    }

    private function request(string $method, array $item): void
    {
        $this->send([['method' => $method, 'data' => $item['data']]]);
    }

    private function send(array $requests): void
    {
        $catalogId = config('services.facebook.catalog_id');
        $token = config('services.facebook.access_token');
        $version = config('services.facebook.graph_version', 'v21.0');

        try {
            $response = Http::asForm()->post("https://graph.facebook.com/{$version}/{$catalogId}/items_batch", [
                'access_token' => $token,
                'allow_upsert' => 'true',
                'item_type' => 'PRODUCT_ITEM',
                'requests' => json_encode($requests),
            ]);

            $body = $response->json();

            if (! $response->ok() || (is_array($body) && ! empty($body['error']))) {
                logger()->warning('Facebook Catalog items_batch failed', [
                    'status' => $response->status(),
                    'body' => $body,
                ]);
            }
        } catch (\Throwable $e) {
            report($e);
        }
    }

    private function imageUrls(Collection $primaryImages, ?Collection $fallbackImages = null): array
    {
        $sources = $primaryImages ?? collect();

        if ($sources->isEmpty() && $fallbackImages) {
            $sources = $fallbackImages;
        }

        return $sources
            ->filter(fn ($image) => ! empty($image->image_url))
            ->map(fn ($image) => $this->absoluteImageUrl($image->image_url))
            ->values()
            ->all();
    }

    private function priceFor($priceEgp, $priceUsd): array
    {
        if (config('services.facebook.feed_currency', 'EGP') === 'USD') {
            return [$priceUsd, 'USD'];
        }

        return [$priceEgp, 'EGP'];
    }

    private function availability(string $productType, $stock): string
    {
        return 'in stock';
    }

    private function absoluteImageUrl(string $path): string
    {
        if (str_starts_with($path, 'http')) {
            return $path;
        }

        $baseUrl = rtrim(config('app.url', 'https://flfl-design.com'), '/');

        return $baseUrl.'/storage/'.ltrim($path, '/');
    }

    private function cleanDescription(?string $description, string $fallback): string
    {
        if (! $description) {
            return "Check out {$fallback} on FLFL Design.";
        }

        $clean = preg_replace('/^-\s*/m', '', $description);
        $clean = preg_replace('/\n+/', ' ', $clean);

        return trim($clean) ?: "Check out {$fallback} on FLFL Design.";
    }
}
