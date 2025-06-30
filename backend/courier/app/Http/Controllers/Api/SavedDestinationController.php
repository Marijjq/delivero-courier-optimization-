<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SavedDestination;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Helpers\GeoHelper;

class SavedDestinationController extends Controller
{
    // GET /api/saved-destinations
    public function index()
    {
        $user = Auth::user();

        if ($user->role === 'admin') {
            return response()->json(SavedDestination::all());
        }

        return response()->json($user->savedDestinations);
    }

    // POST /api/saved-destinations
    public function store(Request $request)
    {
        // 🔍 Log incoming request data
        \Log::info('Saving destination attempt', [
            'auth_id' => Auth::id(),
            'request' => $request->all()
        ]);

        if (Auth::id() === null) {
            return response()->json([
                'error' => 'Authentication failed. Token may be missing or invalid.',
            ], 401);
        }

        $request->validate([
            'location_name' => 'required|string|max:255', 
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        try {
            $destination = SavedDestination::create([
                'user_id' => Auth::id(),
                'latitude' => $request->latitude,
                'longitude' => $request->longitude,
                'location_name' => $request->location_name, // ✅ Correct usage
            ]);

            return response()->json($destination, 201);
        } catch (\Throwable $e) {
            \Log::error('Failed to save destination: ' . $e->getMessage());

            return response()->json([
                'error' => 'Server error while saving destination',
                'details' => $e->getMessage()
            ], 500);
        }
    }

    // DELETE /api/saved-destinations/{id}
    public function destroy($id)
    {
        $destination = SavedDestination::findOrFail($id);
        $user = Auth::user();

        if ($user->role !== 'admin' && $destination->user_id !== $user->id) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $destination->delete();
        return response()->json(['message' => 'Deleted successfully']);
    }
}
