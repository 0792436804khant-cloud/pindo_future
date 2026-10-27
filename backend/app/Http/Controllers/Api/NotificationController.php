<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use App\Models\ClassroomSession;
use App\Models\Role;
use App\Services\NotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /**
     * Get user notifications with unread count.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $unreadCount = AppNotification::forUser($user->id)
            ->unread()
            ->count();

        $notifications = AppNotification::forUser($user->id)
            ->orderBy('created_at', 'desc')
            ->limit(50)
            ->get()
            ->map(function (AppNotification $n) {
                return [
                    'id' => $n->id,
                    'type' => $n->type,
                    'title' => $n->title,
                    'body' => $n->body,
                    'data' => $n->data ?? [],
                    'is_read' => !is_null($n->read_at),
                    'read_at' => $n->read_at?->toIso8601String(),
                    'created_at' => $n->created_at->toIso8601String(),
                    'time_ago' => $n->created_at->diffForHumans(),
                ];
            });

        return response()->json([
            'status' => 'success',
            'unread_count' => $unreadCount,
            'total_count' => $notifications->count(),
            'data' => $notifications,
        ]);
    }

    /**
     * Mark a single notification as read.
     */
    public function markAsRead(Request $request, int $id): JsonResponse
    {
        $user = $request->user();

        $notification = AppNotification::where('id', $id)
            ->where('user_id', $user->id)
            ->firstOrFail();

        $notification->markAsRead();

        return response()->json([
            'status' => 'success',
            'message' => 'Notification marked as read.',
            'id' => $notification->id,
            'read_at' => $notification->read_at?->toIso8601String(),
        ]);
    }

    /**
     * Mark all notifications as read for current user.
     */
    public function markAllAsRead(Request $request): JsonResponse
    {
        $user = $request->user();

        $updatedCount = AppNotification::forUser($user->id)
            ->unread()
            ->update(['read_at' => now()]);

        return response()->json([
            'status' => 'success',
            'message' => 'All notifications marked as read.',
            'updated_count' => $updatedCount,
        ]);
    }

    /**
     * Broadcast a live classroom alert to all cohort/course students.
     */
    public function broadcastSessionLive(
        Request $request,
        string $sessionId,
        NotificationService $notificationService
    ): JsonResponse {
        $user = $request->user();

        $session = ClassroomSession::where('session_id', $sessionId)->firstOrFail();

        // Ensure only host teacher or admin can broadcast
        if ($session->user_id !== $user->id && !$user->hasRole(Role::ADMIN)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Unauthorized. Only the session host teacher can trigger live alerts.',
            ], 403);
        }

        $notifiedCount = $notificationService->notifySessionLive($session);

        return response()->json([
            'status' => 'success',
            'message' => "Live alerts broadcasted to {$notifiedCount} recipients.",
            'session_id' => $session->session_id,
            'recipients_count' => $notifiedCount,
        ]);
    }
}
