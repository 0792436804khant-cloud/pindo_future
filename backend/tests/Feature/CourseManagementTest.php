<?php

namespace Tests\Feature;

use App\Models\ClassroomSession;
use App\Models\Course;
use App\Models\CourseLesson;
use App\Models\CourseModule;
use App\Models\Role;
use App\Models\TeacherPlatform;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class CourseManagementTest extends TestCase
{
    use RefreshDatabase;

    protected User $teacher;
    protected User $otherTeacher;
    protected User $student;

    protected function setUp(): void
    {
        parent::setUp();

        // 1. Seed Roles
        Role::create(['name' => Role::ADMIN, 'label' => 'Administrator']);
        $teacherRole = Role::create(['name' => Role::TEACHER, 'label' => 'Teacher']);
        $studentRole = Role::create(['name' => Role::STUDENT, 'label' => 'Student']);

        // 2. Create Primary Teacher with TCH_123
        $this->teacher = User::create([
            'name' => 'Professor Alan Turing',
            'email' => 'teacher.demo@pindofuture.com',
            'password' => bcrypt('TeacherPassword123!'),
            'role' => Role::TEACHER,
            'teacher_id' => 'TCH_123',
        ]);
        $this->teacher->roles()->attach($teacherRole);

        TeacherPlatform::create([
            'user_id' => $this->teacher->id,
            'headline' => 'Mathematics & Cryptography Specialist',
            'bio' => 'Pioneer in computation and cryptography.',
            'website_url' => 'https://alanturing.org',
        ]);

        // 3. Create Second Teacher
        $this->otherTeacher = User::create([
            'name' => 'Dr. Ada Lovelace',
            'email' => 'ada@pindofuture.com',
            'password' => bcrypt('AdaPassword123!'),
            'role' => Role::TEACHER,
            'teacher_id' => 'TCH_456',
        ]);
        $this->otherTeacher->roles()->attach($teacherRole);

        // 4. Create Student
        $this->student = User::create([
            'name' => 'Demo Student',
            'email' => 'student.demo@pindofuture.com',
            'password' => bcrypt('StudentPassword123!'),
            'role' => Role::STUDENT,
        ]);
        $this->student->roles()->attach($studentRole);
    }

    /**
     * Test public teacher showcase resolves successfully for valid teacher_id.
     */
    public function test_public_teacher_showcase_resolves_with_courses_and_sessions(): void
    {
        // Create 1 published course and 1 draft course
        $publishedCourse = Course::create([
            'teacher_id' => $this->teacher->id,
            'title' => 'Advanced Cryptographic Protocols',
            'description' => 'Master public key crypto and zero-knowledge proofs.',
            'category' => 'Computer Science',
            'price' => 49.99,
            'status' => Course::STATUS_PUBLISHED,
        ]);

        $draftCourse = Course::create([
            'teacher_id' => $this->teacher->id,
            'title' => 'Quantum Algorithms Unreleased',
            'status' => Course::STATUS_DRAFT,
        ]);

        // Create an active session
        $session = ClassroomSession::create([
            'user_id' => $this->teacher->id,
            'title' => 'Live Enigma Machine Decryption Workshop',
            'status' => ClassroomSession::STATUS_ACTIVE,
            'started_at' => now(),
        ]);

        $response = $this->getJson('/api/v1/teachers/TCH_123/public');

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.teacher.teacher_id', 'TCH_123')
            ->assertJsonPath('data.teacher.name', 'Professor Alan Turing')
            ->assertJsonPath('data.platform.headline', 'Mathematics & Cryptography Specialist')
            ->assertJsonPath('data.metrics.total_courses', 1)
            ->assertJsonPath('data.active_session.session_id', $session->session_id)
            ->assertJsonCount(1, 'data.courses')
            ->assertJsonPath('data.courses.0.title', 'Advanced Cryptographic Protocols');
    }

    /**
     * Test public showcase returns 404 for unknown teacher ID.
     */
    public function test_public_teacher_showcase_returns_404_when_not_found(): void
    {
        $response = $this->getJson('/api/v1/teachers/TCH_NONEXISTENT/public');

        $response->assertStatus(404)
            ->assertJsonPath('status', 'error');
    }

    /**
     * Test teacher can create, update, and manage curriculum modules and lessons.
     */
    public function test_teacher_can_build_full_curriculum_and_link_live_session(): void
    {
        // 1. Create a dynamic classroom session first
        $session = ClassroomSession::create([
            'user_id' => $this->teacher->id,
            'title' => 'Session for Lesson 1',
            'status' => ClassroomSession::STATUS_SCHEDULED,
        ]);

        // 2. Teacher creates a course
        $courseResponse = $this->actingAs($this->teacher)
            ->postJson('/api/v1/teacher/courses', [
                'title' => 'Full-Stack Distributed Systems',
                'description' => 'High-throughput scaling with WebRTC and Redis',
                'category' => 'Engineering',
                'price' => 79.00,
                'status' => Course::STATUS_PUBLISHED,
            ]);

        $courseResponse->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.title', 'Full-Stack Distributed Systems');

        $courseId = $courseResponse->json('data.id');

        // 3. Add Module to Course
        $moduleResponse = $this->actingAs($this->teacher)
            ->postJson("/api/v1/teacher/courses/{$courseId}/modules", [
                'title' => 'Module 1: Real-Time Media Protocols',
                'order' => 1,
            ]);

        $moduleResponse->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.title', 'Module 1: Real-Time Media Protocols');

        $moduleId = $moduleResponse->json('data.id');

        // 4. Add Live Lesson linked to Classroom Session
        $lessonResponse = $this->actingAs($this->teacher)
            ->postJson("/api/v1/teacher/modules/{$moduleId}/lessons", [
                'title' => 'Lesson 1.1: WebRTC SFU Architecture',
                'type' => CourseLesson::TYPE_LIVE_SESSION,
                'classroom_session_id' => $session->id,
                'duration_minutes' => 60,
                'order' => 1,
            ]);

        $lessonResponse->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.title', 'Lesson 1.1: WebRTC SFU Architecture')
            ->assertJsonPath('data.classroom_session.session_id', $session->session_id);

        // 5. Verify Public Course View displays syllabus
        $publicCourseResponse = $this->getJson("/api/v1/courses/{$courseId}");

        $publicCourseResponse->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.modules.0.title', 'Module 1: Real-Time Media Protocols')
            ->assertJsonPath('data.modules.0.lessons.0.title', 'Lesson 1.1: WebRTC SFU Architecture');
    }

    /**
     * Test authorization: teacher cannot modify another teacher's course.
     */
    public function test_teacher_cannot_modify_another_teachers_course(): void
    {
        $course = Course::create([
            'teacher_id' => $this->teacher->id,
            'title' => 'Secret Alan Turing Research',
            'status' => Course::STATUS_DRAFT,
        ]);

        $response = $this->actingAs($this->otherTeacher)
            ->putJson("/api/v1/teacher/courses/{$course->id}", [
                'title' => 'Tampered Title',
            ]);

        $response->assertStatus(404); // Scoped to teacher_id
    }

    /**
     * Test non-teacher (student) cannot create courses.
     */
    public function test_student_cannot_access_teacher_course_management(): void
    {
        $response = $this->actingAs($this->student)
            ->postJson('/api/v1/teacher/courses', [
                'title' => 'Unauthorized Student Course',
            ]);

        $response->assertStatus(403);
    }

    /**
     * Test student can enroll in a published course.
     */
    public function test_student_can_enroll_in_published_course(): void
    {
        $course = Course::create([
            'teacher_id' => $this->teacher->id,
            'title' => 'Discrete Mathematics Masterclass',
            'status' => Course::STATUS_PUBLISHED,
        ]);

        $response = $this->actingAs($this->student)
            ->postJson("/api/v1/courses/{$course->id}/enroll");

        $response->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('enrollment.course_id', $course->id)
            ->assertJsonPath('enrollment.status', 'active');

        $this->assertDatabaseHas('enrollments', [
            'user_id' => $this->student->id,
            'course_id' => $course->id,
            'status' => 'active',
        ]);
    }

    /**
     * Test student duplicate enrollment returns already enrolled message.
     */
    public function test_student_duplicate_enrollment_handled_gracefully(): void
    {
        $course = Course::create([
            'teacher_id' => $this->teacher->id,
            'title' => 'Cryptography 101',
            'status' => Course::STATUS_PUBLISHED,
        ]);

        // First enrollment
        $this->actingAs($this->student)
            ->postJson("/api/v1/courses/{$course->id}/enroll")
            ->assertStatus(201);

        // Second enrollment attempt
        $secondResponse = $this->actingAs($this->student)
            ->postJson("/api/v1/courses/{$course->id}/enroll");

        $secondResponse->assertStatus(200)
            ->assertJsonPath('already_enrolled', true);
    }

    /**
     * Test student can list their enrolled courses.
     */
    public function test_student_can_list_enrolled_courses(): void
    {
        $course = Course::create([
            'teacher_id' => $this->teacher->id,
            'title' => 'Distributed WebRTC Systems',
            'status' => Course::STATUS_PUBLISHED,
        ]);

        \App\Models\Enrollment::create([
            'user_id' => $this->student->id,
            'course_id' => $course->id,
            'status' => 'active',
            'progress_percentage' => 45,
        ]);

        $response = $this->actingAs($this->student)
            ->getJson('/api/v1/student/courses');

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.progress_percentage', 45)
            ->assertJsonPath('data.0.course.title', 'Distributed WebRTC Systems');
    }

    /**
     * Test student can update their course learning progress.
     */
    public function test_student_can_update_learning_progress(): void
    {
        $course = Course::create([
            'teacher_id' => $this->teacher->id,
            'title' => 'High-Performance Algorithms',
            'status' => Course::STATUS_PUBLISHED,
        ]);

        \App\Models\Enrollment::create([
            'user_id' => $this->student->id,
            'course_id' => $course->id,
            'status' => 'active',
            'progress_percentage' => 10,
        ]);

        $response = $this->actingAs($this->student)
            ->postJson("/api/v1/courses/{$course->id}/progress", [
                'progress_percentage' => 100,
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('enrollment.progress_percentage', 100)
            ->assertJsonPath('enrollment.status', 'completed');
    }

    /**
     * Test LiveKit token access gate blocks un-enrolled students and guests for course-tied sessions.
     */
    public function test_livekit_access_gate_blocks_unenrolled_participants_for_course_sessions(): void
    {
        // 1. Create a course, module, and live session
        $course = Course::create([
            'teacher_id' => $this->teacher->id,
            'title' => 'Restricted Masterclass',
            'status' => Course::STATUS_PUBLISHED,
        ]);

        $module = CourseModule::create([
            'course_id' => $course->id,
            'title' => 'Module 1',
        ]);

        $session = ClassroomSession::create([
            'user_id' => $this->teacher->id,
            'title' => 'Course Live Workshop',
            'status' => ClassroomSession::STATUS_ACTIVE,
            'started_at' => now(),
        ]);

        // Link session to lesson
        CourseLesson::create([
            'course_module_id' => $module->id,
            'title' => 'Lesson 1.1 Live',
            'type' => CourseLesson::TYPE_LIVE_SESSION,
            'classroom_session_id' => $session->id,
        ]);

        // A. Unauthenticated Guest attempt -> Blocked (403)
        $guestResponse = $this->postJson("/api/v1/sessions/{$session->session_id}/token");
        $guestResponse->assertStatus(403)
            ->assertJsonPath('requires_enrollment', true)
            ->assertJsonPath('course_id', $course->id);

        // B. Unenrolled Student attempt -> Blocked (403)
        Sanctum::actingAs($this->student);
        $studentResponse = $this->postJson("/api/v1/sessions/{$session->session_id}/token");
        $studentResponse->assertStatus(403)
            ->assertJsonPath('requires_enrollment', true);

        // C. Teacher (Host) -> Always Allowed (200)
        Sanctum::actingAs($this->teacher);
        $teacherResponse = $this->postJson("/api/v1/sessions/{$session->session_id}/token");
        $teacherResponse->assertStatus(200)
            ->assertJsonPath('participant.role', 'teacher');

        // D. Now student enrolls in course
        \App\Models\Enrollment::create([
            'user_id' => $this->student->id,
            'course_id' => $course->id,
            'status' => 'active',
        ]);

        // E. Enrolled Student attempt -> Allowed (200)!
        Sanctum::actingAs($this->student);
        $enrolledResponse = $this->postJson("/api/v1/sessions/{$session->session_id}/token");
        $enrolledResponse->assertStatus(200)
            ->assertJsonPath('participant.role', 'student');
    }
}
