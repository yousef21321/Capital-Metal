<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Storage;

class SeoController extends Controller
{
    private const BOT_PATTERN = '/facebookexternalhit|WhatsApp|Twitterbot|LinkedInBot|TelegramBot|Discordbot|Slackbot|Pinterest|AppleBot|Google-Image-Proxy|Bytespider|ClaudeBot|GPTBot|ChatGPT-User|curl|wget|python-requests/i';

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
        $ogImage = $this->getOgImageUrl($product, $baseUrl);

        $html = $this->renderSeoPage(
            title: $ogTitle,
            description: $ogDescription,
            image: $ogImage,
            url: $productUrl,
            siteName: $appName,
        );

        return response($html, 200)->header('Content-Type', 'text/html');
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

    private function getOgImageUrl(Product $product, string $baseUrl): string
    {
        $image = $product->images->first();

        if (! $image || ! $image->image_url) {
            return $baseUrl . '/og-image.png';
        }

        $diskUrl = Storage::disk('public')->url($image->image_url);

        if (str_starts_with($diskUrl, 'http')) {
            return $diskUrl;
        }

        return $baseUrl . '/storage/' . ltrim($image->image_url, '/');
    }

    private function renderSeoPage(
        string $title,
        string $description,
        string $image,
        string $url,
        string $siteName,
    ): string {
        $t = htmlspecialchars($title, ENT_QUOTES, 'UTF-8');
        $d = htmlspecialchars($description, ENT_QUOTES, 'UTF-8');
        $i = htmlspecialchars($image, ENT_QUOTES, 'UTF-8');
        $u = htmlspecialchars($url, ENT_QUOTES, 'UTF-8');
        $s = htmlspecialchars($siteName, ENT_QUOTES, 'UTF-8');

        return <<<HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>{$t}</title>
    <meta name="description" content="{$d}">
    <meta property="og:type" content="product">
    <meta property="og:url" content="{$u}">
    <meta property="og:title" content="{$t}">
    <meta property="og:description" content="{$d}">
    <meta property="og:image" content="{$i}">
    <meta property="og:image:width" content="1200">
    <meta property="og:image:height" content="630">
    <meta property="og:site_name" content="{$s}">
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="{$t}">
    <meta name="twitter:description" content="{$d}">
    <meta name="twitter:image" content="{$i}">
    <link rel="canonical" href="{$u}">
</head>
<body>
    <p>Redirecting to <a href="{$u}">{$t}</a>...</p>
    <script>window.location.href = '{$u}';</script>
</body>
</html>
HTML;
    }
}
