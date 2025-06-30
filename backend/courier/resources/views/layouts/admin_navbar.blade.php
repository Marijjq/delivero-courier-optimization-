<nav class="navbar navbar-dark bg-dark fixed-top">
    <div class="container-fluid">
        <!-- Sidebar toggle button -->
        <button
            class="navbar-toggler me-2"
            type="button"
            data-bs-toggle="offcanvas"
            data-bs-target="#adminSidebar"
            aria-controls="adminSidebar"
            aria-label="Toggle navigation"
        >
            <span class="navbar-toggler-icon"></span>
        </button>

        <!-- Logo placed here -->
        <a href="{{ route('admin.dashboard') }}" class="navbar-brand d-flex align-items-center me-3">
            <img src="{{ asset('assets/images/logo.png') }}" alt="Logo" height="32" />
        </a>

        <div class="d-flex align-items-center text-white">
            @if (Auth::check())
                <a
                    href="{{ route('admin.profile') }}"
                    class="d-flex align-items-center text-white text-decoration-none me-3"
                >
                    <img
                        src="{{ Auth::user()->avatar ? asset('storage/' . Auth::user()->avatar) : 'https://via.placeholder.com/32' }}"
                        alt="avatar"
                        class="avatar-sm me-2"
                    />
                    <span>{{ Auth::user()->name }}</span>
                </a>
            @endif

            <form method="POST" action="{{ route('admin.logout') }}">
                @csrf
                <button type="submit" class="btn btn-outline-light btn-sm">Logout</button>
            </form>
        </div>
    </div>
</nav>
