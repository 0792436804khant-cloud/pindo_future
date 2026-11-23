<?php

namespace App\Console\Commands;

use App\Models\CohortMember;
use App\Models\Enrollment;
use Illuminate\Console\Command;

class ExpireSubscriptionsCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'pindo:expire-subscriptions';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Automatically expire lapsed cohort and course subscriptions';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $now = now();

        // 1. Expire lapsed cohort memberships
        $expiredCohortsCount = CohortMember::where('status', 'active')
            ->whereNotNull('ends_at')
            ->where('ends_at', '<=', $now)
            ->update(['status' => 'suspended']);

        // 2. Expire lapsed course enrollments
        $expiredEnrollmentsCount = Enrollment::where('status', 'active')
            ->whereNotNull('ends_at')
            ->where('ends_at', '<=', $now)
            ->update(['status' => 'cancelled']);

        $total = $expiredCohortsCount + $expiredEnrollmentsCount;

        $this->info("Successfully audited and expired {$total} subscriptions ({$expiredCohortsCount} cohorts, {$expiredEnrollmentsCount} courses).");

        return Command::SUCCESS;
    }
}
