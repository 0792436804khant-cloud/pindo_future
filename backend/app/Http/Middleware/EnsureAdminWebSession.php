<?php

namespace App\Http\Middleware;

use App\Models\Role;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class EnsureAdminWebSession
{
    /**
     * Protect Web Admin Operations Portal and Telemetry API endpoints.
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (!Auth::check() || Auth::user()->role !== Role::ADMIN) {
            if ($request->expectsJson() || $request->is('admin/api/*')) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'غير مصرح بالدخول. يجب تسجيل الدخول كمدير منصة.',
                ], 401);
            }

            return redirect()->route('admin.login');
        }

        return $next($request);
    }
}
