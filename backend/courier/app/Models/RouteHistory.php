<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RouteHistory extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'start_location_name',
        'start_latitude',
        'start_longitude',
        'end_location_name',
        'end_latitude',
        'end_longitude',
        'distance',
        'duration',
        'completed_at',
        'path',
    ];

    protected $dates = ['completed_at'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
