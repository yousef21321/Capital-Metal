<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class ProductVariantImage extends Model
{
    public $timestamps = false;

    protected $fillable = ['variant_id', 'image_url', 'sort_order'];

    protected $appends = ['image_url_thumb'];

    protected function casts(): array
    {
        return [
            'sort_order' => 'integer',
        ];
    }

    public function getImageUrlThumbAttribute(): ?string
    {
        if (! $this->image_url) {
            return null;
        }

        $thumb = app(\App\Services\ImageOptimizer::class)->thumbnailPath($this->image_url);

        return Storage::disk('public')->exists($thumb) ? $thumb : null;
    }

    public function variant()
    {
        return $this->belongsTo(ProductVariant::class, 'variant_id');
    }
}
