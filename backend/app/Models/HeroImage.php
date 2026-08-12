<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class HeroImage extends Model
{
    protected $fillable = ['image_url', 'sort_order', 'media_type', 'video_url', 'alt_text'];

    protected $appends = ['image_url_thumb'];

    public function getImageUrlThumbAttribute(): ?string
    {
        if (! $this->image_url) {
            return null;
        }

        $thumb = app(\App\Services\ImageOptimizer::class)->thumbnailPath($this->image_url);

        return Storage::disk('public')->exists($thumb) ? $thumb : null;
    }
}
