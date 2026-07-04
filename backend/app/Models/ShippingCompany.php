<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ShippingCompany extends Model
{
    protected $fillable = ['name', 'api_endpoint', 'api_key', 'is_active'];

    protected function casts(): array
    {
        return ['is_active' => 'boolean'];
    }

    public function rates()
    {
        return $this->hasMany(ShippingRate::class, 'company_id');
    }
}
