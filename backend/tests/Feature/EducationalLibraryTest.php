<?php

namespace Tests\Feature;

use App\Models\ClassroomSession;
use App\Models\CohortMember;
use App\Models\Role;
use App\Models\StudyCohort;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class EducationalLibraryTest extends TestCase
{
    use RefreshDatabase;

    protected User $teacher;
    protected string $teacherToken;
    protected User $teacher2;
    protected string $teacher2Token;
    protected User $student;
    protected string $studentToken;
    protected StudyCohort $cohort;
    protected ClassroomSession $session;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();

        $this->teacher = User::where('email', 'teacher.demo@pindofuture.com')->first();
        $this->teacherToken = $this->teacher->createToken('TeacherDevice')->plainTextToken;

        $teacherRole = Role::firstOrCreate(['name' => Role::TEACHER], ['label' => 'Teacher']);
        $this->teacher2 = User::create([
            'name' => 'Teacher Two',
            'email' => 'teacher2.demo@pindofuture.com',
            'password' => bcrypt('password'),
            'role' => Role::TEACHER,
            'teacher_id' => 'TEA-99999',
        ]);
        $this->teacher2->roles()->attach($teacherRole);
        $this->teacher2Token = $this->teacher2->createToken('Teacher2Device')->plainTextToken;

        $this->student = User::where('email', 'student.demo@pindofuture.com')->first();
        $this->studentToken = $this->student->createToken('StudentDevice')->plainTextToken;

        $this->cohort = StudyCohort::create([
            'cohort_code' => 'COH-LIB-1',
            'teacher_id' => $this->teacher->id,
            'name' => 'BAC Math 2026 Elite',
            'subject' => 'Mathématiques',
            'academic_level' => '3AS',
            'stream' => 'Mathématiques',
            'max_students' => 50,
            'monthly_price' => 3000,
            'is_active' => true,
        ]);

        $this->session = $this->teacher->classroomSessions()->create([
            'title' => 'Complex Numbers Chapter 1',
            'cohort_id' => $this->cohort->id,
            'status' => ClassroomSession::STATUS_ENDED,
        ]);
    }

    /**
     * Test teacher can publish recording and educational material.
     */
    public function test_teacher_can_publish_recording_and_material(): void
    {
        // 1. Publish recording
        $recResponse = $this->withHeader('Authorization', 'Bearer ' . $this->teacherToken)
            ->postJson("/api/v1/teacher/cohorts/{$this->cohort->id}/recordings", [
                'classroom_session_id' => $this->session->id,
                'title' => 'Complex Numbers Lecture Recording',
                'description' => 'Complete breakdown of trigonometric and exponential forms.',
                'video_storage_path' => 'recordings/SES_COMPLEX_01.mp4',
                'duration_seconds' => 3600,
            ]);

        $recResponse->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('recording.title', 'Complex Numbers Lecture Recording');

        $recordingId = $recResponse->json('recording.id');

        // 2. Publish material
        $matResponse = $this->withHeader('Authorization', 'Bearer ' . $this->teacherToken)
            ->postJson("/api/v1/teacher/cohorts/{$this->cohort->id}/materials", [
                'title' => 'Summary Cheatsheet PDF',
                'description' => 'All laws of complex numbers for Baccalaureate.',
                'file_path' => 'materials/math_bac_cheatsheet.pdf',
                'file_type' => 'pdf',
                'file_size_bytes' => 1024000,
            ]);

        $matResponse->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('material.title', 'Summary Cheatsheet PDF');

        // 3. List recordings and materials as teacher
        $listRecResponse = $this->withHeader('Authorization', 'Bearer ' . $this->teacherToken)
            ->getJson("/api/v1/teacher/cohorts/{$this->cohort->id}/recordings");

        $listRecResponse->assertStatus(200)
            ->assertJsonCount(1, 'recordings');

        $listMatResponse = $this->withHeader('Authorization', 'Bearer ' . $this->teacherToken)
            ->getJson("/api/v1/teacher/cohorts/{$this->cohort->id}/materials");

        $listMatResponse->assertStatus(200)
            ->assertJsonCount(1, 'materials');
    }

    /**
     * Test teacher cannot publish to another teacher's cohort.
     */
    public function test_teacher_cannot_publish_to_another_teachers_cohort(): void
    {
        $response = $this->withHeader('Authorization', 'Bearer ' . $this->teacher2Token)
            ->postJson("/api/v1/teacher/cohorts/{$this->cohort->id}/recordings", [
                'classroom_session_id' => $this->session->id,
                'title' => 'Unauthorized Recording',
                'video_storage_path' => 'recordings/unauth.mp4',
            ]);

        $response->assertStatus(404);
    }

    /**
     * Test student library access gate: unsubscribed vs subscribed.
     */
    public function test_student_library_access_gate_and_watermark_streaming(): void
    {
        // Teacher publishes a recording and a material
        $rec = \App\Models\SessionRecording::create([
            'classroom_session_id' => $this->session->id,
            'cohort_id' => $this->cohort->id,
            'teacher_id' => $this->teacher->id,
            'title' => 'Integrals and Primitives Lecture',
            'video_storage_path' => 'recordings/integrals.mp4',
            'duration_seconds' => 4200,
            'is_published' => true,
        ]);

        $mat = \App\Models\CohortMaterial::create([
            'cohort_id' => $this->cohort->id,
            'teacher_id' => $this->teacher->id,
            'title' => 'Integration Exercises with Corrections',
            'file_path' => 'materials/integrals_exercises.pdf',
            'file_type' => 'pdf',
            'file_size_bytes' => 500000,
            'is_published' => true,
        ]);

        // 1. Unsubscribed student views library overview
        $overviewResponse = $this->withHeader('Authorization', 'Bearer ' . $this->studentToken)
            ->getJson("/api/v1/student/cohorts/{$this->cohort->id}/library");

        $overviewResponse->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('is_subscribed', false)
            ->assertJsonPath('requires_subscription', true);

        // 2. Unsubscribed student attempts to stream recording => 403 Forbidden
        $streamForbidden = $this->withHeader('Authorization', 'Bearer ' . $this->studentToken)
            ->getJson("/api/v1/student/recordings/{$rec->id}/stream");

        $streamForbidden->assertStatus(403)
            ->assertJsonPath('status', 'error')
            ->assertJsonPath('requires_subscription', true);

        // 3. Unsubscribed student attempts to download material => 403 Forbidden
        $downloadForbidden = $this->withHeader('Authorization', 'Bearer ' . $this->studentToken)
            ->getJson("/api/v1/student/materials/{$mat->id}/access");

        $downloadForbidden->assertStatus(403)
            ->assertJsonPath('status', 'error')
            ->assertJsonPath('requires_subscription', true);

        // 4. Enroll student in cohort as active member
        CohortMember::create([
            'cohort_id' => $this->cohort->id,
            'student_id' => $this->student->id,
            'status' => 'active',
            'joined_at' => now(),
        ]);

        // 5. Now student streams recording => 200 OK with signed URL and dynamic watermark
        $streamResponse = $this->withHeader('Authorization', 'Bearer ' . $this->studentToken)
            ->getJson("/api/v1/student/recordings/{$rec->id}/stream");

        $streamResponse->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonStructure(['stream_url', 'expires_at', 'watermark']);

        $watermark = $streamResponse->json('watermark.watermark_text');
        $this->assertStringContainsString($this->student->name, $watermark);

        // 6. Student downloads material => 200 OK with signed URL
        $downloadResponse = $this->withHeader('Authorization', 'Bearer ' . $this->studentToken)
            ->getJson("/api/v1/student/materials/{$mat->id}/access");

        $downloadResponse->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonStructure(['download_url', 'expires_at']);
    }
}
