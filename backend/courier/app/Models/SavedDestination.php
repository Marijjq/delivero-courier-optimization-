<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SavedDestination extends Model
{
    protected $fillable = [
        'user_id',
        'latitude',
        'longitude',
        'location_name',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

}
