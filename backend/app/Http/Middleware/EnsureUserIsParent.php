<?php

namespace App\Http\Middleware;

use App\Models\Role;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsParent
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (! $user || ! $user->hasRole([Role::PARENT, Role::ADMIN])) {
            return response()->json([
                'status' => 'error',
                'message' => 'Access denied. Only parents and legal guardians can access guardian portal operations.',
            ], 403);
        }

        return $next($request);
    }
}
