<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TicketStatusHistory extends Model
{
    public $timestamps = false;

    protected $table = 'ticket_status_history';

    protected $fillable = ['ticket_id', 'from_status', 'to_status', 'changed_by', 'note'];

    protected $casts = [
        'created_at' => 'datetime',
    ];

    public function ticket()
    {
        return $this->belongsTo(Ticket::class);
    }

    public function changedBy()
    {
        return $this->belongsTo(User::class, 'changed_by');
    }
}
