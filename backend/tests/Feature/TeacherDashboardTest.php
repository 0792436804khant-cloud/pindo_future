<?php

namespace Tests\Feature;

use App\Models\Role;
use App\Models\StudyCohort;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TeacherDashboardTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Role::firstOrCreate(['name' => Role::TEACHER], ['label' => 'Teacher']);
    }

    public function test_teacher_can_fetch_dashboard_payload(): void
    {
        $teacher = User::create([
            'name' => 'Prof. Amine Boudiaf',
            'email' => 'teacher.test@pindofuture.com',
            'password' => bcrypt('password123'),
            'role' => Role::TEACHER,
            'teacherId' => 'TCH_TEST123',
            'isTeacherVerified' => true,
        ]);

        $cohort = StudyCohort::create([
            'teacher_id' => $teacher->id,
            'name' => 'فوج الرياضيات — بكالوريا 2027',
            'subject' => 'الرياضيات',
            'academic_level' => 'ثالثة ثانوي',
            'stream' => 'علوم تجريبية',
            'max_students' => 50,
            'monthly_price' => 3500.00,
            'is_active' => true,
        ]);

        $response = $this->actingAs($teacher, 'sanctum')
            ->getJson('/api/v1/teacher/dashboard');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'status',
                'data' => [
                    'teacher' => [
                        'id',
                        'name',
                        'email',
                        'teacher_id',
                        'is_verified',
                    ],
                    'stats' => [
                        'enrolled_students_count',
                        'active_cohorts_count',
                        'scheduled_sessions_count',
                        'completed_sessions_count',
                        'expired_credits_students_count',
                        'total_earnings',
                        'gross_sales',
                        'pending_earnings',
                        'library_recordings_count',
                    ],
                    'upcoming_session',
                    'today_schedule',
                    'notifications',
                    'cohorts',
                    'recent_transactions',
                ],
            ]);

        $this->assertEquals(1, $response->json('data.stats.active_cohorts_count'));
    }

    public function test_unauthenticated_user_cannot_access_teacher_dashboard(): void
    {
        $response = $this->getJson('/api/v1/teacher/dashboard');
        $response->assertStatus(401);
    }
}
