<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Download extends Model
{
    public $timestamps = false;

    protected $fillable = ['order_item_id', 'download_count', 'last_download_at'];

    public function orderItem()
    {
        return $this->belongsTo(OrderItem::class);
    }
}
