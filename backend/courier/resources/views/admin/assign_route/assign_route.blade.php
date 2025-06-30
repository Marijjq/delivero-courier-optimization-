@extends('layouts.app')

@section('content')
<div class="container pt-5">
    <h2>Assign Route to Courier</h2>

    @if(session('success'))
        <div class="alert alert-success">{{ session('success') }}</div>
    @endif

    @if($errors->any())
        <div class="alert alert-danger">
            <ul class="mb-0">
                @foreach($errors->all() as $error)
                <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form action="{{ route('assign.route.submit') }}" method="POST">
        @csrf

        <div class="mb-3">
            <label for="user_id" class="form-label">Select Courier</label>
            <select name="user_id" id="user_id" class="form-control" required>
                <option value="">-- Select --</option>
                @foreach($users as $user)
                    <option value="{{ $user->id }}" {{ old('user_id') == $user->id ? 'selected' : '' }}>
                        {{ $user->name }} ({{ $user->email }})
                    </option>
                @endforeach
            </select>
        </div>

        <div class="mb-3">
            <label for="title" class="form-label">Route Title</label>
            <input type="text" name="title" class="form-control" value="{{ old('title') }}" required>
        </div>

        <div class="mb-3">
            <label for="coordinates" class="form-label">Coordinates (lat,lon per line)</label>
            <textarea name="coordinates" rows="5" class="form-control" placeholder="42.0087,20.9716&#10;42.0102,20.9735" required>{{ old('coordinates') }}</textarea>
            <small class="form-text text-muted">Enter each coordinate on a new line, latitude and longitude separated by a comma.</small>
        </div>

        <button type="submit" class="btn btn-primary">Assign Route</button>
    </form>
</div>
@endsection
