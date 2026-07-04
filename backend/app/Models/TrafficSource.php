<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TrafficSource extends Model
{
    public $timestamps = false;

    protected $fillable = ['source_name'];

    public function sessions()
    {
        return $this->hasMany(VisitorSession::class, 'traffic_source_id');
    }
}
