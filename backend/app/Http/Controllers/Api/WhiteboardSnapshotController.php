<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ClassroomSession;
use App\Models\ClassroomWhiteboardSnapshot;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WhiteboardSnapshotController extends Controller
{
    /**
     * Get the latest active whiteboard vector state for a classroom session.
     */
    public function getLatest(string $sessionId): JsonResponse
    {
        $snapshot = ClassroomWhiteboardSnapshot::where('session_id', $sessionId)
            ->with('author:id,name,role')
            ->orderBy('version', 'desc')
            ->first();

        if (!$snapshot) {
            return response()->json([
                'status' => 'success',
                'session_id' => $sessionId,
                'has_snapshot' => false,
                'snapshot' => null,
            ]);
        }

        return response()->json([
            'status' => 'success',
            'session_id' => $sessionId,
            'has_snapshot' => true,
            'snapshot' => [
                'id' => $snapshot->id,
                'snapshot_title' => $snapshot->snapshot_title,
                'version' => $snapshot->version,
                'stroke_count' => $snapshot->stroke_count,
                'vector_data' => $snapshot->vector_data,
                'thumbnail_url' => $snapshot->thumbnail_url,
                'author' => [
                    'id' => $snapshot->author?->id,
                    'name' => $snapshot->author?->name,
                    'role' => $snapshot->author?->role,
                ],
                'created_at' => $snapshot->created_at->toIso8601String(),
                'updated_at' => $snapshot->updated_at->toIso8601String(),
            ],
        ]);
    }

    /**
     * Save/Publish a vector snapshot of the whiteboard state.
     */
    public function store(Request $request, string $sessionId): JsonResponse
    {
        $validated = $request->validate([
            'vector_data' => 'required|array',
            'snapshot_title' => 'nullable|string|max:150',
            'stroke_count' => 'nullable|integer|min:0',
            'thumbnail_url' => 'nullable|string|max:500',
        ]);

        $classroomSession = ClassroomSession::where('session_id', $sessionId)->first();
        $user = $request->user();

        $latestVersion = (int) ClassroomWhiteboardSnapshot::where('session_id', $sessionId)->max('version');
        $newVersion = $latestVersion + 1;

        $vectorData = $validated['vector_data'];
        $strokeCount = $validated['stroke_count'] ?? count($vectorData);
        $title = $validated['snapshot_title'] ?? ("Whiteboard Lecture Notes v{$newVersion}");

        $snapshot = ClassroomWhiteboardSnapshot::create([
            'session_id' => $sessionId,
            'classroom_session_id' => $classroomSession?->id,
            'author_id' => $user->id,
            'snapshot_title' => $title,
            'vector_data' => $vectorData,
            'stroke_count' => $strokeCount,
            'version' => $newVersion,
            'thumbnail_url' => $validated['thumbnail_url'] ?? null,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Whiteboard snapshot saved successfully.',
            'snapshot' => [
                'id' => $snapshot->id,
                'snapshot_title' => $snapshot->snapshot_title,
                'version' => $snapshot->version,
                'stroke_count' => $snapshot->stroke_count,
                'author_name' => $user->name,
                'created_at' => $snapshot->created_at->toIso8601String(),
            ],
        ], 201);
    }

    /**
     * Get snapshot revision history for lecture slide navigation.
     */
    public function history(string $sessionId): JsonResponse
    {
        $snapshots = ClassroomWhiteboardSnapshot::where('session_id', $sessionId)
            ->with('author:id,name')
            ->orderBy('version', 'desc')
            ->limit(20)
            ->get()
            ->map(function (ClassroomWhiteboardSnapshot $s) {
                return [
                    'id' => $s->id,
                    'snapshot_title' => $s->snapshot_title,
                    'version' => $s->version,
                    'stroke_count' => $s->stroke_count,
                    'author_name' => $s->author?->name ?? 'Instructor',
                    'created_at' => $s->created_at->toIso8601String(),
                ];
            });

        return response()->json([
            'status' => 'success',
            'session_id' => $sessionId,
            'snapshots' => $snapshots,
        ]);
    }
}
