<?php

namespace App\Http\Controllers\Api\Teacher;

use App\Http\Controllers\Api\Student\CohortLibraryController;
use App\Http\Controllers\Controller;
use App\Jobs\ProcessVideoRecordingJob;
use App\Models\ClassroomSession;
use App\Models\CohortMaterial;
use App\Models\SessionRecording;
use App\Models\StudyCohort;
use App\Services\CacheManagerService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class LibraryController extends Controller
{
    /**
     * List all recordings across the teacher's cohorts and live sessions, categorized by save method.
     */
    public function allTeacherRecordings(Request $request): JsonResponse
    {
        $teacher = $request->user();

        $recordings = SessionRecording::where('teacher_id', $teacher->id)
            ->with(['cohort:id,name,subject', 'session:id,session_id,title,scheduled_at'])
            ->orderByDesc('created_at')
            ->get()
            ->map(function (SessionRecording $rec) use ($teacher) {
                return [
                    'id' => $rec->id,
                    'recording_code' => $rec->recording_code,
                    'title' => $rec->title,
                    'description' => $rec->description,
                    'cohort_id' => $rec->cohort_id,
                    'cohort_name' => $rec->cohort?->name ?? 'جلسة مستقلة',
                    'subject' => $rec->cohort?->subject ?? 'مادة تعليمية',
                    'session_id' => $rec->session?->session_id,
                    'storage_disk' => $rec->storage_disk ?? 'public',
                    'save_mode' => $rec->save_mode ?? 'cloud_library',
                    'mime_type' => $rec->mime_type ?? 'video/webm',
                    'processing_status' => $rec->processing_status ?? 'ready',
                    'duration_seconds' => $rec->duration_seconds,
                    'file_size_bytes' => $rec->file_size_bytes,
                    'is_published' => $rec->is_published,
                    'views_count' => $rec->views_count,
                    'stream_url' => CohortLibraryController::buildSignedRecordingUrl($rec, $teacher->id),
                    'created_at' => $rec->created_at?->toIso8601String(),
                ];
            });

        return response()->json([
            'status' => 'success',
            'recordings' => $recordings,
            'storage_info' => [
                'disk' => config('filesystems.default', 'public'),
                'root_path' => config('filesystems.disks.public.root'),
                'volume_persistent' => ! empty(env('RAILWAY_VOLUME_MOUNT_PATH')),
            ],
        ]);
    }

    /**
     * Upload a live or pre-recorded session video directly to persistent storage (Railway Volume / S3).
     */
    public function uploadSessionRecording(Request $request, string $sessionId, CacheManagerService $cache): JsonResponse
    {
        $teacher = $request->user();
        $session = ClassroomSession::where('session_id', $sessionId)
            ->where('user_id', $teacher->id)
            ->first();

        $validated = $request->validate([
            'video_file' => 'required|file|mimetypes:video/webm,video/mp4,video/quicktime,video/x-matroska,video/ogg,application/octet-stream|max:524288',
            'title' => 'required|string|max:200',
            'description' => 'nullable|string',
            'cohort_id' => 'nullable|integer|exists:study_cohorts,id',
            'duration_seconds' => 'nullable|integer|min:0',
            'save_mode' => 'nullable|string|in:cloud_library,live_capture,uploaded_file,external_link',
            'is_published' => 'nullable|boolean',
        ]);

        $cohortId = $validated['cohort_id'] ?? $session?->cohort_id;
        if ($cohortId) {
            StudyCohort::where('id', $cohortId)
                ->where('teacher_id', $teacher->id)
                ->firstOrFail();
        }

        if (! $session) {
            $session = ClassroomSession::create([
                'session_id' => $sessionId,
                'user_id' => $teacher->id,
                'cohort_id' => $cohortId,
                'title' => $validated['title'],
                'status' => ClassroomSession::STATUS_ACTIVE,
                'started_at' => now(),
            ]);
        }

        $file = $request->file('video_file');
        $recordingCode = SessionRecording::generateUniqueRecordingCode();
        $ext = strtolower($file->getClientOriginalExtension() ?: 'webm');
        if (! in_array($ext, ['webm', 'mp4', 'mov', 'mkv', 'm4v', 'ogg'], true)) {
            $ext = 'webm';
        }

        $folder = 'recordings/cohort_' . ($cohortId ?? 'general') . '/' . $session->session_id;
        $storedPath = $file->storeAs($folder, "{$recordingCode}.{$ext}", 'public');

        $recording = SessionRecording::create([
            'recording_code' => $recordingCode,
            'classroom_session_id' => $session->id,
            'cohort_id' => $cohortId,
            'teacher_id' => $teacher->id,
            'title' => $validated['title'],
            'description' => $validated['description'] ?? null,
            'video_storage_path' => $storedPath,
            'storage_disk' => 'public',
            'save_mode' => $validated['save_mode'] ?? 'live_capture',
            'mime_type' => $file->getClientMimeType() ?: ($ext === 'mp4' ? 'video/mp4' : 'video/webm'),
            'processing_status' => 'ready',
            'duration_seconds' => (int) ($validated['duration_seconds'] ?? 0),
            'file_size_bytes' => $file->getSize(),
            'is_published' => $request->has('is_published') ? $request->boolean('is_published') : true,
        ]);

        $cache->invalidateTeacher($teacher->id);
        ProcessVideoRecordingJob::dispatch($recording->id);

        return response()->json([
            'status' => 'success',
            'message' => 'تم رفع وحفظ تسجيل البث في المكتبة السحابية بنجاح.',
            'recording' => $recording,
            'stream_url' => CohortLibraryController::buildSignedRecordingUrl($recording, $teacher->id),
        ], 201);
    }

    /**
     * Teacher preview stream URL for own recording.
     */
    public function streamTeacherRecording(Request $request, int $id): JsonResponse
    {
        $teacher = $request->user();
        $recording = SessionRecording::where('id', $id)
            ->where('teacher_id', $teacher->id)
            ->firstOrFail();

        return response()->json([
            'status' => 'success',
            'recording' => $recording,
            'stream_url' => CohortLibraryController::buildSignedRecordingUrl($recording, $teacher->id),
            'expires_at' => now()->addHours(3)->toIso8601String(),
        ]);
    }
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

        if (! $recording->isExternalUrl()) {
            $disk = $recording->storage_disk ?: 'public';
            if (Storage::disk($disk)->exists($recording->video_storage_path)) {
                Storage::disk($disk)->delete($recording->video_storage_path);
            }
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
