<?php

namespace App\Http\Controllers;

use App\Models\MainCategory;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class SeoController extends Controller
{
    private const BOT_PATTERN = '/facebookexternalhit|Twitterbot|LinkedInBot|TelegramBot|Discordbot|Slackbot|Pinterest|AppleBot|Google-Image-Proxy|Bytespider|ClaudeBot|GPTBot|ChatGPT-User|curl|wget|python-requests/i';

    private const DEFAULT_OG_IMAGE = '/og-image.png';

    public function productShow(Request $request, string $slug)
    {
        $userAgent = $request->userAgent();

        if (! $this->isBot($userAgent)) {
            return response('', 418);
        }

        $product = Product::with(['images'])
            ->where('slug', $slug)
            ->where('status', 'published')
            ->first();

        if (! $product) {
            abort(404);
        }

        $appName = config('app.name', 'FLFL Design');
        $baseUrl = rtrim(config('app.url', 'https://flfl-design.com'), '/');
        $productUrl = "{$baseUrl}/products/{$slug}";

        $ogTitle = $product->name . ' - ' . $appName;
        $ogDescription = $this->getCleanDescription($product->description, $product->name);
        $ogImage = $this->getProductOgImageUrl($product, $baseUrl);

        return view('app', [
            'ogTitle' => $ogTitle,
            'ogDescription' => $ogDescription,
            'ogImage' => $ogImage,
            'ogUrl' => $productUrl,
            'siteName' => $appName,
        ]);
    }

    public function mainCategoryShow(Request $request, string $slug)
    {
        $userAgent = $request->userAgent();

        if (! $this->isBot($userAgent)) {
            return response('', 418);
        }

        $category = MainCategory::where('slug', $slug)->first();

        if (! $category) {
            abort(404);
        }

        $appName = config('app.name', 'FLFL Design');
        $baseUrl = rtrim(config('app.url', 'https://flfl-design.com'), '/');
        $categoryUrl = "{$baseUrl}/main-categories/{$slug}";

        $ogTitle = $category->name . ' - ' . $appName;
        $ogDescription = $this->getCleanDescription($category->description, $category->name);
        $ogImage = $this->getCategoryOgImageUrl($category, $baseUrl);

        return view('app', [
            'ogTitle' => $ogTitle,
            'ogDescription' => $ogDescription,
            'ogImage' => $ogImage,
            'ogUrl' => $categoryUrl,
            'siteName' => $appName,
        ]);
    }

    private function isBot(?string $userAgent): bool
    {
        if (! $userAgent) {
            return false;
        }

        return (bool) preg_match(self::BOT_PATTERN, $userAgent);
    }

    private function getCleanDescription(?string $description, string $fallback): string
    {
        if (! $description) {
            return "Check out {$fallback} on FLFL Design.";
        }

        $clean = preg_replace('/^-\s*/m', '', $description);
        $clean = preg_replace('/\n+/', ' ', $clean);
        $clean = trim($clean);

        if (mb_strlen($clean) > 200) {
            $clean = mb_substr($clean, 0, 197) . '...';
        }

        return $clean ?: "Check out {$fallback} on FLFL Design.";
    }

    private function getProductOgImageUrl(Product $product, string $baseUrl): string
    {
        $image = $product->images->first();

        if (! $image || ! $image->image_url) {
            return $baseUrl . self::DEFAULT_OG_IMAGE;
        }

        if (str_starts_with($image->image_url, 'http')) {
            return $image->image_url;
        }

        return Storage::disk('public')->url($image->image_url);
    }

    private function getCategoryOgImageUrl(MainCategory $category, string $baseUrl): string
    {
        if (! $category->image_url) {
            return $baseUrl . self::DEFAULT_OG_IMAGE;
        }

        if (str_starts_with($category->image_url, 'http')) {
            return $category->image_url;
        }

        return Storage::disk('public')->url($category->image_url);
    }
}
