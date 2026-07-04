<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TicketDeadlineNegotiation extends Model
{
    public $timestamps = false;

    protected $table = 'ticket_deadline_negotiations';

    protected $fillable = [
        'ticket_id', 'round_number', 'proposed_by', 'proposed_deadline', 'proposed_price', 'reason', 'status', 'created_by',
    ];

    protected $casts = [
        'proposed_deadline' => 'datetime',
        'proposed_price' => 'decimal:2',
        'created_at' => 'datetime',
    ];

    public function ticket()
    {
        return $this->belongsTo(Ticket::class);
    }

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
