<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DigitalFile extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'product_id', 'file_url', 'version', 'max_downloads',
        'link_expiry_days', 'license_type',
    ];

    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
