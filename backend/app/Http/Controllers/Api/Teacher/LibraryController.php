<?php

namespace App\Http\Controllers\Api\Teacher;

use App\Http\Controllers\Controller;
use App\Models\CohortMaterial;
use App\Models\SessionRecording;
use App\Models\StudyCohort;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LibraryController extends Controller
{
    /**
     * List all recordings for a specific cohort.
     */
    public function getRecordings(Request $request, int $cohortId): JsonResponse
    {
        $cohort = StudyCohort::where('id', $cohortId)
            ->where('teacher_id', $request->user()->id)
            ->first();

        if (! $cohort) {
            return response()->json([
                'status' => 'error',
                'message' => 'Cohort not found or unauthorized.',
            ], 404);
        }

        $recordings = SessionRecording::where('cohort_id', $cohort->id)
            ->with('session:id,session_id,title,scheduled_at,started_at,ended_at')
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'status' => 'success',
            'cohort_id' => $cohort->id,
            'recordings' => $recordings,
        ]);
    }

    /**
     * Publish or attach a session recording to a cohort.
     */
    public function publishRecording(Request $request, int $cohortId): JsonResponse
    {
        $cohort = StudyCohort::where('id', $cohortId)
            ->where('teacher_id', $request->user()->id)
            ->first();

        if (! $cohort) {
            return response()->json([
                'status' => 'error',
                'message' => 'Cohort not found or unauthorized.',
            ], 404);
        }

        $validated = $request->validate([
            'classroom_session_id' => 'required|exists:classroom_sessions,id',
            'title' => 'required|string|max:200',
            'description' => 'nullable|string',
            'video_storage_path' => 'required|string|max:500',
            'duration_seconds' => 'nullable|integer|min:0',
            'file_size_bytes' => 'nullable|integer|min:0',
            'is_published' => 'nullable|boolean',
        ]);

        $recording = SessionRecording::create([
            'classroom_session_id' => $validated['classroom_session_id'],
            'cohort_id' => $cohort->id,
            'teacher_id' => $request->user()->id,
            'title' => $validated['title'],
            'description' => $validated['description'] ?? null,
            'video_storage_path' => $validated['video_storage_path'],
            'duration_seconds' => $validated['duration_seconds'] ?? 0,
            'file_size_bytes' => $validated['file_size_bytes'] ?? null,
            'is_published' => $validated['is_published'] ?? true,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Session recording published to cohort library.',
            'recording' => $recording,
        ], 201);
    }

    /**
     * Delete a session recording.
     */
    public function deleteRecording(Request $request, int $id): JsonResponse
    {
        $recording = SessionRecording::where('id', $id)
            ->where('teacher_id', $request->user()->id)
            ->first();

        if (! $recording) {
            return response()->json([
                'status' => 'error',
                'message' => 'Recording not found or unauthorized.',
            ], 404);
        }

        $recording->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Recording removed from library.',
        ]);
    }

    /**
     * List all educational materials for a cohort.
     */
    public function getMaterials(Request $request, int $cohortId): JsonResponse
    {
        $cohort = StudyCohort::where('id', $cohortId)
            ->where('teacher_id', $request->user()->id)
            ->first();

        if (! $cohort) {
            return response()->json([
                'status' => 'error',
                'message' => 'Cohort not found or unauthorized.',
            ], 404);
        }

        $materials = CohortMaterial::where('cohort_id', $cohort->id)
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'status' => 'success',
            'cohort_id' => $cohort->id,
            'materials' => $materials,
        ]);
    }

    /**
     * Upload or publish new educational material (PDF, Summary, Exercise).
     */
    public function storeMaterial(Request $request, int $cohortId): JsonResponse
    {
        $cohort = StudyCohort::where('id', $cohortId)
            ->where('teacher_id', $request->user()->id)
            ->first();

        if (! $cohort) {
            return response()->json([
                'status' => 'error',
                'message' => 'Cohort not found or unauthorized.',
            ], 404);
        }

        $validated = $request->validate([
            'title' => 'required|string|max:200',
            'description' => 'nullable|string',
            'file_path' => 'required|string|max:500',
            'file_type' => 'nullable|string|in:pdf,summary,exercise,exam',
            'file_size_bytes' => 'nullable|integer|min:0',
            'is_published' => 'nullable|boolean',
        ]);

        $material = CohortMaterial::create([
            'cohort_id' => $cohort->id,
            'teacher_id' => $request->user()->id,
            'title' => $validated['title'],
            'description' => $validated['description'] ?? null,
            'file_path' => $validated['file_path'],
            'file_type' => $validated['file_type'] ?? 'pdf',
            'file_size_bytes' => $validated['file_size_bytes'] ?? 0,
            'is_published' => $validated['is_published'] ?? true,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Educational material uploaded to cohort library.',
            'material' => $material,
        ], 201);
    }

    /**
     * Delete educational material.
     */
    public function deleteMaterial(Request $request, int $id): JsonResponse
    {
        $material = CohortMaterial::where('id', $id)
            ->where('teacher_id', $request->user()->id)
            ->first();

        if (! $material) {
            return response()->json([
                'status' => 'error',
                'message' => 'Material not found or unauthorized.',
            ], 404);
        }

        $material->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Material removed from library.',
        ]);
    }
}
