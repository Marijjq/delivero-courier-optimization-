<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\SavedDestination;

class SavedDestinationController extends Controller
{
        public function index()
    {
        $destinations = SavedDestination::with('user')->latest()->get();
        return view('admin.saved_destinations.index', compact('destinations'));
    }
}
