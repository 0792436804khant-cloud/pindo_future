<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ClassroomAttendance;
use App\Models\ClassroomMessage;
use App\Models\ClassroomSession;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ClassroomInteractionController extends Controller
{
    /**
     * Retrieve messages for a given session.
     */
    public function getMessages(string $sessionId): JsonResponse
    {
        $session = ClassroomSession::where('session_id', $sessionId)->first();

        if (!$session) {
            return response()->json([
                'status' => 'error',
                'message' => 'Classroom session not found.',
            ], 404);
        }

        $messages = ClassroomMessage::with('user:id,name,role,teacher_id')
            ->where('session_id', $sessionId)
            ->orderBy('created_at', 'asc')
            ->limit(100)
            ->get()
            ->map(function ($msg) {
                return [
                    'id' => $msg->id,
                    'session_id' => $msg->session_id,
                    'user_id' => $msg->user_id,
                    'sender_name' => $msg->user->name ?? 'Participant',
                    'sender_role' => $msg->user->role ?? 'student',
                    'message' => $msg->message,
                    'is_pinned' => $msg->is_pinned,
                    'created_at' => $msg->created_at->toIso8601String(),
                ];
            });

        return response()->json([
            'status' => 'success',
            'session_id' => $sessionId,
            'count' => $messages->count(),
            'messages' => $messages,
        ]);
    }

    /**
     * Store a message in the session.
     */
    public function sendMessage(Request $request, string $sessionId): JsonResponse
    {
        $validated = $request->validate([
            'message' => ['required', 'string', 'max:2000'],
            'is_pinned' => ['nullable', 'boolean'],
        ]);

        $session = ClassroomSession::where('session_id', $sessionId)->first();

        if (!$session) {
            return response()->json([
                'status' => 'error',
                'message' => 'Classroom session not found.',
            ], 404);
        }

        if ($session->isEnded()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Cannot post messages to an ended classroom session.',
            ], 403);
        }

        $user = Auth::user();
        $isHostOrAdmin = ($user->id === $session->user_id || $user->hasRole(\App\Models\Role::ADMIN));
        $isPinned = $isHostOrAdmin ? ($validated['is_pinned'] ?? false) : false;

        $message = ClassroomMessage::create([
            'session_id' => $session->session_id,
            'user_id' => $user->id,
            'message' => $validated['message'],
            'is_pinned' => $isPinned,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Message broadcast successfully.',
            'data' => [
                'id' => $message->id,
                'session_id' => $message->session_id,
                'user_id' => $user->id,
                'sender_name' => $user->name,
                'sender_role' => $user->role,
                'message' => $message->message,
                'is_pinned' => $message->is_pinned,
                'created_at' => $message->created_at->toIso8601String(),
            ],
        ], 201);
    }

    /**
     * Record attendee entry into the live classroom.
     */
    public function recordJoin(string $sessionId): JsonResponse
    {
        $session = ClassroomSession::where('session_id', $sessionId)->first();

        if (!$session) {
            return response()->json([
                'status' => 'error',
                'message' => 'Classroom session not found.',
            ], 404);
        }

        $user = Auth::user();

        $attendance = ClassroomAttendance::create([
            'session_id' => $session->session_id,
            'user_id' => $user->id,
            'role' => $user->role ?? 'student',
            'joined_at' => now(),
        ]);

        $activeAttendeesCount = ClassroomAttendance::where('session_id', $session->session_id)
            ->whereNull('left_at')
            ->count();

        return response()->json([
            'status' => 'success',
            'message' => 'Attendance entry recorded.',
            'attendance_id' => $attendance->id,
            'active_attendees' => $activeAttendeesCount,
        ]);
    }

    /**
     * Record attendee exit from the live classroom.
     */
    public function recordLeave(string $sessionId): JsonResponse
    {
        $session = ClassroomSession::where('session_id', $sessionId)->first();

        if (!$session) {
            return response()->json([
                'status' => 'error',
                'message' => 'Classroom session not found.',
            ], 404);
        }

        $user = Auth::user();

        $attendance = ClassroomAttendance::where('session_id', $session->session_id)
            ->where('user_id', $user->id)
            ->whereNull('left_at')
            ->latest()
            ->first();

        if ($attendance) {
            $duration = now()->diffInSeconds($attendance->joined_at);
            $attendance->update([
                'left_at' => now(),
                'duration_seconds' => $duration,
            ]);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Attendance departure recorded.',
        ]);
    }
}
