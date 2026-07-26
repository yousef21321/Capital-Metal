<?php

namespace App\Http\Controllers;

use App\Models\IndustorDesigner;
use App\Models\User;
use Illuminate\Http\Request;

class IndustorDesignerController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        abort_unless($user->hasRole('industor'), 403, 'Only industors can manage their designer pool.');

        $designers = $user->designerPool()->with('role')->get(['users.id', 'users.name', 'users.email']);

        return response()->json($designers);
    }

    public function findByEmail(Request $request)
    {
        $user = $request->user();
        abort_unless($user->hasRole('industor'), 403, 'Only industors can search designers.');

        $data = $request->validate(['email' => 'required|string|email']);

        $designer = User::where('email', $data['email'])->whereHas('role', fn ($q) => $q->where('name', 'designer'))->first(['id', 'name', 'email']);

        abort_if(! $designer, 404, 'No designer found with that email.');

        $alreadyInPool = $user->designerPool()->where('users.id', $designer->id)->exists();

        return response()->json([
            'id' => $designer->id,
            'name' => $designer->name,
            'email' => $designer->email,
            'in_pool' => $alreadyInPool,
        ]);
    }

    public function store(Request $request)
    {
        $user = $request->user();
        abort_unless($user->hasRole('industor'), 403, 'Only industors can manage their designer pool.');

        $data = $request->validate([
            'designer_id' => 'required|exists:users,id',
        ]);

        $designer = User::findOrFail($data['designer_id']);
        abort_unless($designer->hasRole('designer'), 422, 'Selected user is not a designer.');

        $link = IndustorDesigner::firstOrCreate(
            ['industor_id' => $user->id, 'designer_id' => $data['designer_id']],
            ['is_active' => true]
        );

        return response()->json($link->fresh(), $link->wasRecentlyCreated ? 201 : 200);
    }

    public function destroy(Request $request, $designerId)
    {
        $user = $request->user();
        abort_unless($user->hasRole('industor'), 403, 'Only industors can manage their designer pool.');

        IndustorDesigner::where('industor_id', $user->id)
            ->where('designer_id', $designerId)
            ->delete();

        return response()->json(['message' => 'Designer removed from your pool.']);
    }
}
