<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Ticket extends Model
{
    public const STATUS_PENDING_TESTER_REVIEW = 'pending_tester_review';
    public const STATUS_WAITING_INDUSTOR_APPROVAL = 'waiting_industor_approval';
    public const STATUS_WAITING_TESTER_REVIEW = 'waiting_tester_review';
    public const STATUS_PENDING_PAYMENT = 'pending_payment';
    public const STATUS_APPROVED_BY_TESTER = 'approved_by_tester';
    public const STATUS_ACCEPTED = 'accepted';
    public const STATUS_MODIFICATION_REQUESTED = 'modification_requested';
    public const STATUS_IN_PROGRESS = 'in_progress';
    public const STATUS_AWAITING_QA = 'awaiting_qa';
    public const STATUS_COMPLETED = 'completed';
    public const STATUS_REJECTED_QA = 'rejected_qa';
    public const STATUS_REJECTED_BY_INDUSTOR = 'rejected_by_industor';
    public const STATUS_REJECTED_BY_TESTER = 'rejected_by_tester';
    public const STATUS_CANCELLED = 'cancelled';

    protected $fillable = [
        'industor_id', 'subscription_id', 'title', 'description', 'status',
        'tester_id', 'designer_id', 'deadline',
        'reviewed_at', 'approved_at', 'assigned_at', 'started_at',
        'uploaded_at', 'completed_at', 'rejection_reason',
        'is_published_to_store', 'store_listing_id',
        'accepted_at', 'qa_claimed_at',
        'price', 'review_notes', 'reviewed_by', 'is_late', 'penalty', 'penalty_reason',
        'is_single_purchase',
        'original_price', 'industor_price', 'designer_price', 'price_updated_at', 'urgent_price_applied',
        'industor_expected_deadline', 'tester_suggested_deadline', 'final_deadline',
        'deadline_approved_by_industor', 'deadline_negotiation_history',
        'industor_expected_price', 'tester_suggested_price',
        'industor_counter_deadline', 'industor_counter_price',
        'final_price', 'current_negotiation_round', 'negotiation_status',
    ];

    protected $casts = [
        'deadline' => 'datetime',
        'reviewed_at' => 'datetime',
        'approved_at' => 'datetime',
        'assigned_at' => 'datetime',
        'started_at' => 'datetime',
        'uploaded_at' => 'datetime',
        'completed_at' => 'datetime',
        'accepted_at' => 'datetime',
        'qa_claimed_at' => 'datetime',
        'is_published_to_store' => 'boolean',
        'is_late' => 'boolean',
        'is_single_purchase' => 'boolean',
        'price' => 'decimal:2',
        'penalty' => 'decimal:2',
        'original_price' => 'decimal:2',
        'industor_price' => 'decimal:2',
        'designer_price' => 'decimal:2',
        'price_updated_at' => 'datetime',
        'urgent_price_applied' => 'boolean',
        'industor_expected_deadline' => 'datetime',
        'tester_suggested_deadline' => 'datetime',
        'final_deadline' => 'datetime',
        'deadline_approved_by_industor' => 'boolean',
        'deadline_negotiation_history' => 'array',
        'industor_expected_price' => 'decimal:2',
        'tester_suggested_price' => 'decimal:2',
        'industor_counter_deadline' => 'datetime',
        'industor_counter_price' => 'decimal:2',
        'final_price' => 'decimal:2',
        'current_negotiation_round' => 'integer',
    ];

    protected $appends = [
        'is_overdue', 'time_type', 'remaining_percentage',
        'remaining_seconds', 'total_seconds', 'designer_earnings',
    ];

    public function industor()
    {
        return $this->belongsTo(User::class, 'industor_id');
    }

    public function tester()
    {
        return $this->belongsTo(User::class, 'tester_id');
    }

    public function reviewer()
    {
        return $this->belongsTo(User::class, 'reviewed_by');
    }

    public function designer()
    {
        return $this->belongsTo(User::class, 'designer_id');
    }

    public function subscription()
    {
        return $this->belongsTo(UserSubscription::class);
    }

    public function histories()
    {
        return $this->hasMany(TicketStatusHistory::class);
    }

    public function attachments()
    {
        return $this->hasMany(TicketAttachment::class);
    }

    public function modificationRequests()
    {
        return $this->hasMany(TicketModificationRequest::class);
    }

    public function storeListing()
    {
        return $this->hasOne(StoreListing::class);
    }

    public function product()
    {
        return $this->hasOne(Product::class);
    }

    public function payments()
    {
        return $this->hasMany(Payment::class);
    }

    public function priceHistory()
    {
        return $this->hasMany(TicketPriceHistory::class);
    }

    public function deadlineNegotiations()
    {
        return $this->hasMany(TicketDeadlineNegotiation::class);
    }

    public function getIsOverdueAttribute(): bool
    {
        return $this->deadline
            && $this->deadline < now()
            && !in_array($this->status, [self::STATUS_COMPLETED, self::STATUS_CANCELLED, self::STATUS_AWAITING_QA]);
    }

    public function getTotalSecondsAttribute(): int
    {
        if (!$this->reviewed_at || !$this->deadline) {
            return 0;
        }

        return max(1, (int) ($this->deadline->timestamp - $this->reviewed_at->timestamp));
    }

    public function getRemainingSecondsAttribute(): int
    {
        if (!$this->deadline) {
            return 0;
        }

        return max(0, (int) ($this->deadline->timestamp - now()->timestamp));
    }

    public function getRemainingPercentageAttribute(): float
    {
        if (!$this->reviewed_at || !$this->deadline) {
            return 100.0;
        }

        $remaining = $this->remaining_seconds;
        $percentage = ($remaining / $this->total_seconds) * 100;

        return round(max(0, min(100, $percentage)), 1);
    }

    public function getTimeTypeAttribute(): string
    {
        return $this->remaining_percentage > 50 ? 'normal' : 'urgent';
    }

    public function getCanPublishToStoreAttribute(): bool
    {
        return $this->status === self::STATUS_COMPLETED
            && !$this->is_published_to_store
            && $this->subscription
            && $this->subscription->canPublishToStore();
    }

    public function getDesignerEarningsAttribute(): ?string
    {
        if ($this->price === null) {
            return null;
        }

        $penalty = $this->penalty ?? 0;

        return (string) max(0, (float) $this->price - (float) $penalty);
    }
}
