<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class ProductImage extends Model
{
    public $timestamps = false;

    protected $fillable = ['product_id', 'image_url', 'sort_order'];

    protected $appends = ['image_url_thumb'];

    public function getImageUrlThumbAttribute(): ?string
    {
        if (! $this->image_url) {
            return null;
        }

        $thumb = app(\App\Services\ImageOptimizer::class)->thumbnailPath($this->image_url);

        return Storage::disk('public')->exists($thumb) ? $thumb : null;
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
