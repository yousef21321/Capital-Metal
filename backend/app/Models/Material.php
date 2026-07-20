<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Material extends Model
{
    protected $fillable = ['slug', 'name', 'is_active', 'sort_order'];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function manufacturingMethods()
    {
        return $this->belongsToMany(ManufacturingMethod::class, 'material_manufacturing_method');
    }
}
