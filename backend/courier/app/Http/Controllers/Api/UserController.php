<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;


class UserController extends Controller
{
    // Register courier (role always courier)
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => 'courier', // Always courier by default
        ]);

        return response()->json(['message' => 'User registered successfully', 'user' => $user], 201);
    }

    // Login and return token
    public function login(Request $request)
    {
        $credentials = $request->only('email', 'password');

        if (!Auth::attempt($credentials)) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        $user = Auth::user();
        $token = $user->createToken('api_token')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => $user
        ]);
    }


    // Logout
    public function logout(Request $request)
    {
        $request->user()->tokens()->delete();

        return response()->json(['message' => 'Logged out successfully']);
    }

    // View profile
    public function profile(Request $request)
    {
        $user = $request->user();

        if ($user->avatar) {
            $user->avatar = asset('storage/' . $user->avatar);
        }

        return response()->json($user);
    }

    // Update profile
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|string|email|max:255|unique:users,email,' . $user->id,
            'phone' => 'nullable|string|max:20',
            'vehicle' => 'nullable|string|max:255',
            'avatar' => 'nullable|image|max:2048', // max 2MB
        ]);

        if ($request->has('name')) $user->name = $request->name;
        if ($request->has('email')) $user->email = $request->email;
        if ($request->has('phone')) $user->phone = $request->phone;
        if ($request->has('vehicle')) $user->vehicle = $request->vehicle;

        // ✅ Avatar upload
        if ($request->hasFile('avatar')) {
            $path = $request->file('avatar')->store('avatars', 'public');
            $user->avatar = $path;
        }

        $user->save();

        return response()->json(['message' => 'Profile updated successfully', 'user' => $user]);
    }

    public function updateStatus(Request $request)
    {
        $request->validate([
            'is_online' => 'required|boolean',
        ]);

        $user = auth()->user();
        $user->is_online = $request->is_online;
        $user->save();

        return response()->json(['success' => true, 'is_online' => $user->is_online]);
    }

    public function updateLocation(Request $request)
    {
        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        $user = auth()->user();
        $user->current_latitude = $request->latitude;
        $user->current_longitude = $request->longitude;
        $user->last_updated_at = now();
        $user->save();

        return response()->json(['message' => 'Location updated']);
    }
    
    public function onlineUsers()
    {
        $onlineUsers = User::where('is_online', true)
            ->whereNotNull('current_latitude')
            ->whereNotNull('current_longitude')
            ->get();

        foreach ($onlineUsers as $user) {
            if ($user->avatar) {
                $user->avatar = asset('storage/' . $user->avatar);
            }
        }

        return response()->json($onlineUsers);
    }


    public function liveCourierLocations()
    {
        $this->authorize('admin-only'); // Optional if using Gate

        $couriers = User::where('role', 'courier')
            ->whereNotNull('current_latitude')
            ->select('id', 'name', 'current_latitude', 'current_longitude', 'last_updated_at')
            ->get();

        return response()->json($couriers);
    }


}
