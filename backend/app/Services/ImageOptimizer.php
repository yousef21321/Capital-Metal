<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Intervention\Image\Drivers\Gd\Driver;
use Intervention\Image\ImageManager;

class ImageOptimizer
{
    private int $maxWidth;

    private int $maxHeight;

    private int $quality;

    private ImageManager $manager;

    public function __construct(int $maxWidth = 1200, int $maxHeight = 1200, int $quality = 80)
    {
        $this->maxWidth = $maxWidth;
        $this->maxHeight = $maxHeight;
        $this->quality = $quality;
        $this->manager = new ImageManager(new Driver);
    }

    public function optimizeUploadedFile(UploadedFile $file, string $directory, string $disk = 'public'): string
    {
        $mime = mime_content_type($file->getRealPath());

        if (! in_array($mime, ['image/jpeg', 'image/png', 'image/gif', 'image/webp'])) {
            return $file->store($directory, $disk);
        }

        $img = $this->manager->read($file->getRealPath());

        if ($img->width() > $this->maxWidth || $img->height() > $this->maxHeight) {
            $img->scaleDown(width: $this->maxWidth, height: $this->maxHeight);
        }

        $filename = pathinfo($file->hashName(), PATHINFO_FILENAME).'.webp';
        $path = $directory.'/'.$filename;

        $encoded = $img->toWebp($this->quality)->toString();
        Storage::disk($disk)->put($path, $encoded);

        return $path;
    }

    public function optimizeExistingFile(string $relativePath, string $disk = 'public'): ?string
    {
        $fullPath = Storage::disk($disk)->path($relativePath);

        if (! file_exists($fullPath)) {
            return null;
        }

        $mime = mime_content_type($fullPath);

        if (! in_array($mime, ['image/jpeg', 'image/png', 'image/gif'])) {
            return null;
        }

        $img = $this->manager->read($fullPath);

        if ($img->width() > $this->maxWidth || $img->height() > $this->maxHeight) {
            $img->scaleDown(width: $this->maxWidth, height: $this->maxHeight);
        }

        $webpPath = preg_replace('/\.(jpe?g|png|gif)$/i', '.webp', $relativePath);

        $encoded = $img->toWebp($this->quality)->toString();
        Storage::disk($disk)->put($webpPath, $encoded);

        return $webpPath;
    }
}
