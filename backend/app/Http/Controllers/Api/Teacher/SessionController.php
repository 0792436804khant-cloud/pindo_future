<?php

namespace App\Http\Controllers\Api\Teacher;

use App\Http\Controllers\Controller;
use App\Http\Requests\Teacher\CreateSessionRequest;
use App\Http\Resources\ClassroomSessionResource;
use App\Models\ClassroomSession;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SessionController extends Controller
{
    /**
     * List all classroom sessions for the authenticated teacher.
     */
    public function index(Request $request): JsonResponse
    {
        $status = $request->query('status');

        $sessions = $request->user()->classroomSessions()
            ->when($status, fn ($q) => $q->where('status', $status))
            ->orderByDesc('created_at')
            ->paginate($request->query('per_page', 15));

        return response()->json([
            'status' => 'success',
            'data' => ClassroomSessionResource::collection($sessions),
            'meta' => [
                'current_page' => $sessions->currentPage(),
                'last_page' => $sessions->lastPage(),
                'total' => $sessions->total(),
            ],
        ]);
    }

    /**
     * Create a new dynamic classroom session bound to a Session ID.
     */
    public function store(CreateSessionRequest $request): JsonResponse
    {
        $validated = $request->validated();
        $teacher = $request->user();

        $session = $teacher->classroomSessions()->create([
            'title' => $validated['title'],
            'description' => $validated['description'] ?? null,
            'status' => ClassroomSession::STATUS_SCHEDULED,
            'max_participants' => $validated['max_participants'] ?? 30000,
            'settings' => $validated['settings'] ?? [
                'allow_chat' => true,
                'mute_on_entry' => true,
                'recording_enabled' => false,
            ],
            'scheduled_at' => $validated['scheduled_at'] ?? now(),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Classroom session created successfully.',
            'session' => new ClassroomSessionResource($session->load('teacher')),
        ], 201);
    }

    /**
     * View a specific session.
     */
    public function show(Request $request, string $sessionId): JsonResponse
    {
        $session = $request->user()->classroomSessions()
            ->bySessionId($sessionId)
            ->first();

        if (! $session) {
            return response()->json([
                'status' => 'error',
                'message' => "Session '{$sessionId}' was not found or does not belong to your account.",
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'session' => new ClassroomSessionResource($session->load('teacher')),
        ]);
    }

    /**
     * Transition session to active (live).
     */
    public function start(Request $request, string $sessionId): JsonResponse
    {
        $session = $request->user()->classroomSessions()
            ->bySessionId($sessionId)
            ->first();

        if (! $session) {
            return response()->json([
                'status' => 'error',
                'message' => "Session '{$sessionId}' not found.",
            ], 404);
        }

        if ($session->isEnded()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Cannot restart a classroom session that has already ended.',
            ], 422);
        }

        $session->start();

        return response()->json([
            'status' => 'success',
            'message' => "Classroom session '{$sessionId}' is now LIVE.",
            'session' => new ClassroomSessionResource($session->fresh()->load('teacher')),
        ]);
    }

    /**
     * End an active classroom session.
     */
    public function end(Request $request, string $sessionId): JsonResponse
    {
        $session = $request->user()->classroomSessions()
            ->bySessionId($sessionId)
            ->first();

        if (! $session) {
            return response()->json([
                'status' => 'error',
                'message' => "Session '{$sessionId}' not found.",
            ], 404);
        }

        if ($session->isEnded()) {
            return response()->json([
                'status' => 'notice',
                'message' => 'Session has already been marked as ended.',
                'session' => new ClassroomSessionResource($session),
            ]);
        }

        $session->end();

        return response()->json([
            'status' => 'success',
            'message' => "Classroom session '{$sessionId}' has been ended.",
            'session' => new ClassroomSessionResource($session->fresh()->load('teacher')),
        ]);
    }
}
