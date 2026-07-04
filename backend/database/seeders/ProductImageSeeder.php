<?php

namespace Database\Seeders;

use App\Models\Product;
use App\Models\ProductImage;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Storage;

class ProductImageSeeder extends Seeder
{
    private const COLORS = [
        [52, 152, 219],   // blue
        [46, 204, 113],  // green
        [231, 76, 60],   // red
        [155, 89, 182],  // purple
        [241, 196, 15],  // yellow
        [230, 126, 34],  // orange
    ];

    public function run(): void
    {
        if (!extension_loaded('gd')) {
            return;
        }

        $disk = Storage::disk('public');
        $products = Product::all();

        foreach ($products as $index => $product) {
            $colorIndex = $index % count(self::COLORS);
            $imageCount = ($index % 2) + 1;

            for ($img = 0; $img < $imageCount; $img++) {
                $color = self::COLORS[($colorIndex + $img) % count(self::COLORS)];
                $filename = "products/{$product->id}/image-{$img}.png";
                $relativeDir = "products/{$product->id}";

                if (!$disk->exists($relativeDir)) {
                    $disk->makeDirectory($relativeDir);
                }

                if ($disk->exists($filename)) {
                    continue;
                }

                $pngData = $this->generatePlaceholderImage($product->name, $color);

                $disk->put($filename, $pngData);

                ProductImage::firstOrCreate([
                    'product_id' => $product->id,
                    'image_url' => $filename,
                ], [
                    'sort_order' => $img,
                ]);
            }
        }
    }

    private function generatePlaceholderImage(string $label, array $bgColor): string
    {
        $width = 600;
        $height = 600;

        $image = imagecreatetruecolor($width, $height);

        $bg = imagecolorallocate($image, $bgColor[0], $bgColor[1], $bgColor[2]);
        imagefill($image, 0, 0, $bg);

        // Lighter overlay rectangle for depth
        $overlay = imagecolorallocatealpha($image, 255, 255, 255, 40);
        imagefilledrectangle($image, 40, 40, $width - 40, $height - 40, $overlay);

        // Icon circle
        $circleColor = imagecolorallocate($image, 255, 255, 255);
        imagefilledellipse($image, (int)($width / 2), (int)($height / 2) - 50, 120, 120, $circleColor);

        // Label text
        $textColor = imagecolorallocate($image, 255, 255, 255);
        $fontSize = 5;
        $text = strlen($label) > 20 ? substr($label, 0, 18) . '...' : $label;
        $textWidth = imagefontwidth($fontSize) * strlen($text);
        $textX = (int)(($width - $textWidth) / 2);
        imagestring($image, $fontSize, $textX, (int)($height / 2) + 40, $text, $textColor);

        // Type tag
        $tagColor = imagecolorallocate($image, 30, 30, 30);
        $tagText = strtoupper(substr($label, 0, 3));
        $tagWidth = imagefontwidth($fontSize) * strlen($tagText) + 10;
        imagefilledrectangle($image, (int)(($width - $tagWidth) / 2), (int)($height / 2) + 70, (int)(($width + $tagWidth) / 2), (int)($height / 2) + 90, $tagColor);
        $tagTextX = (int)(($width - imagefontwidth($fontSize) * strlen($tagText)) / 2);
        imagestring($image, $fontSize, $tagTextX, (int)($height / 2) + 73, $tagText, $textColor);

        ob_start();
        imagepng($image);
        $data = ob_get_clean();
        imagedestroy($image);

        return $data;
    }
}
