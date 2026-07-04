<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Affiliate extends Model
{
    protected $fillable = ['user_id', 'referral_code', 'commission_percentage'];

    protected function casts(): array
    {
        return ['commission_percentage' => 'decimal:2'];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    public function earnings()
    {
        return $this->hasMany(AffiliateEarning::class);
    }
}
