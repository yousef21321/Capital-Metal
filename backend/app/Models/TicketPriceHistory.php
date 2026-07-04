<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TicketPriceHistory extends Model
{
    public $timestamps = false;

    protected $table = 'ticket_price_history';

    protected $fillable = [
        'ticket_id', 'original_price', 'industor_price',
        'designer_price', 'change_reason', 'created_at',
    ];

    protected $casts = [
        'original_price' => 'decimal:2',
        'industor_price' => 'decimal:2',
        'designer_price' => 'decimal:2',
        'created_at' => 'datetime',
    ];

    public function ticket()
    {
        return $this->belongsTo(Ticket::class);
    }
}
