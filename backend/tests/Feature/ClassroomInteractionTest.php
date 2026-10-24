<?php

namespace Tests\Feature;

use App\Models\ClassroomAttendance;
use App\Models\ClassroomMessage;
use App\Models\ClassroomSession;
use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ClassroomInteractionTest extends TestCase
{
    use RefreshDatabase;

    private User $teacher;
    private User $student;
    private ClassroomSession $session;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed();

        $this->teacher = User::where('role', Role::TEACHER)->first();
        $this->student = User::where('role', Role::STUDENT)->first();

        $this->session = ClassroomSession::create([
            'session_id' => 'SES_TEST_PH4',
            'user_id' => $this->teacher->id,
            'title' => 'Quantum Computing 101',
            'status' => ClassroomSession::STATUS_ACTIVE,
            'started_at' => now(),
        ]);
    }

    public function test_authenticated_user_can_send_chat_message(): void
    {
        Sanctum::actingAs($this->student);

        $response = $this->postJson("/api/v1/sessions/{$this->session->session_id}/messages", [
            'message' => 'Hello Professor! When will Q&A start?',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.message', 'Hello Professor! When will Q&A start?')
            ->assertJsonPath('data.sender_name', $this->student->name)
            ->assertJsonPath('data.sender_role', 'student');

        $this->assertDatabaseHas('classroom_messages', [
            'session_id' => $this->session->session_id,
            'user_id' => $this->student->id,
            'message' => 'Hello Professor! When will Q&A start?',
        ]);
    }

    public function test_cannot_post_message_to_ended_session(): void
    {
        $this->session->end();

        Sanctum::actingAs($this->student);

        $response = $this->postJson("/api/v1/sessions/{$this->session->session_id}/messages", [
            'message' => 'Is anyone still here?',
        ]);

        $response->assertStatus(403)
            ->assertJsonPath('status', 'error');
    }

    public function test_can_retrieve_session_messages(): void
    {
        ClassroomMessage::create([
            'session_id' => $this->session->session_id,
            'user_id' => $this->teacher->id,
            'message' => 'Welcome to class everyone!',
            'is_pinned' => true,
        ]);

        ClassroomMessage::create([
            'session_id' => $this->session->session_id,
            'user_id' => $this->student->id,
            'message' => 'Glad to be here!',
        ]);

        Sanctum::actingAs($this->student);

        $response = $this->getJson("/api/v1/sessions/{$this->session->session_id}/messages");

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('count', 2)
            ->assertJsonPath('messages.0.message', 'Welcome to class everyone!')
            ->assertJsonPath('messages.0.sender_role', 'teacher')
            ->assertJsonPath('messages.0.is_pinned', true);
    }

    public function test_attendance_join_and_leave_lifecycle(): void
    {
        Sanctum::actingAs($this->student);

        // Join
        $joinResponse = $this->postJson("/api/v1/sessions/{$this->session->session_id}/attendance/join");

        $joinResponse->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('active_attendees', 1);

        $this->assertDatabaseHas('classroom_attendances', [
            'session_id' => $this->session->session_id,
            'user_id' => $this->student->id,
            'left_at' => null,
        ]);

        // Leave
        $leaveResponse = $this->postJson("/api/v1/sessions/{$this->session->session_id}/attendance/leave");

        $leaveResponse->assertStatus(200)
            ->assertJsonPath('status', 'success');

        $this->assertDatabaseMissing('classroom_attendances', [
            'session_id' => $this->session->session_id,
            'user_id' => $this->student->id,
            'left_at' => null,
        ]);
    }
}
