<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class VisitorSession extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'user_id', 'session_id', 'traffic_source_id', 'device_type',
        'country', 'started_at', 'ended_at', 'converted',
    ];

    protected function casts(): array
    {
        return ['converted' => 'boolean'];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function trafficSource()
    {
        return $this->belongsTo(TrafficSource::class, 'traffic_source_id');
    }
}
