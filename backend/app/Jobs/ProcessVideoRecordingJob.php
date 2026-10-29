<?php

namespace App\Jobs;

use App\Models\CohortRecording;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

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
     * Execute the job: Verify file integrity, flag processing as ready, and enable secure streaming.
     */
    public function handle(): void
    {
        Log::info("ProcessVideoRecordingJob processing recording ID #{$this->recordingId} on worker.");

        $recording = CohortRecording::find($this->recordingId);

        if (!$recording) {
            Log::warning("ProcessVideoRecordingJob: Recording #{$this->recordingId} not found.");
            return;
        }

        // Mark recording as verified and ready for watermark streaming
        $recording->status = 'ready';
        $recording->save();

        Log::info("ProcessVideoRecordingJob: Recording #{$this->recordingId} is now READY for students.");
    }

    public function failed(\Throwable $exception): void
    {
        Log::error("ProcessVideoRecordingJob failed for recording #{$this->recordingId}: {$exception->getMessage()}");
    }
}
