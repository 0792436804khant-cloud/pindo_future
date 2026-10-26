<?php

namespace Tests\Feature;

use App\Models\Role;
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
    }

    public function test_student_dashboard_requires_authentication(): void
    {
        $response = $this->getJson('/api/v1/student/dashboard');
        $response->assertStatus(401);
    }

    public function test_student_can_fetch_dashboard_payload(): void
    {
        $student = User::create([
            'name' => 'Ada Lovelace',
            'email' => 'ada.student@pindofuture.com',
            'password' => bcrypt('Password123!'),
            'role' => Role::STUDENT,
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
