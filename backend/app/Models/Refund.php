<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Refund extends Model
{
    public $timestamps = false;

    protected $fillable = ['order_id', 'amount', 'reason', 'status'];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }
}
