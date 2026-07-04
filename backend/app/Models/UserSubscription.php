<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserSubscription extends Model
{
    public $timestamps = false;

    protected $fillable = ['user_id', 'plan_id', 'start_date', 'end_date', 'status', 'tickets_remaining', 'tickets_used', 'approval_status', 'approved_by', 'approved_at', 'rejection_reason', 'paymob_transaction_id'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function plan()
    {
        return $this->belongsTo(SubscriptionPlan::class, 'plan_id');
    }

    public function approver()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    public function tickets()
    {
        return $this->hasMany(Ticket::class);
    }

    public function isActive(): bool
    {
        return $this->status === 'active'
            && $this->approval_status === 'approved'
            && $this->tickets_remaining > 0
            && ($this->end_date === null || $this->end_date > now());
    }

    public function canPublishToStore(): bool
    {
        return (bool) ($this->plan->can_publish_to_store ?? false);
    }
}
