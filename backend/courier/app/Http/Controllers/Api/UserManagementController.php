<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;

class UserManagementController extends Controller
{
    // GET /api/admin/users
    public function index()
    {
        $this->authorizeAdmin();
        $users = User::all();

        $users->transform(function ($user) {
            $user->avatar_url = $user->avatar
                ? asset('storage/' . $user->avatar)
                : asset('assets/images/user.png'); // fallback if needed
            return $user;
        });

        return response()->json($users);
    }

    // GET /api/admin/users/{id}
    public function show($id)
    {
        $this->authorizeAdmin();
        $user = User::findOrFail($id);
        $user->avatar_url = $user->avatar
            ? asset('storage/' . $user->avatar)
            : asset('assets/images/user.png');

        return response()->json($user);
    }

    // POST /api/admin/users
    public function store(Request $request)
    {
        $this->authorizeAdmin();

        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:6',
            'role' => 'in:admin,courier',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $request->role ?? 'courier',
        ]);

        return response()->json($user, 201);
    }

    // PUT /api/admin/users/{id}
    public function update(Request $request, $id)
    {
        $this->authorizeAdmin();
        $user = User::findOrFail($id);

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:users,email,' . $user->id,
            'password' => 'nullable|string|min:6',
            'role' => 'in:admin,courier',
        ]);

        $user->name = $request->name ?? $user->name;
        $user->email = $request->email ?? $user->email;
        if ($request->filled('password')) {
            $user->password = Hash::make($request->password);
        }
        $user->role = $request->role ?? $user->role;
        $user->save();

        return response()->json($user);
    }

    // DELETE /api/admin/users/{id}
    public function destroy($id)
    {
        $this->authorizeAdmin();
        $user = User::findOrFail($id);
        $user->delete();

        return response()->json(['message' => 'User deleted successfully']);
    }

    private function authorizeAdmin()
    {
        if (Auth::check() && Auth::user()->role !== 'admin') {
            abort(403, 'Unauthorized');
        }
    }
}
