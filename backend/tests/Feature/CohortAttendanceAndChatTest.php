<?php

namespace Tests\Feature;

use App\Models\CohortMember;
use App\Models\Role;
use App\Models\StudyCohort;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class CohortAttendanceAndChatTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        Role::firstOrCreate(['name' => Role::ADMIN], ['label' => 'Administrator']);
        Role::firstOrCreate(['name' => Role::TEACHER], ['label' => 'Teacher']);
        Role::firstOrCreate(['name' => Role::STUDENT], ['label' => 'Student']);
    }

    private function createUser(string $role, string $name = 'User'): User
    {
        $unique = Str::random(8);

        return User::create([
            'name' => $name,
            'email' => "user.{$unique}@example.com",
            'password' => bcrypt('SecurePassword123!'),
            'role' => $role,
        ]);
    }

    public function test_empty_cohort_has_zero_fake_students_and_teacher_can_manage_sessions(): void
    {
        $teacher = $this->createUser(Role::TEACHER, 'الأستاذ أمين');
        $cohort = StudyCohort::create([
            'teacher_id' => $teacher->id,
            'name' => 'فوج 1',
            'subject' => 'الرياضيات',
            'academic_level' => 'ثالثة ثانوي (BAC)',
            'live_sessions_price' => 2500,
            'library_price' => 1500,
            'bundle_price' => 3500,
            'include_library' => true,
        ]);

        // Verify 3500 bundle pays 2975 DZD net (85%)
        $pricing = $cohort->resolvePackagePricing(StudyCohort::PACKAGE_FULL_BUNDLE);
        $this->assertEquals(2975.0, $pricing['teacher_net_amount']);
        $this->assertEquals(525.0, $pricing['platform_fee']);

        // Attendance endpoint returns 0 fake students
        $this->actingAs($teacher)->getJson("/api/v1/teacher/cohorts/{$cohort->id}/attendance?month=2026-11")
            ->assertOk()
            ->assertJsonCount(0, 'data.students')
            ->assertJsonCount(0, 'data.sessions');

        // Teacher can define an attendance session
        $sessRes = $this->actingAs($teacher)->postJson("/api/v1/teacher/cohorts/{$cohort->id}/attendance/sessions", [
            'label' => 'الحصة 1',
            'session_date' => '2026-11-27',
            'month_key' => '2026-11',
        ])->assertStatus(201);

        $sessionId = $sessRes->json('data.id');

        // Add real student and record attendance
        $student = $this->createUser(Role::STUDENT, 'تلميذ حقيقي');
        CohortMember::create([
            'cohort_id' => $cohort->id,
            'student_id' => $student->id,
            'status' => 'active',
            'joined_at' => now(),
        ]);

        $this->actingAs($teacher)->postJson("/api/v1/teacher/cohorts/{$cohort->id}/attendance/records", [
            'records' => [
                ['session_id' => $sessionId, 'student_id' => $student->id, 'status' => 'L'],
            ],
        ])->assertOk();

        $this->actingAs($teacher)->getJson("/api/v1/teacher/cohorts/{$cohort->id}/attendance?month=2026-11")
            ->assertOk()
            ->assertJsonCount(1, 'data.students')
            ->assertJsonPath('data.students.0.number', 1)
            ->assertJsonPath('data.students.0.name', 'تلميذ حقيقي')
            ->assertJsonPath("data.records.{$student->id}_{$sessionId}", 'L');
    }

    public function test_cohort_chat_tracks_delivery_and_read_receipts_per_member(): void
    {
        $teacher = $this->createUser(Role::TEACHER, 'الأستاذ محمد');
        $student1 = $this->createUser(Role::STUDENT, 'ياسين الطالب');
        $student2 = $this->createUser(Role::STUDENT, 'أنيس الطالب');

        $cohort = StudyCohort::create([
            'teacher_id' => $teacher->id,
            'name' => 'فوج النخبة',
            'subject' => 'الفيزياء',
            'academic_level' => 'ثالثة ثانوي (BAC)',
            'bundle_price' => 3500,
        ]);

        CohortMember::create(['cohort_id' => $cohort->id, 'student_id' => $student1->id, 'status' => 'active', 'joined_at' => now()]);
        CohortMember::create(['cohort_id' => $cohort->id, 'student_id' => $student2->id, 'status' => 'active', 'joined_at' => now()]);

        // 1. Teacher sends message -> initially 'sent', 0 read, 2 unread
        $sendRes = $this->actingAs($teacher)->postJson("/api/v1/cohorts/{$cohort->id}/chat/messages", [
            'text' => 'السلام عليكم',
        ])->assertStatus(201);

        $sendRes->assertJsonPath('data.delivery_status', 'sent')
            ->assertJsonPath('data.read_count', 0)
            ->assertJsonPath('data.total_recipients', 2)
            ->assertJsonCount(0, 'data.read_by')
            ->assertJsonCount(2, 'data.unread_by');

        // 2. Student 1 opens chat -> marks message read by Student 1
        $this->actingAs($student1)->getJson("/api/v1/cohorts/{$cohort->id}/chat/messages")
            ->assertOk()
            ->assertJsonCount(1, 'data.messages');

        // 3. Teacher refreshes -> sees delivery_status = 'read', read_count = 1/2, read_by Student 1, unread_by Student 2
        $teacherView = $this->actingAs($teacher)->getJson("/api/v1/cohorts/{$cohort->id}/chat/messages")
            ->assertOk();

        $teacherView->assertJsonPath('data.messages.0.delivery_status', 'read')
            ->assertJsonPath('data.messages.0.read_count', 1)
            ->assertJsonPath('data.messages.0.total_recipients', 2)
            ->assertJsonPath('data.messages.0.read_by.0.name', 'ياسين الطالب')
            ->assertJsonPath('data.messages.0.unread_by.0.name', 'أنيس الطالب');
    }
}
