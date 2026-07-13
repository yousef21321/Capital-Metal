<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SubscriptionPlan extends Model
{
    protected $fillable = ['name', 'price', 'currency', 'duration_days', 'ticket_limit', 'can_publish_to_store', 'discount_percent'];

    protected $casts = [
        'price' => 'decimal:2',
        'can_publish_to_store' => 'boolean',
        'discount_percent' => 'decimal:2',
    ];

    public function subscriptions()
    {
        return $this->hasMany(UserSubscription::class, 'plan_id');
    }
}
