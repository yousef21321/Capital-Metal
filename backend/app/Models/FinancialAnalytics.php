<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FinancialAnalytics extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'order_id', 'product_cost', 'shipping_cost', 'payment_gateway_fee',
        'gross_revenue', 'net_profit', 'profit_margin',
    ];

    protected function casts(): array
    {
        return [
            'product_cost' => 'decimal:2',
            'shipping_cost' => 'decimal:2',
            'payment_gateway_fee' => 'decimal:2',
            'gross_revenue' => 'decimal:2',
            'net_profit' => 'decimal:2',
            'profit_margin' => 'decimal:2',
        ];
    }

    public function order()
    {
        return $this->belongsTo(Order::class);
    }
}
