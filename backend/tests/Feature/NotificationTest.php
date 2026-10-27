<?php

namespace Tests\Feature;

use App\Models\AppNotification;
use App\Models\ClassroomSession;
use App\Models\CohortMember;
use App\Models\ParentStudent;
use App\Models\Role;
use App\Models\StudyCohort;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class NotificationTest extends TestCase
{
    use RefreshDatabase;

    protected User $teacher;
    protected User $student;
    protected User $parent;
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
            'name' => 'Prof. Amine Math',
            'email' => 'teacher.amine@pindofuture.com',
            'password' => bcrypt('password123'),
            'role' => Role::TEACHER,
        ]);

        $this->student = User::create([
            'name' => 'Kareem Ahmed',
            'email' => 'student.kareem@pindofuture.com',
            'password' => bcrypt('password123'),
            'role' => Role::STUDENT,
        ]);

        $this->parent = User::create([
            'name' => 'Ahmed Father',
            'email' => 'parent.ahmed@pindofuture.com',
            'password' => bcrypt('password123'),
            'role' => Role::PARENT,
        ]);

        ParentStudent::create([
            'parent_id' => $this->parent->id,
            'student_id' => $this->student->id,
            'relationship' => 'Father',
            'status' => 'active',
        ]);

        $this->cohort = StudyCohort::create([
            'teacher_id' => $this->teacher->id,
            'name' => 'رياضيات — بكالوريا 2027',
            'subject' => 'Mathematics',
            'academic_level' => 'secondary',
            'stream' => 'Scientific',
            'monthly_price' => 4500,
            'is_active' => true,
        ]);

        CohortMember::create([
            'cohort_id' => $this->cohort->id,
            'student_id' => $this->student->id,
            'status' => 'active',
            'joined_at' => now(),
        ]);

        $this->session = ClassroomSession::create([
            'session_id' => 'SES-MATH-LIVE-999',
            'user_id' => $this->teacher->id,
            'cohort_id' => $this->cohort->id,
            'title' => 'مراجعة الدوال الأسية وحل التمارين النموذجية',
            'status' => ClassroomSession::STATUS_SCHEDULED,
            'scheduled_at' => now()->addMinutes(10),
        ]);
    }

    public function test_user_can_list_notifications_with_unread_count(): void
    {
        AppNotification::create([
            'user_id' => $this->student->id,
            'type' => AppNotification::TYPE_COURSE_ENROLLED,
            'title' => 'تم تأكيد اشتراكك في الفوج',
            'body' => 'أهلاً بك في فوج رياضيات بكالوريا 2027!',
            'data' => ['cohort_id' => $this->cohort->id],
        ]);

        $response = $this->actingAs($this->student, 'sanctum')
            ->getJson('/api/v1/notifications');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'unread_count' => 1,
                'total_count' => 1,
            ])
            ->assertJsonStructure([
                'status',
                'unread_count',
                'total_count',
                'data' => [
                    '*' => ['id', 'type', 'title', 'body', 'data', 'is_read', 'created_at', 'time_ago'],
                ],
            ]);
    }

    public function test_user_can_mark_single_notification_as_read(): void
    {
        $notification = AppNotification::create([
            'user_id' => $this->student->id,
            'type' => AppNotification::TYPE_LIVE_SESSION_STARTING,
            'title' => 'اقترب موعد الحصة',
            'body' => 'ستبدأ الحصة بعد 10 دقائق.',
        ]);

        $response = $this->actingAs($this->student, 'sanctum')
            ->postJson("/api/v1/notifications/{$notification->id}/read");

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'message' => 'Notification marked as read.',
                'id' => $notification->id,
            ]);

        $this->assertNotNull($notification->fresh()->read_at);
    }

    public function test_user_can_mark_all_notifications_as_read(): void
    {
        AppNotification::create([
            'user_id' => $this->student->id,
            'type' => 'alert_1',
            'title' => 'Alert 1',
            'body' => 'Content 1',
        ]);

        AppNotification::create([
            'user_id' => $this->student->id,
            'type' => 'alert_2',
            'title' => 'Alert 2',
            'body' => 'Content 2',
        ]);

        $response = $this->actingAs($this->student, 'sanctum')
            ->postJson('/api/v1/notifications/read-all');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'updated_count' => 2,
            ]);

        $this->assertEquals(0, AppNotification::forUser($this->student->id)->unread()->count());
    }

    public function test_teacher_can_broadcast_session_live_alert(): void
    {
        $response = $this->actingAs($this->teacher, 'sanctum')
            ->postJson("/api/v1/sessions/{$this->session->session_id}/notify-live");

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'session_id' => $this->session->session_id,
            ]);

        // Student received live alert
        $this->assertDatabaseHas('app_notifications', [
            'user_id' => $this->student->id,
            'type' => AppNotification::TYPE_LIVE_SESSION_STARTED,
        ]);

        // Parent received guardian alert
        $this->assertDatabaseHas('app_notifications', [
            'user_id' => $this->parent->id,
            'type' => AppNotification::TYPE_GUARDIAN_ALERT,
        ]);
    }

    public function test_starting_session_automatically_triggers_live_alerts(): void
    {
        $response = $this->actingAs($this->teacher, 'sanctum')
            ->postJson("/api/v1/teacher/sessions/{$this->session->session_id}/start");

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
            ]);

        $this->assertEquals(ClassroomSession::STATUS_ACTIVE, $this->session->fresh()->status);

        // Verification of auto-broadcast
        $studentNotification = AppNotification::where('user_id', $this->student->id)
            ->where('type', AppNotification::TYPE_LIVE_SESSION_STARTED)
            ->first();

        $this->assertNotNull($studentNotification);
        $this->assertStringContainsString('الحصة المباشرة بدأت الآن', $studentNotification->title);
    }
}
