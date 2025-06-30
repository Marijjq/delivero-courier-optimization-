@extends('layouts.app')

@section('content')
<div class="container pt-5">
    <div class="d-flex align-items-center mb-4">
        @if(Auth::user()->avatar)
            <img src="{{ asset('storage/' . Auth::user()->avatar) }}"
                 alt="Avatar"
                 class="rounded-circle me-3 shadow"
                 style="width: 60px; height: 60px; object-fit: cover;">
        @else
            <img src="https://via.placeholder.com/60"
                 alt="Default Avatar"
                 class="rounded-circle me-3 shadow"
                 style="width: 100px; height: 100px; object-fit: cover;">
        @endif
        <h2 class="mb-0">My Profile</h2>
    </div>

    <!-- ✅ Profile Info Section -->
    <div class="card mb-4">
        <div class="card-header">Profile Information</div>
        <div class="card-body">
            <p><strong>Name:</strong> {{ Auth::user()->name }}</p>
            <p><strong>Email:</strong> {{ Auth::user()->email }}</p>
            <p><strong>Role:</strong> {{ Auth::user()->role }}</p>
            <p><strong>Phone:</strong> {{ Auth::user()->phone ?? 'N/A' }}</p>
        </div>
    </div>

    <!-- ✅ Edit Profile Section -->
    <div class="card">
        <div class="card-header">Edit Profile</div>
        <div class="card-body">
            @if(session('success'))
                <div class="alert alert-success">{{ session('success') }}</div>
            @endif

            <form method="POST" action="{{ route('admin.profile.update') }}" enctype="multipart/form-data">
                @csrf
                <div class="mb-3">
                    <label>Name</label>
                    <input type="text" name="name" value="{{ old('name', Auth::user()->name) }}" class="form-control">
                </div>
                <div class="mb-3">
                    <label>Email</label>
                    <input type="email" name="email" value="{{ old('email', Auth::user()->email) }}" class="form-control">
                </div>
                <div class="mb-3">
                    <label>Phone</label>
                    <input type="text" name="phone" value="{{ old('phone', Auth::user()->phone) }}" class="form-control">
                </div>
                <div class="mb-3">
                    <label>Avatar (optional)</label>
                    <input type="file" name="avatar" class="form-control">
                </div>
                <div class="mb-3">
                    <label>New Password (optional)</label>
                    <input type="password" name="password" class="form-control">
                </div>
                <div class="mb-3">
                    <label>Confirm Password</label>
                    <input type="password" name="password_confirmation" class="form-control">
                </div>
                <button type="submit" class="btn btn-primary">Update Profile</button>
            </form>
        </div>
    </div>
</div>
@endsection
