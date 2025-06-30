<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AdminDashboardController;
use App\Http\Controllers\Auth\AdminLoginController;
use App\Http\Controllers\Admin\UserManagementController;
use App\Http\Controllers\Admin\SavedDestinationController;
use App\Http\Controllers\Admin\RouteHistoryController;
use App\Http\Controllers\Admin\AdminProfileController;
use App\Http\Controllers\Api\Admin\AssignedRouteController;

// Admin authentication
Route::get('/admin/login', [AdminLoginController::class, 'showLoginForm'])->name('login');
Route::post('/admin/login', [AdminLoginController::class, 'login']);
Route::post('/admin/logout', [AdminLoginController::class, 'logout'])->name('admin.logout');

// Admin area
Route::middleware(['auth'])->prefix('admin')->group(function () {
    Route::get('/dashboard', [AdminDashboardController::class, 'index'])->name('admin.dashboard');

    // User Management
    Route::get('/users', [UserManagementController::class, 'index'])->name('admin.users.index');
    Route::get('/users/create', [UserManagementController::class, 'create'])->name('admin.users.create');
    Route::post('/users', [UserManagementController::class, 'store'])->name('admin.users.store');
    Route::get('/users/{user}/edit', [UserManagementController::class, 'edit'])->name('admin.users.edit');
    Route::put('/users/{user}', [UserManagementController::class, 'update'])->name('admin.users.update');
    Route::delete('/users/{user}', [UserManagementController::class, 'destroy'])->name('admin.users.destroy');

    // Saved Destinations
    Route::get('/saved-destinations', [SavedDestinationController::class, 'index'])->name('admin.destinations.index');

    // Route History
    Route::get('/route-history', [RouteHistoryController::class, 'index'])->name('admin.routes.index');

    // Admin Profile
    Route::get('/profile', [AdminProfileController::class, 'edit'])->name('admin.profile');
    Route::post('/profile', [AdminProfileController::class, 'update'])->name('admin.profile.update');

    // Live Courier Map
    Route::view('/live-map', 'admin.live_map')->name('admin.live-map');

    Route::get('/assign-route', [AssignedRouteController::class, 'create'])->name('assign.route.form');
    Route::post('/assign-route', [AssignedRouteController::class, 'store'])->name('assign.route.submit');

    // Assign route
    Route::get('/assign-route', [AssignedRouteController::class, 'create'])->name('assign.route.form');
    Route::post('/assign-route', [AssignedRouteController::class, 'store'])->name('assign.route.submit');
    Route::get('/assigned-routes', [AssignedRouteController::class, 'list'])->name('assign.route.list');

});
