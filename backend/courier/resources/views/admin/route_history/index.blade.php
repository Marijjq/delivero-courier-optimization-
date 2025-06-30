@extends('layouts.app')

@section('content')
<div class="container pt-5">
    <h2 class="mb-4">Route History</h2>

    <table class="table table-striped">
        <thead>
            <tr>
                <th>User</th>
                <th>Start Location</th>
                <th>End Location</th>
                <th>Distance (km)</th>
                <th>Duration (min)</th>
                <th>Completed At</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($routes as $route)
                <tr>
                    <td>{{ $route->user->name }}</td>
                    <td>{{ $route->start_location_name }} ({{ $route->start_lat }}, {{ $route->start_lon }})</td>
                    <td>{{ $route->end_location_name }} ({{ $route->end_lat }}, {{ $route->end_lon }})</td>
                    <td>{{ $route->distance }}</td>
                    <td>{{ $route->duration }}</td>
                    <td>{{ $route->completed_at }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
</div>
@endsection
