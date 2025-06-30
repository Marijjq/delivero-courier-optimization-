<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\AssignedRoute;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class AssignedRouteController extends Controller
{
    // Web: List assigned routes with pagination
    public function list()
    {
        $routes = AssignedRoute::with('user')->latest()->paginate(20);

        return view('admin.assign_route.assigned_routes_list', compact('routes'));
    }

    // Web: Show form to assign a new route
    public function create()
    {
        $users = User::where('role', 'courier')->get();

        return view('admin.assign_route.assign_route', compact('users'));
    }

    // Web & API: Store a new assigned route
    public function store(Request $request)
    {

        if ($request->expectsJson()) {
            // API request validation
            $validator = Validator::make($request->all(), [
                'user_id'    => 'required|exists:users,id',
                'title'      => 'required|string|max:255',
                'coordinates'=> 'required|array|min:1',
                'coordinates.*.lat' => 'required|numeric',
                'coordinates.*.lon' => 'required|numeric',
                'distance'   => 'nullable|numeric',
                'duration'   => 'nullable|integer',
                'due_at'     => 'nullable|date',
                'note'       => 'nullable|string',
            ]);

            if ($validator->fails()) {
                return response()->json(['errors' => $validator->errors()], 422);
            }

            $coordinates = $request->input('coordinates');
        } else {
            // Web form validation
            $validator = Validator::make($request->all(), [
                'user_id'    => 'required|exists:users,id',
                'title'      => 'required|string|max:255',
                'coordinates'=> 'required|string',
                'distance'   => 'nullable|numeric',
                'duration'   => 'nullable|integer',
                'due_at'     => 'nullable|date',
                'note'       => 'nullable|string',
            ]);

            if ($validator->fails()) {
                return redirect()->back()->withErrors($validator)->withInput();
            }

            $raw = explode("\n", $request->input('coordinates'));
            $coordinates = [];

            foreach ($raw as $line) {
                $line = trim($line);
                if (empty($line)) continue;

                $parts = array_map('trim', explode(',', $line));
                if (count($parts) !== 2 || !is_numeric($parts[0]) || !is_numeric($parts[1])) {
                    return redirect()->back()
                        ->withErrors(['coordinates' => "Invalid coordinate format: {$line}"])
                        ->withInput();
                }

                $coordinates[] = ['lat' => (float)$parts[0], 'lon' => (float)$parts[1]];
            }

            if (count($coordinates) < 1) {  // changed from <2 to <1
                return redirect()->back()
                    ->withErrors(['coordinates' => 'At least one valid coordinate is required'])
                    ->withInput();
            }
        }

        $route = AssignedRoute::create([
            'admin_id'    => Auth::id(),
            'user_id'     => $request->input('user_id'),
            'title'       => $request->input('title'),
            'coordinates' => $coordinates,
            'distance'    => $request->input('distance'),
            'duration'    => $request->input('duration'),
            'assigned_at' => now(),
            'due_at'      => $request->input('due_at'),
            'note'        => $request->input('note'),
            'status'      => 'assigned',
        ]);

        if ($request->expectsJson()) {
            return response()->json($route, 201);
        }

        return redirect()->route('assign.route.list')
            ->with('success', 'Route assigned successfully!');
    }

    // API: List all assigned routes (admin only)
    public function index()
    {

        return AssignedRoute::with('user')->latest()->get();
    }

}
