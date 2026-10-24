<?php

namespace Tests\Feature;

use App\Models\ClassroomSession;
use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TeacherSessionTest extends TestCase
{
    use RefreshDatabase;

    protected User $teacher;
    protected string $teacherToken;
    protected User $student;
    protected string $studentToken;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();

        $this->teacher = User::where('email', 'teacher.demo@pindofuture.com')->first();
        $this->teacherToken = $this->teacher->createToken('TeacherDevice')->plainTextToken;

        $this->student = User::where('email', 'student.demo@pindofuture.com')->first();
        $this->studentToken = $this->student->createToken('StudentDevice')->plainTextToken;
    }

    /**
     * Test teacher can create dynamic classroom session with auto-generated Session ID.
     */
    public function test_teacher_can_create_dynamic_classroom_session(): void
    {
        $response = $this->withHeader('Authorization', 'Bearer ' . $this->teacherToken)
            ->postJson('/api/v1/teacher/sessions', [
                'title' => 'Quantum Mechanics & WebRTC SFU Scaling',
                'description' => 'A masterclass on scaling concurrent classroom sessions up to 30,000 users.',
                'max_participants' => 30000,
                'settings' => [
                    'allow_chat' => true,
                    'mute_on_entry' => true,
                ],
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('session.title', 'Quantum Mechanics & WebRTC SFU Scaling')
            ->assertJsonPath('session.max_participants', 30000)
            ->assertJsonPath('session.status', 'scheduled')
            ->assertJsonPath('session.teacher.teacher_id', 'TCH_123');

        $sessionId = $response->json('session.session_id');
        $this->assertNotEmpty($sessionId);
        $this->assertStringStartsWith('SES_', $sessionId);

        $this->assertDatabaseHas('classroom_sessions', [
            'session_id' => $sessionId,
            'user_id' => $this->teacher->id,
            'max_participants' => 30000,
        ]);
    }

    /**
     * Test student is forbidden from creating classroom sessions.
     */
    public function test_student_cannot_create_classroom_session(): void
    {
        $response = $this->withHeader('Authorization', 'Bearer ' . $this->studentToken)
            ->postJson('/api/v1/teacher/sessions', [
                'title' => 'Unauthorized Session',
            ]);

        $response->assertStatus(403)
            ->assertJsonPath('status', 'error');
    }

    /**
     * Test teacher can list their sessions.
     */
    public function test_teacher_can_list_their_sessions(): void
    {
        $this->teacher->classroomSessions()->create([
            'title' => 'Intro to Algorithms',
            'status' => 'scheduled',
        ]);

        $response = $this->withHeader('Authorization', 'Bearer ' . $this->teacherToken)
            ->getJson('/api/v1/teacher/sessions');

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonCount(2, 'data');
    }

    /**
     * Test teacher can transition session to live.
     */
    public function test_teacher_can_start_session(): void
    {
        $session = $this->teacher->classroomSessions()->create([
            'title' => 'Live Physics Lab',
            'status' => 'scheduled',
        ]);

        $response = $this->withHeader('Authorization', 'Bearer ' . $this->teacherToken)
            ->postJson("/api/v1/teacher/sessions/{$session->session_id}/start");

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('session.status', 'active')
            ->assertJsonPath('session.is_live', true);

        $this->assertEquals('active', $session->fresh()->status);
        $this->assertNotNull($session->fresh()->started_at);
    }

    /**
     * Test teacher can end a session.
     */
    public function test_teacher_can_end_session(): void
    {
        $session = $this->teacher->classroomSessions()->create([
            'title' => 'Calculus I',
            'status' => 'active',
            'started_at' => now(),
        ]);

        $response = $this->withHeader('Authorization', 'Bearer ' . $this->teacherToken)
            ->postJson("/api/v1/teacher/sessions/{$session->session_id}/end");

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('session.status', 'ended')
            ->assertJsonPath('session.is_live', false);

        $this->assertEquals('ended', $session->fresh()->status);
        $this->assertNotNull($session->fresh()->ended_at);
    }

    /**
     * Test cannot restart ended session.
     */
    public function test_cannot_restart_ended_session(): void
    {
        $session = $this->teacher->classroomSessions()->create([
            'title' => 'Ended Lecture',
            'status' => 'ended',
            'ended_at' => now(),
        ]);

        $response = $this->withHeader('Authorization', 'Bearer ' . $this->teacherToken)
            ->postJson("/api/v1/teacher/sessions/{$session->session_id}/start");

        $response->assertStatus(422)
            ->assertJsonPath('status', 'error');
    }

    /**
     * Test attendee can look up session by Session ID.
     */
    public function test_attendee_can_lookup_session_by_session_id(): void
    {
        $session = $this->teacher->classroomSessions()->create([
            'title' => 'Open Masterclass',
            'status' => 'active',
            'started_at' => now(),
        ]);

        // Public lookup without authentication
        $response = $this->getJson("/api/v1/sessions/{$session->session_id}");

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('session.session_id', $session->session_id)
            ->assertJsonPath('session.title', 'Open Masterclass')
            ->assertJsonPath('session.is_live', true)
            ->assertJsonPath('session.teacher.teacher_id', 'TCH_123');
    }

    /**
     * Test teacher platform profile and deep link retrieval and updates.
     */
    public function test_teacher_platform_profile_and_deep_link(): void
    {
        $response = $this->withHeader('Authorization', 'Bearer ' . $this->teacherToken)
            ->getJson('/api/v1/teacher/platform');

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('platform.teacher.teacher_id', 'TCH_123')
            ->assertJsonStructure(['platform' => ['teacher', 'platform', 'metrics']]);

        // Update platform bio and headline
        $updateResponse = $this->withHeader('Authorization', 'Bearer ' . $this->teacherToken)
            ->putJson('/api/v1/teacher/platform', [
                'headline' => 'Senior Computer Scientist & Educator',
                'bio' => 'Teaching cryptography and computation theory.',
                'website_url' => 'https://alanturing.org',
            ]);

        $updateResponse->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('platform.platform.headline', 'Senior Computer Scientist & Educator')
            ->assertJsonPath('platform.platform.website_url', 'https://alanturing.org');
    }
}
