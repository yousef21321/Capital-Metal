<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DailyReport extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'report_date', 'total_orders', 'total_revenue', 'total_profit',
        'total_shipping', 'new_customers', 'conversion_rate',
    ];

    protected function casts(): array
    {
        return [
            'report_date' => 'datetime',
            'total_revenue' => 'decimal:2',
            'total_profit' => 'decimal:2',
            'total_shipping' => 'decimal:2',
            'conversion_rate' => 'decimal:2',
        ];
    }
}
