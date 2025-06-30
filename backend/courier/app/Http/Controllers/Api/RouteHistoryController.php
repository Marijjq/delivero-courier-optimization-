<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;
use App\Models\RouteHistory;
use App\Helpers\GeoHelper;
use Carbon\Carbon;

class RouteHistoryController extends Controller
{
    // List route histories
    public function index()
    {
        $user = Auth::user();

        $query = RouteHistory::with('user')->latest();
        return $user->role === 'admin'
            ? $query->get()
            : $query->where('user_id', $user->id)->get();
    }

    // Store a new route history (single destination)
    public function store(Request $request)
    {
        $validated = $request->validate([
            'start_latitude' => 'required|numeric',
            'start_longitude' => 'required|numeric',
            'end_latitude' => 'required|numeric',
            'end_longitude' => 'required|numeric',
            'distance' => 'required|numeric',
            'duration' => 'required|integer',
            'path' => 'nullable|string',
        ]);

        $startName = GeoHelper::reverseGeocode($validated['start_latitude'], $validated['start_longitude']) ?? 'Unknown Start';
        $endName = GeoHelper::reverseGeocode($validated['end_latitude'], $validated['end_longitude']) ?? 'Unknown End';

        $history = RouteHistory::create([
            'user_id' => Auth::id(),
            'start_location_name' => $startName,
            'start_latitude' => $validated['start_latitude'],
            'start_longitude' => $validated['start_longitude'],
            'end_location_name' => $endName,
            'end_latitude' => $validated['end_latitude'],
            'end_longitude' => $validated['end_longitude'],
            'distance' => $validated['distance'],
            'duration' => $validated['duration'],
            'completed_at' => now(),
            'path' => $validated['path'] ?? null,
            'route_type' => 'simple',
        ]);

        return response()->json($history, 201);
    }

    // Store optimized multi-stop route
    public function optimize(Request $request)
    {
        $coordinates = $request->input('coordinates');
        $names = $request->input('names');

        if (!is_array($coordinates) || count($coordinates) < 2) {
            return response()->json(['message' => 'At least two coordinates are required.'], 422);
        }

        $coordString = collect($coordinates)
            ->map(fn($c) => "{$c['lon']},{$c['lat']}")
            ->implode(';');

        $osrmUrl = "http://router.project-osrm.org/trip/v1/driving/{$coordString}?roundtrip=false&source=first&destination=last&geometries=geojson";

        $response = Http::get($osrmUrl);

        if ($response->failed()) {
            return response()->json(['message' => 'Failed to fetch optimized route.'], 500);
        }

        $data = $response->json();

        if (empty($data['trips'][0]) || !isset($data['trips'][0]['geometry'])) {
            return response()->json(['message' => 'Invalid route data from OSRM.'], 422);
        }

        $trip = $data['trips'][0];
        $start = $coordinates[0];
        $end = $coordinates[count($coordinates) - 1];

        $history = RouteHistory::create([
            'user_id' => Auth::id(),
            'start_location_name' => $names[0] ?? 'Start',
            'start_latitude' => $start['lat'],
            'start_longitude' => $start['lon'],
            'end_location_name' => $names[count($names) - 1] ?? 'End',
            'end_latitude' => $end['lat'],
            'end_longitude' => $end['lon'],
            'distance' => $trip['distance'],
            'duration' => $trip['duration'],
            'completed_at' => Carbon::now(),
            'path' => json_encode($trip['geometry']),
        ]);

        return response()->json([
            'message' => 'Optimized route saved successfully.',
            'route' => $history,
        ]);
    }

    // Show specific route
    public function show(RouteHistory $routeHistory)
    {
        $this->authorizeAccess($routeHistory);
        return $routeHistory;
    }

    // Update route
    public function update(Request $request, RouteHistory $routeHistory)
    {
        $this->authorizeAccess($routeHistory);

        $data = $request->validate([
            'start_location_name' => 'sometimes|string',
            'start_latitude' => 'sometimes|numeric',
            'start_longitude' => 'sometimes|numeric',
            'end_location_name' => 'sometimes|string',
            'end_latitude' => 'sometimes|numeric',
            'end_longitude' => 'sometimes|numeric',
            'distance' => 'sometimes|numeric',
            'duration' => 'sometimes|integer',
            'completed_at' => 'nullable|date',
            'path' => 'nullable|string',
        ]);

        $routeHistory->update($data);
        return $routeHistory;
    }

    // Delete route
    public function destroy(RouteHistory $routeHistory)
    {
        $this->authorizeAccess($routeHistory);
        $routeHistory->delete();
        return response()->json(['message' => 'Route history deleted']);
    }

    // Access control helper
    private function authorizeAccess(RouteHistory $routeHistory)
    {
        $user = Auth::user();
        if ($user->id !== $routeHistory->user_id && $user->role !== 'admin') {
            abort(403, 'Unauthorized');
        }
    }
}
