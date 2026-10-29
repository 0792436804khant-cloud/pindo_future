<?php

namespace Tests\Feature;

use App\Jobs\BroadcastLiveSessionJob;
use App\Jobs\RecordAttendanceBatchJob;
use App\Models\AppNotification;
use App\Models\ClassroomAttendance;
use App\Models\ClassroomSession;
use App\Models\CohortMember;
use App\Models\Role;
use App\Models\StudyCohort;
use App\Models\User;
use App\Services\CacheManagerService;
use App\Services\NotificationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Queue;
use Tests\TestCase;

class QueueAndCacheInfrastructureTest extends TestCase
{
    use RefreshDatabase;

    protected User $teacher;
    protected User $student;
    protected StudyCohort $cohort;
    protected ClassroomSession $session;

    protected function setUp(): void
    {
        parent::setUp();

        Role::firstOrCreate(['name' => Role::ADMIN], ['label' => 'Admin']);
        Role::firstOrCreate(['name' => Role::TEACHER], ['label' => 'Teacher']);
        Role::firstOrCreate(['name' => Role::STUDENT], ['label' => 'Student']);
        Role::firstOrCreate(['name' => Role::PARENT], ['label' => 'Parent']);

        $this->teacher = User::create([
            'name' => 'Prof. Hocine Chem',
            'email' => 'hocine@pindofuture.com',
            'password' => bcrypt('password123'),
            'role' => Role::TEACHER,
        ]);

        $this->student = User::create([
            'name' => 'Sara Benali',
            'email' => 'sara@pindofuture.com',
            'password' => bcrypt('password123'),
            'role' => Role::STUDENT,
        ]);

        $this->cohort = StudyCohort::create([
            'teacher_id' => $this->teacher->id,
            'name' => 'علوم طبيعية — بكالوريا 2027',
            'subject' => 'Natural Sciences',
            'academic_level' => 'secondary',
            'stream' => 'Scientific',
            'monthly_price' => 5000,
            'is_active' => true,
        ]);

        CohortMember::create([
            'cohort_id' => $this->cohort->id,
            'student_id' => $this->student->id,
            'status' => 'active',
            'joined_at' => now(),
        ]);

        $this->session = ClassroomSession::create([
            'session_id' => 'SES-SCI-BAC-101',
            'user_id' => $this->teacher->id,
            'cohort_id' => $this->cohort->id,
            'title' => 'آليات تركيب البروتين والأنزيمات',
            'status' => ClassroomSession::STATUS_SCHEDULED,
            'scheduled_at' => now()->addMinutes(5),
        ]);
    }

    public function test_broadcast_live_session_job_executes_successfully(): void
    {
        $job = new BroadcastLiveSessionJob($this->session);
        $notifService = app(NotificationService::class);

        $recipientsCount = $job->handle($notifService);

        $this->assertGreaterThanOrEqual(1, $recipientsCount);
        $this->assertDatabaseHas('app_notifications', [
            'user_id' => $this->student->id,
            'type' => AppNotification::TYPE_LIVE_SESSION_STARTED,
        ]);
    }

    public function test_record_attendance_batch_job_processes_batches_in_transaction(): void
    {
        $batch = [
            [
                'session_id' => $this->session->session_id,
                'user_id' => $this->student->id,
                'duration_seconds' => 360,
                'joined_at' => now()->subMinutes(6)->toDateTimeString(),
                'left_at' => now()->toDateTimeString(),
            ],
            [
                'session_id' => $this->session->session_id,
                'user_id' => $this->teacher->id,
                'duration_seconds' => 360,
                'joined_at' => now()->subMinutes(6)->toDateTimeString(),
                'left_at' => now()->toDateTimeString(),
            ],
        ];

        $job = new RecordAttendanceBatchJob($batch);
        $processed = $job->handle();

        $this->assertEquals(2, $processed);
        $this->assertDatabaseHas('classroom_attendances', [
            'session_id' => $this->session->session_id,
            'user_id' => $this->student->id,
            'duration_seconds' => 360,
        ]);
    }

    public function test_student_dashboard_caches_result_and_invalidates_cleanly(): void
    {
        Cache::flush();

        // 1. Initial hit populates cache
        $response = $this->actingAs($this->student, 'sanctum')
            ->getJson('/api/v1/student/dashboard');

        $response->assertStatus(200);

        $cacheKey = "student:dashboard:{$this->student->id}";
        $this->assertTrue(Cache::has($cacheKey));

        // 2. Invalidate via CacheManagerService
        $cacheManager = app(CacheManagerService::class);
        $cacheManager->invalidateStudent($this->student->id);

        $this->assertFalse(Cache::has($cacheKey));
    }

    public function test_teacher_dashboard_caches_result(): void
    {
        Cache::flush();

        $response = $this->actingAs($this->teacher, 'sanctum')
            ->getJson('/api/v1/teacher/dashboard');

        $response->assertStatus(200);

        $cacheKey = "teacher:dashboard:{$this->teacher->id}";
        $this->assertTrue(Cache::has($cacheKey));
    }
}
