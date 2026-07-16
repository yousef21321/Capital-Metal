<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class HeroImage extends Model
{
    protected $fillable = ['image_url', 'sort_order', 'media_type', 'video_url', 'alt_text'];
}
