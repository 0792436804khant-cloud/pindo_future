<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Models\CohortMaterial;
use App\Models\CohortMember;
use App\Models\SessionRecording;
use App\Models\StudyCohort;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\URL;

class CohortLibraryController extends Controller
{
    /**
     * View cohort educational library (recordings, summaries, exercises).
     */
    public function index(Request $request, int $cohortId): JsonResponse
    {
        $student = $request->user();
        $cohort = StudyCohort::with('teacher:id,name,teacher_id,is_verified,verification_status')
            ->where('id', $cohortId)
            ->first();

        if (! $cohort) {
            return response()->json([
                'status' => 'error',
                'message' => 'Study cohort not found.',
            ], 404);
        }

        $isSubscribed = CohortMember::where('cohort_id', $cohort->id)
            ->where('student_id', $student->id)
            ->where('status', 'active')
            ->exists();

        $recordings = SessionRecording::where('cohort_id', $cohort->id)
            ->published()
            ->orderByDesc('created_at')
            ->get()
            ->map(function (SessionRecording $rec) use ($isSubscribed) {
                return [
                    'id' => $rec->id,
                    'recording_code' => $rec->recording_code,
                    'title' => $rec->title,
                    'description' => $rec->description,
                    'duration_seconds' => $rec->duration_seconds,
                    'views_count' => $rec->views_count,
                    'created_at' => $rec->created_at->toIso8601String(),
                    'is_accessible' => $isSubscribed,
                ];
            });

        $materials = CohortMaterial::where('cohort_id', $cohort->id)
            ->published()
            ->orderByDesc('created_at')
            ->get()
            ->map(function (CohortMaterial $mat) use ($isSubscribed) {
                return [
                    'id' => $mat->id,
                    'material_code' => $mat->material_code,
                    'title' => $mat->title,
                    'description' => $mat->description,
                    'file_type' => $mat->file_type,
                    'file_size_bytes' => $mat->file_size_bytes,
                    'downloads_count' => $mat->downloads_count,
                    'created_at' => $mat->created_at->toIso8601String(),
                    'is_accessible' => $isSubscribed,
                ];
            });

        return response()->json([
            'status' => 'success',
            'cohort' => [
                'id' => $cohort->id,
                'name' => $cohort->name,
                'subject' => $cohort->subject,
                'academic_level' => $cohort->academic_level,
                'stream' => $cohort->stream,
                'teacher' => $cohort->teacher,
            ],
            'is_subscribed' => $isSubscribed,
            'requires_subscription' => ! $isSubscribed,
            'recordings_count' => $recordings->count(),
            'materials_count' => $materials->count(),
            'recordings' => $recordings,
            'materials' => $materials,
        ]);
    }

    /**
     * Request secure signed streaming URL for a recorded lecture.
     */
    public function streamRecording(Request $request, int $recordingId): JsonResponse
    {
        $student = $request->user();
        $recording = SessionRecording::with('cohort')->where('id', $recordingId)->first();

        if (! $recording) {
            return response()->json([
                'status' => 'error',
                'message' => 'Recording not found.',
            ], 404);
        }

        // Authorization check: active cohort membership required
        $isSubscribed = CohortMember::where('cohort_id', $recording->cohort_id)
            ->where('student_id', $student->id)
            ->where('status', 'active')
            ->exists();

        if (! $isSubscribed) {
            return response()->json([
                'status' => 'error',
                'message' => 'Active cohort subscription required to access this recorded lecture.',
                'requires_subscription' => true,
                'cohort_id' => $recording->cohort_id,
            ], 403);
        }

        $recording->increment('views_count');

        $watermarkText = $student->guardian_link_code
            ? "{$student->name} • {$student->guardian_link_code}"
            : "{$student->name} • {$student->email}";

        // Simulated signed streaming URL token with 3-hour expiry
        $signedStreamUrl = "https://stream.pindofuture.com/secure-hls/{$recording->recording_code}/master.m3u8?token="
            . hash_hmac('sha256', "{$recording->id}:{$student->id}:" . now()->addHours(3)->timestamp, config('app.key'));

        return response()->json([
            'status' => 'success',
            'recording' => [
                'id' => $recording->id,
                'recording_code' => $recording->recording_code,
                'title' => $recording->title,
                'description' => $recording->description,
                'duration_seconds' => $recording->duration_seconds,
            ],
            'stream_url' => $signedStreamUrl,
            'expires_at' => now()->addHours(3)->toIso8601String(),
            'watermark' => [
                'watermark_text' => $watermarkText,
                'student_name' => $student->name,
                'student_id' => $student->id,
                'guardian_link_code' => $student->guardian_link_code,
            ],
        ]);
    }

    /**
     * Request access or download for educational material (PDF, Summary, Exercise).
     */
    public function downloadMaterial(Request $request, int $materialId): JsonResponse
    {
        $student = $request->user();
        $material = CohortMaterial::where('id', $materialId)->first();

        if (! $material) {
            return response()->json([
                'status' => 'error',
                'message' => 'Educational material not found.',
            ], 404);
        }

        // Authorization check: active cohort membership required
        $isSubscribed = CohortMember::where('cohort_id', $material->cohort_id)
            ->where('student_id', $student->id)
            ->where('status', 'active')
            ->exists();

        if (! $isSubscribed) {
            return response()->json([
                'status' => 'error',
                'message' => 'Active cohort subscription required to access this educational material.',
                'requires_subscription' => true,
                'cohort_id' => $material->cohort_id,
            ], 403);
        }

        $material->increment('downloads_count');

        $signedDownloadUrl = "https://cdn.pindofuture.com/materials/{$material->material_code}/download?token="
            . hash_hmac('sha256', "{$material->id}:{$student->id}:" . now()->addHours(2)->timestamp, config('app.key'));

        return response()->json([
            'status' => 'success',
            'material' => [
                'id' => $material->id,
                'material_code' => $material->material_code,
                'title' => $material->title,
                'file_type' => $material->file_type,
                'file_size_bytes' => $material->file_size_bytes,
            ],
            'download_url' => $signedDownloadUrl,
            'expires_at' => now()->addHours(2)->toIso8601String(),
        ]);
    }
}
