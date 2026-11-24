<?php

namespace Tests\Feature;

use App\Models\ClassroomSession;
use App\Models\CohortMember;
use App\Models\Role;
use App\Models\StudyCohort;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class StudentDashboardTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Role::firstOrCreate(['name' => Role::STUDENT], ['label' => 'Student']);
        Role::firstOrCreate(['name' => Role::TEACHER], ['label' => 'Teacher']);
    }

    public function test_student_dashboard_requires_authentication(): void
    {
        $response = $this->getJson('/api/v1/student/dashboard');
        $response->assertStatus(401);
    }

    public function test_new_student_without_enrollments_receives_clean_empty_state(): void
    {
        $student = User::create([
            'name' => 'Nabil Student',
            'email' => 'nabil.student@pindofuture.com',
            'password' => bcrypt('Password123!'),
            'role' => Role::STUDENT,
        ]);

        $response = $this->actingAs($student, 'sanctum')
            ->getJson('/api/v1/student/dashboard');

        $response->assertStatus(200)
            ->assertJsonPath('data.next_session', null)
            ->assertJsonPath('data.subscriptions.active_cohorts_count', 0)
            ->assertJsonPath('data.subscriptions.remaining_credits', 0)
            ->assertJsonPath('data.subscriptions.status', 'inactive');
    }

    public function test_student_can_fetch_dashboard_payload(): void
    {
        $teacher = User::create([
            'name' => 'Prof. Amine',
            'email' => 'teacher.dash@pindofuture.com',
            'password' => bcrypt('Password123!'),
            'role' => Role::TEACHER,
        ]);

        $student = User::create([
            'name' => 'Ada Lovelace',
            'email' => 'ada.student@pindofuture.com',
            'password' => bcrypt('Password123!'),
            'role' => Role::STUDENT,
        ]);

        $cohort = StudyCohort::create([
            'teacher_id' => $teacher->id,
            'name' => 'فوج الرياضيات للبكالوريا',
            'subject' => 'الرياضيات',
            'academic_level' => 'secondary',
            'monthly_price' => 2500,
            'is_active' => true,
        ]);

        CohortMember::create([
            'cohort_id' => $cohort->id,
            'student_id' => $student->id,
            'status' => 'active',
            'joined_at' => now(),
        ]);

        ClassroomSession::create([
            'session_id' => 'SES-TEST-MATH-01',
            'user_id' => $teacher->id,
            'cohort_id' => $cohort->id,
            'title' => 'مراجعة المتتاليات العددية',
            'status' => ClassroomSession::STATUS_SCHEDULED,
            'scheduled_at' => now()->addHour(),
        ]);

        $response = $this->actingAs($student, 'sanctum')
            ->getJson('/api/v1/student/dashboard');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'status',
                'data' => [
                    'student' => ['id', 'name', 'email', 'role'],
                    'next_session' => ['id', 'session_id', 'title', 'subject', 'teacher_name', 'scheduled_at', 'status'],
                    'subscriptions' => ['package_name', 'remaining_credits', 'active_cohorts_count', 'library_access'],
                    'today_schedule',
                    'recent_recordings',
                    'attendance' => ['attendance_rate'],
                    'notifications',
                ],
            ]);
    }
}
