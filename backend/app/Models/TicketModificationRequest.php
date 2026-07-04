<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TicketModificationRequest extends Model
{
    public $timestamps = false;

    protected $fillable = ['ticket_id', 'designer_id', 'description', 'status', 'industor_response', 'handled_at'];

    protected $casts = [
        'handled_at' => 'datetime',
        'created_at' => 'datetime',
    ];

    public function ticket()
    {
        return $this->belongsTo(Ticket::class);
    }

    public function designer()
    {
        return $this->belongsTo(User::class, 'designer_id');
    }
}
