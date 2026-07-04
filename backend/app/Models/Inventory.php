<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Inventory extends Model
{
    protected $table = 'inventory';
    public $timestamps = false;

    protected $fillable = ['product_id', 'sku', 'stock_quantity', 'low_stock_alert', 'warehouse_location'];

    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
