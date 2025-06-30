<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\SavedDestinationController;
use App\Http\Controllers\Api\RouteHistoryController;
use App\Http\Controllers\Api\UserManagementController;
use App\Http\Controllers\Api\Admin\AssignedRouteController;

// Public routes
Route::post('/register', [UserController::class, 'register']);
Route::post('/login', [UserController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // User
    Route::post('/logout', [UserController::class, 'logout']);
    Route::get('/user', [UserController::class, 'profile']); 
    Route::put('/user', [UserController::class, 'updateProfile']); 
    Route::put('/user/status', [UserController::class, 'updateStatus']);
    Route::post('/update-location', [UserController::class, 'updateLocation']);
    Route::get('/admin/live-locations', [UserController::class, 'liveCourierLocations']); 
    Route::put('/user/location', [UserController::class, 'updateLocation']);

    // Saved destinations
    Route::get('/saved-destinations', [SavedDestinationController::class, 'index']);
    Route::post('/saved-destinations', [SavedDestinationController::class, 'store']);
    Route::delete('/saved-destinations/{id}', [SavedDestinationController::class, 'destroy']);

    // Route history
    Route::get('/route-history', [RouteHistoryController::class, 'index']);
    Route::post('/route-history', [RouteHistoryController::class, 'store']);
    Route::get('/route-history/{id}', [RouteHistoryController::class, 'show']);
    Route::delete('/route-history/{id}', [RouteHistoryController::class, 'destroy']);
    Route::post('/route-history/optimize', [RouteHistoryController::class, 'optimize']);

    Route::get('/assigned-routes', [AssignedRouteController::class, 'index']);
    Route::post('/assign-route', [AssignedRouteController::class, 'store']);

    // ✅ Admin-only user management
    Route::middleware('can:isAdmin')->group(function () {
        Route::get('/admin/users', [UserManagementController::class, 'index']);
        Route::get('/admin/users/{id}', [UserManagementController::class, 'show']);
        Route::post('/admin/users', [UserManagementController::class, 'store']);
        Route::put('/admin/users/{id}', [UserManagementController::class, 'update']);
        Route::delete('/admin/users/{id}', [UserManagementController::class, 'destroy']);
        Route::get('/admin/online-users', [UserManagementController::class, 'onlineUsers']);
    
    
    });
});
    Route::get('/online-users', [UserController::class, 'onlineUsers']);
