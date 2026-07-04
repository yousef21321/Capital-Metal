<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class IndustorDesigner extends Model
{
    public $timestamps = false;

    protected $table = 'industor_designers';

    protected $fillable = ['industor_id', 'designer_id', 'is_active'];

    protected $casts = [
        'is_active' => 'boolean',
        'created_at' => 'datetime',
    ];

    public function industor()
    {
        return $this->belongsTo(User::class, 'industor_id');
    }

    public function designer()
    {
        return $this->belongsTo(User::class, 'designer_id');
    }
}
