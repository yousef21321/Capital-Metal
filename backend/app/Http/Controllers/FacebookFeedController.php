<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Response;

class FacebookFeedController extends Controller
{
    public function products(): Response
    {
        $baseUrl = rtrim(config('app.url', 'https://capital-metal.com'), '/');

        $products = Product::with(['images', 'inventory', 'variants.images'])
            ->where('status', 'published')
            ->orderBy('id')
            ->get();

        $items = '';

        foreach ($products as $product) {
            $activeVariants = $product->variants->where('is_active', true);

            if ($activeVariants->isNotEmpty()) {
                foreach ($activeVariants as $variant) {
                    [$price, $currency] = $this->priceFor($variant->price_egp, $variant->price_usd);
                    $items .= $this->item(
                        id: "product-{$product->id}-{$variant->id}",
                        itemGroupId: (string) $product->id,
                        name: $variant->name ?: $product->name,
                        description: $variant->description ?: $product->description,
                        link: "{$baseUrl}/products/{$product->slug}",
                        imageUrls: $this->imageUrls($variant->images, $product->images),
                        price: $price,
                        currency: $currency,
                        sku: $variant->sku,
                        stock: $variant->stock_quantity,
                        productType: $product->product_type,
                    );
                }
            } else {
                [$price, $currency] = $this->priceFor($product->price_egp, $product->price_usd);
                $items .= $this->item(
                    id: (string) $product->id,
                    itemGroupId: null,
                    name: $product->name,
                    description: $product->description,
                    link: "{$baseUrl}/products/{$product->slug}",
                    imageUrls: $this->imageUrls($product->images),
                    price: $price,
                    currency: $currency,
                    sku: $product->inventory?->sku,
                    stock: $product->inventory?->stock_quantity,
                    productType: $product->product_type,
                );
            }
        }

        $xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
        $xml .= '<rss xmlns:g="http://base.google.com/ns/1.0" version="2.0">'."\n";
        $xml .= "  <channel>\n";
        $xml .= '    <title>'.htmlspecialchars(config('app.name', 'Capital-Metal'), ENT_XML1, 'UTF-8')."</title>\n";
        $xml .= "    <link>{$baseUrl}</link>\n";
        $xml .= "    <description>Capital-Metal product catalog</description>\n";
        $xml .= $items;
        $xml .= "  </channel>\n";
        $xml .= "</rss>\n";

        return response($xml, 200, [
            'Content-Type' => 'application/xml; charset=UTF-8',
            'X-Robots-Tag' => 'noindex, nofollow',
        ]);
    }

    private function item(
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
    ): string {
        $x = '<item>'."\n";
        $x .= '  <g:id>'.htmlspecialchars($id, ENT_XML1, 'UTF-8')."</g:id>\n";

        if ($itemGroupId !== null) {
            $x .= '  <g:item_group_id>'.htmlspecialchars($itemGroupId, ENT_XML1, 'UTF-8')."</g:item_group_id>\n";
        }

        $x .= '  <g:title>'.htmlspecialchars($name, ENT_XML1, 'UTF-8')."</g:title>\n";
        $x .= '  <g:description>'.htmlspecialchars($this->cleanDescription($description, $name), ENT_XML1, 'UTF-8')."</g:description>\n";
        $x .= '  <g:link>'.htmlspecialchars($link, ENT_XML1, 'UTF-8')."</g:link>\n";

        if (! empty($imageUrls)) {
            $x .= '  <g:image_link>'.htmlspecialchars($imageUrls[0], ENT_XML1, 'UTF-8')."</g:image_link>\n";
            if (count($imageUrls) > 1) {
                $x .= '  <g:additional_image_link>'.htmlspecialchars(implode(',', $imageUrls), ENT_XML1, 'UTF-8')."</g:additional_image_link>\n";
            }
        }

        $amount = is_numeric($price) ? number_format((float) $price, 2, '.', '') : '0.00';
        $x .= "  <g:price>{$amount} {$currency}</g:price>\n";
        $x .= "  <g:condition>new</g:condition>\n";
        $x .= '  <g:availability>'.$this->availability($productType, $stock)."</g:availability>\n";
        $x .= '  <g:brand>'.htmlspecialchars(config('app.name', 'Capital-Metal'), ENT_XML1, 'UTF-8')."</g:brand>\n";
        $x .= "  <g:product_type>{$productType}</g:product_type>\n";

        if (! empty($sku)) {
            $x .= '  <g:mpn>'.htmlspecialchars($sku, ENT_XML1, 'UTF-8')."</g:mpn>\n";
        }

        $x .= "</item>\n";

        return $x;
    }

    private function imageUrls($primaryImages, $fallbackImages = null): array
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

        $baseUrl = rtrim(config('app.url', 'https://capital-metal.com'), '/');

        return $baseUrl.'/storage/'.ltrim($path, '/');
    }

    private function cleanDescription(?string $description, string $fallback): string
    {
        if (! $description) {
            return "Check out {$fallback} on Capital-Metal.";
        }

        $clean = preg_replace('/^-\s*/m', '', $description);
        $clean = preg_replace('/\n+/', ' ', $clean);

        return trim($clean) ?: "Check out {$fallback} on Capital-Metal.";
    }
}
