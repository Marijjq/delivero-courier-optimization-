<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

use App\Models\RouteHistory;
use App\Models\SavedDestination;
use App\Models\User;

class AdminDashboardController extends Controller
{

    public function index()
    {
        $userCount = User::count();
        $destinationCount = SavedDestination::count();
        $routeCount = RouteHistory::count();
        $onlineCount = User::where('is_online', true)->count();

        return view('admin.dashboard', compact('userCount', 'destinationCount', 'routeCount', 'onlineCount'));
    }


}
