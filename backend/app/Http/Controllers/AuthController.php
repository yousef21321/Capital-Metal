<?php

namespace App\Http\Controllers;

use App\Models\Cart;
use App\Models\Role;
use App\Models\User;
use App\Services\ImageOptimizer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:150',
            'email' => 'required|string|email|max:150|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'phone' => 'nullable|string|max:20',
            'currency_preference' => 'nullable|in:EGP,USD',
        ]);

        $userRole = Role::where('name', 'user')->first();

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => $request->password,
            'role_id' => $userRole?->id,
            'phone' => $request->phone,
            'currency_preference' => $request->currency_preference ?? 'EGP',
        ]);

        $this->mergeGuestCart($request, $user);

        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'user' => $user->load('role'),
            'token' => $token,
        ], 201);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|string|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        if (! $user->is_active) {
            return response()->json(['message' => 'Account is deactivated.'], 403);
        }

        $token = $user->createToken('auth-token')->plainTextToken;

        $this->mergeGuestCart($request, $user);

        return response()->json([
            'user' => $user->load('role'),
            'token' => $token,
        ]);
    }

    public function googleLogin(Request $request)
    {
        $request->validate([
            'credential' => 'required|string',
        ]);

        $allowedClients = array_filter(array_map('trim', explode(',', config('services.google.client_id'))));
        $tokenInfo = null;

        foreach ($allowedClients as $clientId) {
            $url = 'https://oauth2.googleapis.com/tokeninfo?id_token='.$request->credential;
            $response = @file_get_contents($url);
            if ($response !== false) {
                $tokenInfo = json_decode($response, true);
                if (isset($tokenInfo['aud']) && $tokenInfo['aud'] === $clientId) {
                    break;
                }
                $tokenInfo = null;
            }
        }

        if (! $tokenInfo || ! isset($tokenInfo['email'])) {
            throw ValidationException::withMessages([
                'credential' => ['Invalid Google credential.'],
            ]);
        }

        $email = $tokenInfo['email'];
        $googleId = $tokenInfo['sub'];
        $name = $tokenInfo['name'] ?? $email;
        $avatar = $tokenInfo['picture'] ?? null;

        $user = User::where('email', $email)->first();

        if (! $user) {
            $userRole = Role::where('name', 'user')->first();
            $user = User::create([
                'name' => $name,
                'email' => $email,
                'password' => Str::random(32),
                'role_id' => $userRole?->id,
                'google_id' => $googleId,
                'avatar' => $avatar,
                'provider' => 'google',
            ]);
        } elseif (! $user->google_id) {
            $user->update([
                'google_id' => $googleId,
                'avatar' => $avatar,
                'provider' => 'google',
            ]);
        }

        if (! $user->is_active) {
            return response()->json(['message' => 'Account is deactivated.'], 403);
        }

        $token = $user->createToken('auth-token')->plainTextToken;

        $this->mergeGuestCart($request, $user);

        return response()->json([
            'user' => $user->load('role'),
            'token' => $token,
        ]);
    }

    protected function mergeGuestCart(Request $request, User $user): void
    {
        $guestToken = $request->header('X-Guest-Token');

        if (! $guestToken) {
            return;
        }

        $guestCart = Cart::where('guest_token', $guestToken)->first();

        if (! $guestCart || $guestCart->items->isEmpty()) {
            return;
        }

        $userCart = Cart::firstOrCreate(['user_id' => $user->id]);

        foreach ($guestCart->items as $item) {
            $existing = $userCart->items()
                ->where('product_id', $item->product_id)
                ->where('license_type', $item->license_type)
                ->first();

            if ($existing) {
                $existing->increment('quantity', $item->quantity);
            } else {
                $userCart->items()->create([
                    'product_id' => $item->product_id,
                    'quantity' => $item->quantity,
                    'license_type' => $item->license_type,
                ]);
            }
        }

        $guestCart->items()->delete();
        $guestCart->delete();
    }

    public function me(Request $request)
    {
        return response()->json($request->user()->load('role'));
    }

    public function updateCurrency(Request $request)
    {
        $request->validate([
            'currency_preference' => 'required|in:EGP,USD',
        ]);

        $user = $request->user();
        $user->currency_preference = $request->currency_preference;
        $user->save();

        return response()->json($user->load('role'));
    }

    public function updateProfile(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:150',
            'avatar' => 'nullable|file|mimes:jpg,jpeg,png,webp,gif|max:2048',
        ]);

        $user = $request->user();
        $user->name = $request->name;

        if ($request->hasFile('avatar')) {
            $optimizer = new ImageOptimizer(400, 400, 85);
            $oldAvatar = $user->avatar;
            $user->avatar = $optimizer->optimizeUploadedFile($request->file('avatar'), 'avatars');
            if ($oldAvatar && Storage::disk('public')->exists($oldAvatar)) {
                Storage::disk('public')->delete($oldAvatar);
            }
        }

        $user->save();

        return response()->json($user->load('role'));
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logged out successfully.']);
    }
}
