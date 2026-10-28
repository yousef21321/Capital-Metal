<?php

namespace App\Http\Controllers;

use App\Models\Role;
use Illuminate\Http\Request;

class RoleController extends Controller
{
    public function adminIndex(Request $request)
    {
        abort_unless($request->user()->hasRole('admin'), 403);

        return response()->json(Role::orderBy('id')->get());
    }

    public function updatePermissions(Request $request, $id)
    {
        abort_unless($request->user()->hasRole('admin'), 403);

        $role = Role::findOrFail($id);

        $data = $request->validate([
            'permissions' => 'nullable|array',
            'permissions.*' => 'string|max:100',
        ]);

        $role->update([
            'permissions' => array_values(array_unique($data['permissions'] ?? [])),
        ]);

        return response()->json($role->fresh());
    }
}
