<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class StoreListing extends Model
{
    protected $fillable = [
        'ticket_id', 'industor_id', 'attachment_id',
        'title', 'description', 'price', 'status',
    ];

    protected $casts = [
        'price' => 'decimal:2',
    ];

    public function ticket()
    {
        return $this->belongsTo(Ticket::class);
    }

    public function industor()
    {
        return $this->belongsTo(User::class, 'industor_id');
    }

    public function attachment()
    {
        return $this->belongsTo(TicketAttachment::class);
    }
}
