<?php

namespace Tests\Feature;

use App\Models\ClassroomSession;
use App\Models\CohortMember;
use App\Models\Role;
use App\Models\StudyCohort;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class CohortManagementTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        Role::firstOrCreate(['name' => Role::ADMIN], ['label' => 'Administrator']);
        Role::firstOrCreate(['name' => Role::TEACHER], ['label' => 'Teacher']);
        Role::firstOrCreate(['name' => Role::STUDENT], ['label' => 'Student']);
        Role::firstOrCreate(['name' => Role::PARENT], ['label' => 'Parent']);
    }

    protected function createUser(string $role, array $attributes = []): User
    {
        $unique = Str::random(8);
        return User::create(array_merge([
            'name' => "User {$unique}",
            'email' => "user.{$unique}@example.com",
            'password' => bcrypt('SecurePassword123!'),
            'role' => $role,
        ], $attributes));
    }

    public function test_teacher_can_create_study_cohort_with_algerian_bac_stream_and_schedule(): void
    {
        $teacher = $this->createUser(Role::TEACHER, [
            'wilaya' => 16, // Alger
        ]);

        $payload = [
            'name' => 'فوج النخبة - رياضيات بكالوريا 2026',
            'subject' => 'Mathématiques',
            'academic_level' => '3AS BAC',
            'stream' => 'علوم تجريبية',
            'max_students' => 80,
            'monthly_price' => 3000.00,
            'schedule' => [
                ['day' => 'Friday', 'time' => '18:00', 'duration_minutes' => 120],
                ['day' => 'Tuesday', 'time' => '19:00', 'duration_minutes' => 90],
            ],
            'description' => 'مراجعة شاملة لجميع وحدات الرياضيات مع حل مواضيع البكالوريا النموذجية',
        ];

        $response = $this->actingAs($teacher)->postJson('/api/v1/teacher/cohorts', $payload);

        $response->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.name', $payload['name'])
            ->assertJsonPath('data.academic_level', '3AS BAC')
            ->assertJsonPath('data.stream', 'علوم تجريبية')
            ->assertJsonPath('data.max_students', 80)
            ->assertJsonPath('data.monthly_price', 3000);

        $this->assertDatabaseHas('study_cohorts', [
            'teacher_id' => $teacher->id,
            'name' => $payload['name'],
            'stream' => 'علوم تجريبية',
        ]);
    }

    public function test_teacher_cannot_access_or_modify_another_teachers_cohort(): void
    {
        $teacher1 = $this->createUser(Role::TEACHER);
        $teacher2 = $this->createUser(Role::TEACHER);

        $cohort = StudyCohort::create([
            'teacher_id' => $teacher1->id,
            'name' => 'Teacher 1 Physics Group',
            'subject' => 'Physique',
            'academic_level' => '3AS BAC',
            'stream' => 'تقني رياضي',
            'max_students' => 50,
        ]);

        $updateResponse = $this->actingAs($teacher2)->putJson("/api/v1/teacher/cohorts/{$cohort->id}", [
            'name' => 'Hacked Cohort',
        ]);

        $updateResponse->assertStatus(404);

        $deleteResponse = $this->actingAs($teacher2)->deleteJson("/api/v1/teacher/cohorts/{$cohort->id}");
        $deleteResponse->assertStatus(404);
    }

    public function test_student_can_discover_cohorts_filtered_by_stream_and_level(): void
    {
        $teacher = $this->createUser(Role::TEACHER, [
            'is_verified' => true,
            'wilaya' => 31, // Oran
        ]);

        StudyCohort::create([
            'teacher_id' => $teacher->id,
            'name' => 'Maths BAC Sciences',
            'subject' => 'Maths',
            'academic_level' => '3AS BAC',
            'stream' => 'علوم تجريبية',
            'max_students' => 50,
            'is_active' => true,
        ]);

        StudyCohort::create([
            'teacher_id' => $teacher->id,
            'name' => 'History BAC Philo',
            'subject' => 'Histoire',
            'academic_level' => '3AS BAC',
            'stream' => 'آداب وفلسفة',
            'max_students' => 50,
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/v1/cohorts?stream=' . urlencode('علوم تجريبية'));

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.name', 'Maths BAC Sciences')
            ->assertJsonPath('data.0.teacher.is_verified', true);
    }

    public function test_student_can_join_and_leave_cohort_enforcing_capacity(): void
    {
        $teacher = $this->createUser(Role::TEACHER);
        $student1 = $this->createUser(Role::STUDENT);
        $student2 = $this->createUser(Role::STUDENT);

        $cohort = StudyCohort::create([
            'teacher_id' => $teacher->id,
            'name' => 'Limited Capacity Cohort',
            'subject' => 'Sciences',
            'academic_level' => '3AS BAC',
            'max_students' => 1,
            'is_active' => true,
        ]);

        // Student 1 joins
        $join1 = $this->actingAs($student1)->postJson("/api/v1/student/cohorts/{$cohort->id}/join");
        $join1->assertStatus(201);
        $this->assertEquals(1, $cohort->fresh()->enrolled_count);

        // Student 1 duplicate join returns 422
        $dupJoin = $this->actingAs($student1)->postJson("/api/v1/student/cohorts/{$cohort->id}/join");
        $dupJoin->assertStatus(422);

        // Student 2 tries to join but cohort is full
        $join2 = $this->actingAs($student2)->postJson("/api/v1/student/cohorts/{$cohort->id}/join");
        $join2->assertStatus(422);

        // Student 1 leaves
        $leave = $this->actingAs($student1)->deleteJson("/api/v1/student/cohorts/{$cohort->id}/leave");
        $leave->assertStatus(200);
        $this->assertEquals(0, $cohort->fresh()->enrolled_count);

        // Now Student 2 can join
        $join2Success = $this->actingAs($student2)->postJson("/api/v1/student/cohorts/{$cohort->id}/join");
        $join2Success->assertStatus(201);
        $this->assertEquals(1, $cohort->fresh()->enrolled_count);
    }

    public function test_teacher_can_schedule_live_session_bound_to_cohort(): void
    {
        $teacher = $this->createUser(Role::TEACHER);
        $cohort = StudyCohort::create([
            'teacher_id' => $teacher->id,
            'name' => 'Elite Math Cohort',
            'subject' => 'Mathématiques',
            'academic_level' => '3AS BAC',
            'max_students' => 60,
        ]);

        $response = $this->actingAs($teacher)->postJson("/api/v1/teacher/cohorts/{$cohort->id}/sessions", [
            'title' => 'حصة مباشرة: الدوال الأسية واللوغاريتمية',
            'description' => 'شرح معمق وحل تمارين الامتحانات السابقة',
            'scheduled_at' => now()->addDay()->toIso8601String(),
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.cohort_id', $cohort->id)
            ->assertJsonPath('data.max_participants', 60);

        $this->assertDatabaseHas('classroom_sessions', [
            'cohort_id' => $cohort->id,
            'title' => 'حصة مباشرة: الدوال الأسية واللوغاريتمية',
        ]);
    }

    public function test_teacher_verification_badge_lifecycle(): void
    {
        $admin = $this->createUser(Role::ADMIN);
        $teacher = $this->createUser(Role::TEACHER, [
            'is_verified' => false,
            'verification_status' => 'unverified',
        ]);

        // 1. Teacher submits verification documents
        $req = $this->actingAs($teacher)->postJson('/api/v1/teacher/verification/request', [
            'national_id_or_diploma' => 'DIPLOME_ENS_MATH_2020.pdf',
        ]);

        $req->assertStatus(200)
            ->assertJsonPath('data.verification_status', 'pending');

        $this->assertEquals('pending', $teacher->fresh()->verification_status);

        // 2. Admin lists pending verifications
        $list = $this->actingAs($admin)->getJson('/api/v1/admin/teachers/verifications');
        $list->assertStatus(200)
            ->assertJsonCount(1, 'data');

        // 3. Admin approves verification
        $approve = $this->actingAs($admin)->postJson("/api/v1/admin/teachers/{$teacher->id}/verify");
        $approve->assertStatus(200)
            ->assertJsonPath('data.is_verified', true)
            ->assertJsonPath('data.verification_status', 'verified');

        $this->assertTrue($teacher->fresh()->is_verified);
    }

    public function test_parent_can_link_student_via_guardian_link_code(): void
    {
        $parent = $this->createUser(Role::PARENT);
        $student = $this->createUser(Role::STUDENT, [
            'guardian_link_code' => 'PINDO-STU-ALGER99',
        ]);

        $response = $this->actingAs($parent)->postJson('/api/v1/parent/link-child', [
            'linking_code' => 'PINDO-STU-ALGER99',
            'relationship' => 'Father',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('child.id', $student->id);

        $this->assertDatabaseHas('parent_student', [
            'parent_id' => $parent->id,
            'student_id' => $student->id,
        ]);
    }
}
