<?php

namespace App\Http\Controllers;

use App\Models\Role;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class UserController extends Controller
{
    public function adminIndex(Request $request)
    {
        abort_unless($request->user()->hasRole('admin'), 403);

        $query = User::with('role');

        if ($request->search) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('email', 'like', "%{$search}%")
                    ->orWhere('phone', 'like', "%{$search}%");
            });
        }

        if ($request->role) {
            $query->whereHas('role', function ($q) use ($request) {
                $q->where('name', $request->role);
            });
        }

        $users = $query->latest('id')->paginate($request->per_page ?? 20);

        return response()->json($users);
    }

    public function adminStore(Request $request)
    {
        abort_unless($request->user()->hasRole('admin'), 403);

        $data = $request->validate([
            'name' => 'required|string|max:150',
            'email' => 'required|string|email|max:150|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'phone' => 'nullable|string|max:20',
            'role' => 'required|exists:roles,name',
            'is_active' => 'boolean',
            'currency_preference' => 'nullable|in:EGP,USD',
        ]);

        $role = Role::where('name', $data['role'])->first();

        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'phone' => $data['phone'] ?? null,
            'role_id' => $role->id,
            'is_active' => $data['is_active'] ?? true,
            'currency_preference' => $data['currency_preference'] ?? 'EGP',
        ]);

        return response()->json($user->load('role'), 201);
    }

    public function adminUpdate(Request $request, $id)
    {
        abort_unless($request->user()->hasRole('admin'), 403);

        $user = User::findOrFail($id);

        $data = $request->validate([
            'name' => 'sometimes|string|max:150',
            'email' => 'sometimes|string|email|max:150|unique:users,email,'.$user->id,
            'phone' => 'nullable|string|max:20',
            'role' => 'sometimes|exists:roles,name',
            'is_active' => 'boolean',
            'currency_preference' => 'nullable|in:EGP,USD',
        ]);

        if (isset($data['role'])) {
            $role = Role::where('name', $data['role'])->first();
            $data['role_id'] = $role->id;
            unset($data['role']);
        }

        $user->update($data);

        return response()->json($user->fresh('role'));
    }

    public function adminResetPassword(Request $request, $id)
    {
        abort_unless($request->user()->hasRole('admin'), 403);

        $data = $request->validate([
            'password' => 'required|string|min:8|confirmed',
        ]);

        $user = User::findOrFail($id);
        $user->update([
            'password' => Hash::make($data['password']),
            'reset_token' => null,
            'reset_token_expiry' => null,
        ]);

        $user->tokens()->delete();

        return response()->json(['message' => 'Password reset successfully.']);
    }

    public function adminImpersonate(Request $request, $id)
    {
        abort_unless($request->user()->hasRole('admin'), 403);

        $user = User::findOrFail($id);

        if (! $user->is_active) {
            return response()->json(['message' => 'Account is deactivated.'], 403);
        }

        $token = $user->createToken('impersonate-'.now()->timestamp)->plainTextToken;

        return response()->json([
            'user' => $user->load('role'),
            'token' => $token,
        ]);
    }
}
