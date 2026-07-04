<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Coupon extends Model
{
    protected $fillable = [
        'code', 'discount_type', 'discount_value', 'min_order_amount',
        'expiry_date', 'usage_limit', 'used_count',
    ];

    protected function casts(): array
    {
        return [
            'expiry_date' => 'datetime',
            'discount_value' => 'decimal:2',
            'min_order_amount' => 'decimal:2',
        ];
    }
}
