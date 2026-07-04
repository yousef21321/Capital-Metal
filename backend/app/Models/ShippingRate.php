<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ShippingRate extends Model
{
    public $timestamps = false;

    protected $fillable = ['company_id', 'governorate', 'cost'];

    public function company()
    {
        return $this->belongsTo(ShippingCompany::class, 'company_id');
    }
}
