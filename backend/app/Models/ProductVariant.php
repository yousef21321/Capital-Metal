<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ProductVariant extends Model
{
    protected $fillable = [
        'product_id', 'name', 'description', 'price_egp', 'price_usd',
        'cost', 'sku', 'material', 'manufacturing_method', 'stock_quantity', 'is_active', 'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'price_egp' => 'decimal:2',
            'price_usd' => 'decimal:2',
            'cost' => 'decimal:2',
            'is_active' => 'boolean',
            'stock_quantity' => 'integer',
        ];
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    public function images()
    {
        return $this->hasMany(ProductVariantImage::class, 'variant_id')->orderBy('sort_order');
    }
}
