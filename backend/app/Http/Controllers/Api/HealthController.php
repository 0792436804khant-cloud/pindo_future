<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Throwable;

class HealthController extends Controller
{
    /**
     * Return application health and database connection status.
     */
    public function check(): JsonResponse
    {
        $dbConnected = false;
        $dbDriver = config('database.default');
        $dbError = null;

        try {
            DB::connection()->getPdo();
            $dbConnected = true;
        } catch (Throwable $e) {
            $dbError = $e->getMessage();
        }

        return response()->json([
            'status' => 'success',
            'platform' => 'Pindo Future Educational Platform',
            'api_version' => 'v1.0.0-foundation',
            'timestamp' => now()->toIso8601String(),
            'services' => [
                'api' => 'operational',
                'database' => [
                    'driver' => $dbDriver,
                    'connected' => $dbConnected,
                    'error' => $dbError,
                ],
            ],
            'architecture' => [
                'session_model' => 'dynamic_session_id',
                'target_capacity' => '30,000 concurrent users',
                'sfu_infrastructure' => 'external_webrtc_delegated',
            ]
        ], $dbConnected ? 200 : 200); // Return 200 so mobile app can inspect payload during foundation test
    }
}
