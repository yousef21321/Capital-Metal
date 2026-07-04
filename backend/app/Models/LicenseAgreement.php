<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LicenseAgreement extends Model
{
    public $timestamps = false;

    protected $fillable = ['product_id', 'license_type', 'agreement_file_url'];

    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
