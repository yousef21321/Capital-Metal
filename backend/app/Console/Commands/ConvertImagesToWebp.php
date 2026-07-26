<?php

namespace App\Console\Commands;

use App\Services\ImageOptimizer;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Storage;

class ConvertImagesToWebp extends Command
{
    protected $signature = 'images:convert-webp';

    protected $description = 'Convert all existing JPG/PNG images to WebP format';

    public function handle(ImageOptimizer $optimizer): int
    {
        $directories = ['products', 'hero', 'tickets'];
        $totalConverted = 0;
        $totalSkipped = 0;

        foreach ($directories as $dir) {
            if (! Storage::disk('public')->exists($dir)) {
                continue;
            }

            $files = Storage::disk('public')->allFiles($dir);

            foreach ($files as $file) {
                $mime = Storage::disk('public')->mimeType($file);

                if (! in_array($mime, ['image/jpeg', 'image/png', 'image/gif'])) {
                    $totalSkipped++;

                    continue;
                }

                $webpPath = preg_replace('/\.(jpe?g|png|gif)$/i', '.webp', $file);

                if (Storage::disk('public')->exists($webpPath)) {
                    $totalSkipped++;

                    continue;
                }

                $result = $optimizer->optimizeExistingFile($file);

                if ($result) {
                    $this->line("Converted: {$file} -> {$result}");
                    $totalConverted++;
                } else {
                    $this->warn("Failed: {$file}");
                }
            }
        }

        $this->info("Done! Converted: {$totalConverted}, Skipped: {$totalSkipped}");

        return 0;
    }
}
