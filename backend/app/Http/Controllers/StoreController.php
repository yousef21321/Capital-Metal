<?php

namespace App\Http\Controllers;

use App\Models\StoreListing;
use Illuminate\Http\Request;

class StoreController extends Controller
{
    public function index(Request $request)
    {
        $query = StoreListing::with(['ticket', 'industor', 'attachment'])
            ->where('status', 'active')
            ->latest();

        if ($request->search) {
            $query->where('title', 'like', "%{$request->search}%");
        }

        return response()->json($query->paginate($request->per_page ?? 20));
    }

    public function show($id)
    {
        return response()->json(
            StoreListing::with(['ticket', 'industor', 'attachment'])->where('status', 'active')->findOrFail($id)
        );
    }
}
