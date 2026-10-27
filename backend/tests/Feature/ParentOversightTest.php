<?php

namespace Tests\Feature;

use App\Models\ClassroomAttendance;
use App\Models\ClassroomSession;
use App\Models\Course;
use App\Models\CourseModule;
use App\Models\Enrollment;
use App\Models\GuardianNote;
use App\Models\Lesson;
use App\Models\ParentStudent;
use App\Models\Role;
use App\Models\StudyCohort;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ParentOversightTest extends TestCase
{
    use RefreshDatabase;

    protected User $parent;
    protected User $student;
    protected User $teacher;

    protected function setUp(): void
    {
        parent::setUp();

        Role::firstOrCreate(['name' => Role::ADMIN], ['label' => 'Admin']);
        Role::firstOrCreate(['name' => Role::TEACHER], ['label' => 'Teacher']);
        Role::firstOrCreate(['name' => Role::STUDENT], ['label' => 'Student']);
        Role::firstOrCreate(['name' => Role::PARENT], ['label' => 'Parent']);

        $this->parent = User::create([
            'name' => 'El-Hadj Mohamed',
            'email' => 'parent@pindofuture.com',
            'password' => bcrypt('password123'),
            'role' => Role::PARENT,
        ]);

        $this->student = User::create([
            'name' => 'Amine Mohamed',
            'email' => 'student.amine@pindofuture.com',
            'password' => bcrypt('password123'),
            'role' => Role::STUDENT,
            'student_id' => 'STU-ALG-9988',
        ]);

        $this->teacher = User::create([
            'name' => 'Prof. Karima',
            'email' => 'karima@pindofuture.com',
            'password' => bcrypt('password123'),
            'role' => Role::TEACHER,
            'verification_status' => 'verified',
        ]);
    }

    public function test_parent_can_link_student_child_via_email(): void
    {
        $response = $this->actingAs($this->parent, 'sanctum')
            ->postJson('/api/v1/parent/link-child', [
                'student_email' => 'student.amine@pindofuture.com',
                'relationship' => 'Father',
            ]);

        $response->assertStatus(201)
            ->assertJson([
                'status' => 'success',
                'child' => [
                    'id' => $this->student->id,
                    'name' => 'Amine Mohamed',
                    'email' => 'student.amine@pindofuture.com',
                    'relationship' => 'Father',
                ],
            ]);

        $this->assertDatabaseHas('parent_student', [
            'parent_id' => $this->parent->id,
            'student_id' => $this->student->id,
            'relationship' => 'Father',
            'status' => 'active',
        ]);
    }

    public function test_parent_can_fetch_children_overview(): void
    {
        ParentStudent::create([
            'parent_id' => $this->parent->id,
            'student_id' => $this->student->id,
            'relationship' => 'Father',
            'status' => 'active',
            'linked_at' => now(),
        ]);

        $response = $this->actingAs($this->parent, 'sanctum')
            ->getJson('/api/v1/parent/children');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'status',
                'data' => [
                    '*' => [
                        'id',
                        'name',
                        'email',
                        'relationship',
                        'linked_at',
                        'academics' => [
                            'enrolled_courses_count',
                            'completed_courses_count',
                            'average_progress',
                        ],
                        'attendance' => [
                            'total_watch_seconds',
                            'total_watch_minutes',
                            'sessions_attended_count',
                        ],
                        'notes_count',
                    ],
                ],
            ]);
    }

    public function test_parent_can_fetch_child_academics_and_attendance(): void
    {
        ParentStudent::create([
            'parent_id' => $this->parent->id,
            'student_id' => $this->student->id,
            'relationship' => 'Father',
            'status' => 'active',
            'linked_at' => now(),
        ]);

        $course = Course::create([
            'teacher_id' => $this->teacher->id,
            'title' => 'Math Bac 2027 Advanced',
            'slug' => 'math-bac-2027-advanced',
            'category' => 'Mathematics',
            'difficulty_level' => 'advanced',
            'price' => 4500,
            'is_published' => true,
        ]);

        Enrollment::create([
            'user_id' => $this->student->id,
            'course_id' => $course->id,
            'status' => Enrollment::STATUS_ACTIVE,
            'progress_percentage' => 45.0,
            'enrolled_at' => now(),
        ]);

        $academicsResponse = $this->actingAs($this->parent, 'sanctum')
            ->getJson("/api/v1/parent/children/{$this->student->id}/academics");

        $academicsResponse->assertStatus(200)
            ->assertJson([
                'status' => 'success',
            ]);

        $attendanceResponse = $this->actingAs($this->parent, 'sanctum')
            ->getJson("/api/v1/parent/children/{$this->student->id}/attendance");

        $attendanceResponse->assertStatus(200)
            ->assertJsonStructure([
                'status',
                'child' => [
                    'id',
                    'name',
                ],
                'summary' => [
                    'total_sessions_attended',
                    'total_watch_seconds',
                    'total_watch_minutes',
                    'total_watch_hours',
                ],
                'data',
            ]);
    }

    public function test_parent_can_acknowledge_teacher_note(): void
    {
        ParentStudent::create([
            'parent_id' => $this->parent->id,
            'student_id' => $this->student->id,
            'relationship' => 'Father',
            'status' => 'active',
            'linked_at' => now(),
        ]);

        $note = GuardianNote::create([
            'student_id' => $this->student->id,
            'author_id' => $this->teacher->id,
            'title' => 'Excellent homework performance',
            'content' => 'Amine scored 19/20 on integration test exercises.',
            'category' => 'academic',
            'priority' => 'normal',
            'is_acknowledged' => false,
        ]);

        $response = $this->actingAs($this->parent, 'sanctum')
            ->putJson("/api/v1/parent/notes/{$note->id}/acknowledge");

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'message' => 'Guardian note acknowledged.',
                'note_id' => $note->id,
            ]);

        $this->assertTrue($note->fresh()->is_acknowledged);
    }
}
