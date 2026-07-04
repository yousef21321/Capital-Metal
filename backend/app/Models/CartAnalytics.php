<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CartAnalytics extends Model
{
    public $timestamps = false;

    protected $fillable = ['cart_id', 'user_id', 'total_value', 'is_converted', 'abandoned_at'];

    protected function casts(): array
    {
        return [
            'total_value' => 'decimal:2',
            'is_converted' => 'boolean',
            'abandoned_at' => 'datetime',
        ];
    }

    public function cart()
    {
        return $this->belongsTo(Cart::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
