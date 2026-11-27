<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CohortChatMessage;
use App\Models\CohortMessageRead;
use App\Models\StudyCohort;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CohortChatController extends Controller
{
    /**
     * List cohort chat messages, mark incoming messages delivered+read by the
     * current user, and include full social-style delivery/read receipt telemetry.
     */
    public function index(string $cohortIdentifier, Request $request): JsonResponse
    {
        $user = $request->user();
        $cohort = $this->resolveAuthorizedCohort($cohortIdentifier, $user);

        // Mark all existing messages from other users as delivered & read by this user
        $now = now();
        $otherMessageIds = CohortChatMessage::where('cohort_id', $cohort->id)
            ->where('sender_id', '!=', $user->id)
            ->pluck('id');

        foreach ($otherMessageIds as $msgId) {
            $read = CohortMessageRead::firstOrNew([
                'message_id' => $msgId,
                'user_id' => $user->id,
            ]);
            if (! $read->delivered_at) {
                $read->delivered_at = $now;
            }
            if (! $read->read_at) {
                $read->read_at = $now;
            }
            $read->save();
        }

        // Load all active cohort members + teacher for receipt comparison
        $cohortParticipants = $this->getCohortParticipants($cohort);

        $messages = CohortChatMessage::where('cohort_id', $cohort->id)
            ->with(['sender:id,name,role', 'reads.user:id,name,role'])
            ->orderBy('created_at', 'asc')
            ->get()
            ->map(fn (CohortChatMessage $m) => $this->formatMessage($m, $cohort, $cohortParticipants, $user->id));

        return response()->json([
            'status' => 'success',
            'data' => [
                'cohort_id' => $cohort->id,
                'cohort_code' => $cohort->cohort_code,
                'cohort_name' => $cohort->name,
                'members_count' => $cohortParticipants->count(),
                'messages' => $messages,
            ],
        ]);
    }

    /**
     * Send a new message to the cohort chat room.
     */
    public function store(string $cohortIdentifier, Request $request): JsonResponse
    {
        $user = $request->user();
        $cohort = $this->resolveAuthorizedCohort($cohortIdentifier, $user);

        $validated = $request->validate([
            'text' => ['nullable', 'string', 'max:5000'],
            'message_type' => ['nullable', 'in:text,image,link,file'],
            'image_url' => ['nullable', 'string'],
            'link_url' => ['nullable', 'string', 'max:500'],
            'link_title' => ['nullable', 'string', 'max:255'],
            'file_name' => ['nullable', 'string', 'max:255'],
            'file_size_bytes' => ['nullable', 'integer'],
        ]);

        $roleStr = is_string($user->role) ? $user->role : ($user->role?->value ?? 'student');
        $msg = CohortChatMessage::create([
            'cohort_id' => $cohort->id,
            'sender_id' => $user->id,
            'sender_role' => $cohort->teacher_id === $user->id ? 'teacher' : $roleStr,
            'text' => $validated['text'] ?? '',
            'message_type' => $validated['message_type'] ?? 'text',
            'image_url' => $validated['image_url'] ?? null,
            'link_url' => $validated['link_url'] ?? null,
            'link_title' => $validated['link_title'] ?? null,
            'file_name' => $validated['file_name'] ?? null,
            'file_size_bytes' => $validated['file_size_bytes'] ?? null,
            'reactions' => [],
        ]);

        $msg->load(['sender:id,name,role', 'reads.user:id,name,role']);
        $cohortParticipants = $this->getCohortParticipants($cohort);

        return response()->json([
            'status' => 'success',
            'data' => $this->formatMessage($msg, $cohort, $cohortParticipants, $user->id),
        ], 201);
    }

    /**
     * Explicitly acknowledge delivery or read of a specific message.
     */
    public function markRead(string $cohortIdentifier, int $messageId, Request $request): JsonResponse
    {
        $user = $request->user();
        $cohort = $this->resolveAuthorizedCohort($cohortIdentifier, $user);

        $msg = CohortChatMessage::where('cohort_id', $cohort->id)->findOrFail($messageId);
        if ($msg->sender_id !== $user->id) {
            $now = now();
            $read = CohortMessageRead::firstOrNew([
                'message_id' => $msg->id,
                'user_id' => $user->id,
            ]);
            $read->delivered_at = $read->delivered_at ?? $now;
            $read->read_at = $read->read_at ?? $now;
            $read->save();
        }

        return response()->json(['status' => 'success']);
    }

    /**
     * Toggle emoji reaction on a cohort chat message.
     */
    public function toggleReaction(string $cohortIdentifier, int $messageId, Request $request): JsonResponse
    {
        $user = $request->user();
        $cohort = $this->resolveAuthorizedCohort($cohortIdentifier, $user);

        $validated = $request->validate([
            'emoji' => ['required', 'string', 'max:16'],
        ]);

        $msg = CohortChatMessage::where('cohort_id', $cohort->id)->findOrFail($messageId);
        $reactions = is_array($msg->reactions) ? $msg->reactions : [];
        $emoji = $validated['emoji'];

        if (in_array($emoji, $reactions, true)) {
            $reactions = array_values(array_diff($reactions, [$emoji]));
        } else {
            $reactions[] = $emoji;
        }

        $msg->update(['reactions' => $reactions]);

        return response()->json([
            'status' => 'success',
            'data' => ['reactions' => $reactions],
        ]);
    }

    /**
     * Toggle pin status on a message (teacher only).
     */
    public function togglePin(string $cohortIdentifier, int $messageId, Request $request): JsonResponse
    {
        $user = $request->user();
        $cohort = $this->resolveAuthorizedCohort($cohortIdentifier, $user);
        abort_unless($cohort->teacher_id === $user->id, 403);

        $msg = CohortChatMessage::where('cohort_id', $cohort->id)->findOrFail($messageId);
        $msg->update(['is_pinned' => ! $msg->is_pinned]);

        return response()->json([
            'status' => 'success',
            'data' => ['is_pinned' => $msg->is_pinned],
        ]);
    }

    private function resolveAuthorizedCohort(string $cohortIdentifier, User $user): StudyCohort
    {
        $cohort = StudyCohort::where('cohort_code', $cohortIdentifier)
            ->when(is_numeric($cohortIdentifier), fn ($q) => $q->orWhere('id', (int) $cohortIdentifier))
            ->firstOrFail();

        $isTeacher = $cohort->teacher_id === $user->id;
        $isMember = $cohort->hasStudent($user->id);
        $roleStr = is_string($user->role) ? $user->role : ($user->role?->value ?? 'student');
        $isAdmin = $roleStr === 'admin';

        abort_unless($isTeacher || $isMember || $isAdmin, 403, 'غير مصرح لك بالوصول إلى محادثة هذا الفوج.');

        return $cohort;
    }

    private function getCohortParticipants(StudyCohort $cohort)
    {
        $students = $cohort->members()
            ->where('status', 'active')
            ->with('student:id,name,role')
            ->get()
            ->map(fn ($m) => [
                'user_id' => $m->student_id,
                'name' => $m->student?->name ?? 'طالب',
                'role' => 'student',
            ]);

        $cohort->loadMissing('teacher:id,name');
        if ($cohort->teacher) {
            $students->push([
                'user_id' => $cohort->teacher->id,
                'name' => $cohort->teacher->name,
                'role' => 'teacher',
            ]);
        }

        return $students->unique('user_id')->values();
    }

    private function formatMessage(
        CohortChatMessage $m,
        StudyCohort $cohort,
        $participants,
        int $currentUserId
    ): array {
        $recipients = $participants->where('user_id', '!=', $m->sender_id)->values();
        $readsByUserId = $m->reads->keyBy('user_id');

        $readBy = [];
        $unreadBy = [];
        $deliveredCount = 0;

        foreach ($recipients as $p) {
            $rec = $readsByUserId->get($p['user_id']);
            if ($rec && $rec->read_at) {
                $deliveredCount++;
                $readBy[] = [
                    'user_id' => $p['user_id'],
                    'name' => $p['name'],
                    'role' => $p['role'],
                    'read_at' => $rec->read_at->toIso8601String(),
                ];
            } else {
                if ($rec && $rec->delivered_at) {
                    $deliveredCount++;
                }
                $unreadBy[] = [
                    'user_id' => $p['user_id'],
                    'name' => $p['name'],
                    'role' => $p['role'],
                ];
            }
        }

        $readCount = count($readBy);
        $totalRecipients = $recipients->count();

        $deliveryStatus = 'sent';
        if ($readCount > 0) {
            $deliveryStatus = 'read';
        } elseif ($deliveredCount > 0) {
            $deliveryStatus = 'delivered';
        }

        return [
            'id' => (string) $m->id,
            'cohort_id' => (string) $cohort->id,
            'cohort_code' => $cohort->cohort_code,
            'cohort_name' => $cohort->name,
            'sender_id' => (string) $m->sender_id,
            'sender_name' => $m->sender?->name ?? 'عضو',
            'sender_role' => $m->sender_role,
            'text' => $m->text ?? '',
            'message_type' => $m->message_type,
            'image_url' => $m->image_url,
            'link_url' => $m->link_url,
            'link_title' => $m->link_title,
            'file_name' => $m->file_name,
            'file_size_bytes' => $m->file_size_bytes,
            'is_pinned' => (bool) $m->is_pinned,
            'reactions' => $m->reactions ?? [],
            'timestamp' => $m->created_at?->toIso8601String(),
            'is_mine' => $m->sender_id === $currentUserId,
            'delivery_status' => $deliveryStatus,
            'delivered_count' => $deliveredCount,
            'read_count' => $readCount,
            'total_recipients' => $totalRecipients,
            'read_by' => $readBy,
            'unread_by' => $unreadBy,
        ];
    }
}
