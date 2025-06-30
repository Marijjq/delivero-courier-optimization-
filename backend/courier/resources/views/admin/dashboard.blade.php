@extends('layouts.app')

@section('content')
<div class="container pt-5">
    <h2 class="mb-4">Admin Dashboard</h2>

    <div class="row">
        <!-- User Management -->
        <div class="col-md-6 mb-4">
            <div class="card text-center">
                <div class="card-body">
                    <h5 class="card-title">User Management</h5>
                    <p class="card-text">Total Users: <strong>{{ $userCount }}</strong></p>
                    <a href="{{ route('admin.users.index') }}" class="btn btn-primary">Manage Users</a>
                </div>
            </div>
        </div>

        <!-- Saved Destinations -->
        <div class="col-md-6 mb-4">
            <div class="card text-center">
                <div class="card-body">
                    <h5 class="card-title">Saved Destinations</h5>
                    <p class="card-text">Total Destinations: <strong>{{ $destinationCount }}</strong></p>
                    <a href="{{ route('admin.destinations.index') }}" class="btn btn-success">View Destinations</a>
                </div>
            </div>
        </div>

        <!-- Route History -->
        <div class="col-md-6 mb-4">
            <div class="card text-center">
                <div class="card-body">
                    <h5 class="card-title">Route History</h5>
                    <p class="card-text">Total Routes: <strong>{{ $routeCount }}</strong></p>
                    <a href="{{ route('admin.routes.index') }}" class="btn btn-warning">View Route History</a>
                </div>
            </div>
        </div>

        <!-- Online Users -->
        <div class="col-md-6 mb-4">
            <div class="card text-center border border-info">
                <div class="card-body">
                    <h5 class="card-title">Online Couriers</h5>
                    <p class="card-text">Currently Online: <strong>{{ $onlineCount }}</strong></p>
                    <a href="{{ route('admin.live-map') }}" class="btn btn-outline-info">View Live Locations</a>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
