<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ManufacturingMethod extends Model
{
    protected $fillable = ['slug', 'name', 'is_active', 'sort_order'];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function materials()
    {
        return $this->belongsToMany(Material::class, 'material_manufacturing_method');
    }
}
