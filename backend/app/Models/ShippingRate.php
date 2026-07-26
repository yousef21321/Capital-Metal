<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ShippingRate extends Model
{
    protected $fillable = ['region', 'governorate', 'cost'];

    protected $casts = [
        'cost' => 'decimal:2',
    ];
}
