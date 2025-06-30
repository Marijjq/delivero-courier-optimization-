<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AssignedRoute extends Model
{
        protected $fillable = [
        'admin_id', 'user_id', 'title', 'coordinates', 'distance',
        'duration', 'assigned_at', 'due_at', 'status', 'note'
    ];

    protected $casts = [
        'coordinates' => 'array',
        'assigned_at' => 'datetime',
        'due_at' => 'datetime',
    ];

    public function user() {
        return $this->belongsTo(User::class);
    }

    public function admin() {
        return $this->belongsTo(User::class, 'admin_id');
    }

}
