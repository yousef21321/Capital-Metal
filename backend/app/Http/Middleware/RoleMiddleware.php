<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RoleMiddleware
{
    public function handle(Request $request, Closure $next, ...$roles): Response
    {
        $user = $request->user();

        if (! $user || ! $user->role) {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        if ($user->role->name === 'admin') {
            return $next($request);
        }

        if (! in_array($user->role->name, $roles)) {
            return response()->json(['message' => 'Forbidden: insufficient permissions.'], 403);
        }

        return $next($request);
    }
}
