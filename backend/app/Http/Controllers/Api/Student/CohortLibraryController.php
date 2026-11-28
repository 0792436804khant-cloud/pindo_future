<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Models\CohortMaterial;
use App\Models\CohortMember;
use App\Models\SessionRecording;
use App\Models\StudyCohort;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\URL;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Symfony\Component\HttpFoundation\Response;

class CohortLibraryController extends Controller
{
    public static function buildSignedRecordingUrl(SessionRecording $recording, int $userId, int $hours = 3): string
    {
        if ($recording->isExternalUrl()) {
            return $recording->video_storage_path;
        }

        $expires = now()->addHours($hours)->timestamp;
        $sig = hash_hmac(
            'sha256',
            "{$recording->recording_code}:{$userId}:{$expires}",
            config('app.key')
        );

        return url("/api/v1/media/recordings/{$recording->recording_code}/stream?uid={$userId}&expires={$expires}&sig={$sig}");
    }
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

        $signedStreamUrl = self::buildSignedRecordingUrl($recording, $student->id, 3);

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

    /**
     * Serve actual recorded video file with HMAC signature check & HTTP 206 Byte-Range streaming support.
     */
    public function serveSignedStream(Request $request, string $recordingCode): Response
    {
        $uid = (int) $request->query('uid', 0);
        $expires = (int) $request->query('expires', 0);
        $sig = (string) $request->query('sig', '');

        if ($uid <= 0 || $expires < now()->timestamp || $sig === '') {
            abort(403, 'رابط البث منتهي الصلاحية أو غير صالح.');
        }

        $expectedSig = hash_hmac('sha256', "{$recordingCode}:{$uid}:{$expires}", config('app.key'));
        if (! hash_equals($expectedSig, $sig)) {
            abort(403, 'توقيع الحماية غير مطابق.');
        }

        $recording = SessionRecording::where('recording_code', $recordingCode)->firstOrFail();
        $disk = $recording->storage_disk ?: 'public';

        if ($recording->isExternalUrl()) {
            return redirect()->away($recording->video_storage_path);
        }

        if (! Storage::disk($disk)->exists($recording->video_storage_path)) {
            abort(404, 'ملف الفيديو المسجل غير موجود في وحدة التخزين.');
        }

        $fullPath = Storage::disk($disk)->path($recording->video_storage_path);
        $fileSize = filesize($fullPath);
        $mimeType = $recording->mime_type ?: 'video/webm';

        $start = 0;
        $end = $fileSize - 1;
        $statusCode = 200;
        $headers = [
            'Content-Type' => $mimeType,
            'Accept-Ranges' => 'bytes',
            'Cache-Control' => 'private, no-store, max-age=0',
            'X-Content-Type-Options' => 'nosniff',
        ];

        $rangeHeader = $request->header('Range');
        if ($rangeHeader && preg_match('/bytes=(\d+)-(\d*)/', $rangeHeader, $matches)) {
            $start = (int) $matches[1];
            if (! empty($matches[2])) {
                $end = min((int) $matches[2], $fileSize - 1);
            }
            if ($start > $end || $start >= $fileSize) {
                return response('', 416, ['Content-Range' => "bytes */{$fileSize}"]);
            }
            $statusCode = 206;
            $headers['Content-Range'] = "bytes {$start}-{$end}/{$fileSize}";
        }

        $length = ($end - $start) + 1;
        $headers['Content-Length'] = $length;

        return response()->stream(function () use ($fullPath, $start, $length) {
            $stream = fopen($fullPath, 'rb');
            if ($stream === false) {
                return;
            }
            fseek($stream, $start);
            $remaining = $length;
            while ($remaining > 0 && ! feof($stream)) {
                $chunk = fread($stream, min(1024 * 64, $remaining));
                if ($chunk === false) {
                    break;
                }
                echo $chunk;
                $remaining -= strlen($chunk);
                if (ob_get_level() > 0) {
                    ob_flush();
                }
                flush();
            }
            fclose($stream);
        }, $statusCode, $headers);
    }
}
