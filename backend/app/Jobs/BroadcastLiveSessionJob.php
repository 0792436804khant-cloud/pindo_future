<?php

namespace App\Jobs;

use App\Models\ClassroomSession;
use App\Services\NotificationService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class BroadcastLiveSessionJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    /**
     * Number of times the job may be attempted.
     */
    public int $tries = 3;

    /**
     * Timeout for the job execution in seconds.
     */
    public int $timeout = 60;

    /**
     * Classroom session to broadcast alerts for.
     */
    public ClassroomSession $session;

    /**
     * Create a new job instance.
     */
    public function __construct(ClassroomSession $session)
    {
        $this->session = $session;
        $this->onQueue('high-priority');
    }

    /**
     * Execute the job.
     */
    public function handle(NotificationService $notificationService): int
    {
        Log::info("Executing BroadcastLiveSessionJob for session {$this->session->session_id} on worker process.");

        $recipientsCount = $notificationService->notifySessionLive($this->session);

        Log::info("BroadcastLiveSessionJob completed successfully. {$recipientsCount} recipients notified.");

        return $recipientsCount;
    }

    /**
     * Handle a job failure.
     */
    public function failed(\Throwable $exception): void
    {
        Log::error("BroadcastLiveSessionJob failed for session {$this->session->session_id}: {$exception->getMessage()}");
    }
}
