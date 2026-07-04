<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CustomerAnalytics extends Model
{
    protected $fillable = [
        'user_id', 'total_orders', 'total_spent', 'total_refunded',
        'net_revenue', 'average_order_value', 'clv', 'last_order_date',
    ];

    protected function casts(): array
    {
        return [
            'total_spent' => 'decimal:2',
            'total_refunded' => 'decimal:2',
            'net_revenue' => 'decimal:2',
            'average_order_value' => 'decimal:2',
            'clv' => 'decimal:2',
            'last_order_date' => 'datetime',
        ];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
