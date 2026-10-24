<?php

namespace App\Http\Middleware;

use App\Models\Role;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsAdmin
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (! $user || ! $user->hasRole(Role::ADMIN)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Access denied. Administrator privileges required.',
            ], 403);
        }

        return $next($request);
    }
}
