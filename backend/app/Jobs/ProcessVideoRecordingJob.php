<?php

namespace App\Jobs;

use App\Models\AppNotification;
use App\Models\CohortMember;
use App\Models\SessionRecording;
use App\Services\CacheManagerService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

class ProcessVideoRecordingJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 2;
    public int $timeout = 300;

    public int $recordingId;

    /**
     * Create a new job instance.
     */
    public function __construct(int $recordingId)
    {
        $this->recordingId = $recordingId;
        $this->onQueue('media-processing');
    }

    /**
     * Verify recording storage integrity, mark ready, invalidate caches, and notify students.
     */
    public function handle(CacheManagerService $cache): void
    {
        Log::info("ProcessVideoRecordingJob processing SessionRecording ID #{$this->recordingId}.");

        $recording = SessionRecording::find($this->recordingId);

        if (! $recording) {
            Log::warning("ProcessVideoRecordingJob: SessionRecording #{$this->recordingId} not found.");
            return;
        }

        if (! $recording->isExternalUrl()) {
            $disk = $recording->storage_disk ?: 'public';
            if (Storage::disk($disk)->exists($recording->video_storage_path)) {
                $recording->file_size_bytes = Storage::disk($disk)->size($recording->video_storage_path);
            }
        }

        $recording->processing_status = 'ready';
        $recording->save();

        $cache->invalidateTeacher((int) $recording->teacher_id);

        if ($recording->is_published && $recording->cohort_id) {
            $studentIds = CohortMember::where('cohort_id', $recording->cohort_id)
                ->where('status', 'active')
                ->pluck('student_id')
                ->unique();

            foreach ($studentIds as $studentId) {
                $cache->invalidateStudent((int) $studentId);
                AppNotification::create([
                    'user_id' => $studentId,
                    'type' => AppNotification::TYPE_RECORDING_READY,
                    'title' => 'تسجيل حصة جديد متاح في المكتبة',
                    'body' => "تمت إضافة تسجيل \"{$recording->title}\" إلى مكتبة الفوج.",
                    'data' => [
                        'recording_id' => $recording->id,
                        'recording_code' => $recording->recording_code,
                        'cohort_id' => $recording->cohort_id,
                    ],
                ]);
            }
        }

        Log::info("ProcessVideoRecordingJob: SessionRecording #{$this->recordingId} READY.");
    }

    public function failed(\Throwable $exception): void
    {
        Log::error("ProcessVideoRecordingJob failed for recording #{$this->recordingId}: {$exception->getMessage()}");
    }
}
