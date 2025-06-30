@extends('layouts.app')

@section('content')
<div class="container pt-5">
    <h2>Saved Destinations</h2>
    <table class="table table-bordered">
        <thead>
            <tr>
                <th>ID</th>
                <th>User</th>
                <th>Location Name</th>
                <th>Latitude</th>
                <th>Longitude</th>
                <th>Saved At</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($destinations as $destination)
                <tr>
                    <td>{{ $destination->id }}</td>
                    <td>{{ $destination->user->name }}</td>
                    <td>{{ $destination->location_name }}</td>
                    <td>{{ $destination->latitude }}</td>
                    <td>{{ $destination->longitude }}</td>
                    <td>{{ $destination->created_at->format('Y-m-d H:i') }}</td>
                </tr>
            @empty
                <tr><td colspan="6" class="text-center">No destinations found.</td></tr>
            @endforelse
        </tbody>
    </table>
</div>
@endsection
