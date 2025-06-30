@extends('layouts.app')

@section('content')
<div class="container pt-5">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2>Assigned Routes</h2>
        <a href="{{ route('assign.route.form') }}" class="btn btn-primary">Assign New Route</a>
    </div>

    @if(session('success'))
        <div class="alert alert-success">{{ session('success') }}</div>
    @endif

    @if($routes->count() === 0)
        <p>No assigned routes found.</p>
    @else
        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Title</th>
                    <th>Courier</th>
                    <th>Status</th>
                    <th>Due Date</th>
                    <th>Assigned At</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach($routes as $route)
                <tr>
                    <td>{{ $route->title }}</td>
                    <td>{{ $route->user->name ?? 'Unknown' }}</td>
                    <td>{{ ucfirst($route->status) }}</td>
                    <td>{{ optional($route->due_at)->format('Y-m-d H:i') ?? '-' }}</td>
                    <td>{{ $route->assigned_at->format('Y-m-d H:i') }}</td>
                    <td>
                        <a href="{{ route('assign.route.form') }}" class="btn btn-sm btn-primary">Assign New</a>
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>

        {{ $routes->links() }}
    @endif
</div>
@endsection
