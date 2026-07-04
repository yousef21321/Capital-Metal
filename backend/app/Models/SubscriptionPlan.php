<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SubscriptionPlan extends Model
{
    protected $fillable = ['name', 'price', 'currency', 'duration_days', 'ticket_limit', 'can_publish_to_store'];

    protected $casts = [
        'price' => 'decimal:2',
        'can_publish_to_store' => 'boolean',
    ];

    public function subscriptions()
    {
        return $this->hasMany(UserSubscription::class, 'plan_id');
    }
}
