<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\RouteHistory;

class RouteHistoryController extends Controller
{
        public function index()
    {
        $routes = RouteHistory::with('user')->latest()->get();

        return view('admin.route_history.index', compact('routes'));
    }

}
