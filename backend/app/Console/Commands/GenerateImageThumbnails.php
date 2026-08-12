<?php

namespace App\Console\Commands;

use App\Services\ImageOptimizer;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Storage;

class GenerateImageThumbnails extends Command
{
    protected $signature = 'images:generate-thumbnails';

    protected $description = 'Generate _thumb.webp variants for existing product, hero and ticket images';

    public function handle(ImageOptimizer $optimizer): int
    {
        $directories = ['products', 'hero', 'tickets'];
        $totalGenerated = 0;
        $totalSkipped = 0;

        foreach ($directories as $dir) {
            if (! Storage::disk('public')->exists($dir)) {
                continue;
            }

            $files = Storage::disk('public')->allFiles($dir);

            foreach ($files as $file) {
                $mime = Storage::disk('public')->mimeType($file);

                if (! in_array($mime, ['image/jpeg', 'image/png', 'image/gif', 'image/webp'])) {
                    continue;
                }

                if (str_contains($file, '_thumb.')) {
                    $totalSkipped++;

                    continue;
                }

                $thumbPath = $optimizer->thumbnailPath($file);

                if (Storage::disk('public')->exists($thumbPath)) {
                    $totalSkipped++;

                    continue;
                }

                if ($optimizer->generateThumbnail($file)) {
                    $this->line("Generated: {$thumbPath}");
                    $totalGenerated++;
                } else {
                    $this->warn("Failed: {$file}");
                }
            }
        }

        $this->info("Done! Generated: {$totalGenerated}, Skipped: {$totalSkipped}");

        return 0;
    }
}
