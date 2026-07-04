<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ProductAnalytics extends Model
{
    protected $fillable = [
        'product_id', 'total_sales', 'total_revenue', 'total_refunds',
        'total_profit', 'conversion_rate',
    ];

    protected function casts(): array
    {
        return [
            'total_revenue' => 'decimal:2',
            'total_refunds' => 'decimal:2',
            'total_profit' => 'decimal:2',
            'conversion_rate' => 'decimal:2',
        ];
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
