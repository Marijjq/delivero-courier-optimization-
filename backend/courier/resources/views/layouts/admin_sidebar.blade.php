<div class="offcanvas offcanvas-start sidebar text-bg-dark" tabindex="-1" id="adminSidebar" aria-labelledby="adminSidebarLabel">
    <div class="offcanvas-header">
        <h5 class="offcanvas-title text-white" id="adminSidebarLabel">Admin Menu</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="offcanvas" aria-label="Close"></button>
    </div>

    <!-- Logo inserted here -->
    <div class="text-center mb-3">
        <a href="{{ route('admin.dashboard') }}">
            <img src="{{ asset('assets/images/logo.png') }}" alt="Logo" style="max-width: 150px; height: auto;" />
        </a>
    </div>

    <div class="offcanvas-body p-0 d-flex flex-column">
        <ul class="nav nav-pills flex-column mb-auto px-2">
            <li class="nav-item">
                <a class="nav-link {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}" href="{{ route('admin.dashboard') }}">
                    <i class="bi bi-speedometer2 me-2"></i> Dashboard
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link {{ request()->routeIs('admin.profile') ? 'active' : '' }}" href="{{ route('admin.profile') }}">
                    <i class="bi bi-person-circle me-2"></i> My Profile
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link {{ request()->routeIs('admin.users.index') ? 'active' : '' }}" href="{{ route('admin.users.index') }}">
                    <i class="bi bi-people me-2"></i> Users
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link {{ request()->routeIs('admin.destinations.index') ? 'active' : '' }}" href="{{ route('admin.destinations.index') }}">
                    <i class="bi bi-geo-alt me-2"></i> Saved Destinations
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link {{ request()->routeIs('admin.routes.index') ? 'active' : '' }}" href="{{ route('admin.routes.index') }}">
                    <i class="bi bi-list-task me-2"></i> Route History
                </a>
            </li>
            <!-- Assigned Routes menu item -->
            <li class="nav-item">
                <a class="nav-link {{ request()->routeIs('assign.route.list') ? 'active' : '' }}" href="{{ route('assign.route.list') }}">
                    <i class="bi bi-map me-2"></i> Assigned Routes
                </a>
            </li>
        </ul>

        <form method="POST" action="{{ route('admin.logout') }}" class="m-3 mt-auto">
            @csrf
            <button class="btn btn-danger w-100">Logout</button>
        </form>
    </div>
</div>
