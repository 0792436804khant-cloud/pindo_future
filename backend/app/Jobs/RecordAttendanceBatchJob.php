<?php

namespace App\Jobs;

use App\Models\ClassroomAttendance;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class RecordAttendanceBatchJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;
    public int $timeout = 30;

    /**
     * Batch array of attendance payload items:
     * [
     *   ['session_id' => '...', 'user_id' => 1, 'duration_seconds' => 120, 'joined_at' => '...'],
     *   ...
     * ]
     */
    public array $attendanceItems;

    /**
     * Create a new job instance.
     */
    public function __construct(array $attendanceItems)
    {
        $this->attendanceItems = $attendanceItems;
        $this->onQueue('attendance');
    }

    /**
     * Execute the job to batch-insert or update attendance records in a single transaction.
     */
    public function handle(): int
    {
        if (empty($this->attendanceItems)) {
            return 0;
        }

        return DB::transaction(function () {
            $processed = 0;
            $now = now();

            foreach ($this->attendanceItems as $item) {
                if (empty($item['session_id']) || empty($item['user_id'])) {
                    continue;
                }

                $record = ClassroomAttendance::where('session_id', $item['session_id'])
                    ->where('user_id', $item['user_id'])
                    ->first();

                if ($record) {
                    $record->duration_seconds = max((int) ($record->duration_seconds ?? 0), (int) ($item['duration_seconds'] ?? 0));
                    $record->left_at = $item['left_at'] ?? $now;
                    $record->save();
                } else {
                    ClassroomAttendance::create([
                        'session_id' => $item['session_id'],
                        'user_id' => $item['user_id'],
                        'joined_at' => $item['joined_at'] ?? $now,
                        'left_at' => $item['left_at'] ?? null,
                        'duration_seconds' => (int) ($item['duration_seconds'] ?? 0),
                    ]);
                }
                $processed++;
            }

            Log::info("RecordAttendanceBatchJob processed {$processed} attendance heartbeats.");

            return $processed;
        });
    }

    public function failed(\Throwable $exception): void
    {
        Log::error("RecordAttendanceBatchJob failed: {$exception->getMessage()}");
    }
}
