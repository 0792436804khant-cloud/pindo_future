<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ClassroomSessionResource;
use App\Models\ClassroomSession;
use Illuminate\Http\JsonResponse;

class ClassroomSessionController extends Controller
{
    /**
     * Public / attendee session lookup by Session ID.
     */
    public function lookup(string $sessionId): JsonResponse
    {
        $session = ClassroomSession::with('teacher')
            ->bySessionId($sessionId)
            ->first();

        if (! $session) {
            return response()->json([
                'status' => 'error',
                'message' => "Classroom session '{$sessionId}' was not found.",
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'session' => new ClassroomSessionResource($session),
        ]);
    }
}
