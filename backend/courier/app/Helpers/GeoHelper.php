<?php

namespace App\Helpers;

use Illuminate\Support\Facades\Http;

class GeoHelper
{
    public static function reverseGeocode(float $lat, float $lon): ?string
    {
        $url = "https://nominatim.openstreetmap.org/reverse";

        $response = Http::withHeaders([
            'User-Agent' => 'courier-app/1.0'
        ])->get($url, [
            'format' => 'json',
            'lat' => $lat,
            'lon' => $lon,
            'zoom' => 18,
            'addressdetails' => 1,
        ]);

        if ($response->successful()) {
            return $response->json('display_name');
        }

        return null;
    }
}
