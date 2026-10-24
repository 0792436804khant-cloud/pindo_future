<?php

namespace Tests\Feature;

use App\Models\ClassroomSession;
use App\Models\User;
use App\Services\Streaming\LiveKitTokenService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class LiveKitTokenTest extends TestCase
{
    use RefreshDatabase;

    protected User $teacher;
    protected string $teacherToken;
    protected User $student;
    protected string $studentToken;
    protected ClassroomSession $session;
    protected LiveKitTokenService $tokenService;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();

        $this->teacher = User::where('email', 'teacher.demo@pindofuture.com')->first();
        $this->teacherToken = $this->teacher->createToken('TeacherDevice')->plainTextToken;

        $this->student = User::where('email', 'student.demo@pindofuture.com')->first();
        $this->studentToken = $this->student->createToken('StudentDevice')->plainTextToken;

        $this->session = $this->teacher->classroomSessions()->create([
            'title' => 'WebRTC SFU Live Class',
            'status' => ClassroomSession::STATUS_SCHEDULED,
            'max_participants' => 30000,
        ]);

        $this->tokenService = new LiveKitTokenService();
    }

    /**
     * Test host teacher receives publisher and room admin token.
     */
    public function test_teacher_receives_publisher_and_admin_token(): void
    {
        $response = $this->withHeader('Authorization', 'Bearer ' . $this->teacherToken)
            ->postJson("/api/v1/sessions/{$this->session->session_id}/token");

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('participant.role', 'teacher')
            ->assertJsonPath('participant.can_publish', true)
            ->assertJsonPath('participant.can_subscribe', true)
            ->assertJsonStructure(['token', 'server_url', 'session', 'participant']);

        $jwt = $response->json('token');
        $claims = $this->tokenService->validateToken($jwt);

        $this->assertEquals($this->session->session_id, $claims['video']['room']);
        $this->assertTrue($claims['video']['canPublish']);
        $this->assertTrue($claims['video']['canSubscribe']);
        $this->assertTrue($claims['video']['roomAdmin']);
    }

    /**
     * Test student receives subscriber-only token when session is active.
     */
    public function test_student_receives_subscriber_token_when_live(): void
    {
        // Teacher starts the session
        $this->session->start();

        $response = $this->withHeader('Authorization', 'Bearer ' . $this->studentToken)
            ->postJson("/api/v1/sessions/{$this->session->session_id}/token");

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('participant.role', 'student')
            ->assertJsonPath('participant.can_publish', false)
            ->assertJsonPath('participant.can_subscribe', true);

        $jwt = $response->json('token');
        $claims = $this->tokenService->validateToken($jwt);

        $this->assertEquals($this->session->session_id, $claims['video']['room']);
        $this->assertFalse($claims['video']['canPublish']); // Cannot stream video/mic by default
        $this->assertTrue($claims['video']['canSubscribe']);
        $this->assertFalse($claims['video']['roomAdmin']);
    }

    /**
     * Test student cannot enter before teacher starts the room.
     */
    public function test_student_cannot_generate_token_for_scheduled_session(): void
    {
        // Session is still scheduled
        $response = $this->withHeader('Authorization', 'Bearer ' . $this->studentToken)
            ->postJson("/api/v1/sessions/{$this->session->session_id}/token");

        $response->assertStatus(422)
            ->assertJsonPath('status', 'error')
            ->assertJsonPath('message', 'The classroom session has not started yet. Please wait for the instructor.');
    }

    /**
     * Test teacher CAN enter scheduled session early to verify equipment.
     */
    public function test_host_teacher_can_enter_scheduled_session_early(): void
    {
        $response = $this->withHeader('Authorization', 'Bearer ' . $this->teacherToken)
            ->postJson("/api/v1/sessions/{$this->session->session_id}/token");

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success');
    }

    /**
     * Test token generation fails if session has ended.
     */
    public function test_cannot_generate_token_for_ended_session(): void
    {
        $this->session->end();

        $response = $this->withHeader('Authorization', 'Bearer ' . $this->teacherToken)
            ->postJson("/api/v1/sessions/{$this->session->session_id}/token");

        $response->assertStatus(422)
            ->assertJsonPath('status', 'error');
    }

    /**
     * Test guest attendee can receive subscriber token for active session.
     */
    public function test_guest_attendee_receives_token_for_active_session(): void
    {
        $this->session->start();

        // No Authorization header, guest attendee
        $response = $this->postJson("/api/v1/sessions/{$this->session->session_id}/token", [
            'participant_name' => 'Guest Learner Bob',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('participant.role', 'guest')
            ->assertJsonPath('participant.can_publish', false)
            ->assertJsonPath('participant.can_subscribe', true);

        $jwt = $response->json('token');
        $claims = $this->tokenService->validateToken($jwt);

        $this->assertEquals('Guest Learner Bob', $claims['name']);
        $this->assertFalse($claims['video']['canPublish']);
    }

    /**
     * Test token verification endpoint.
     */
    public function test_token_verification_endpoint(): void
    {
        $this->session->start();

        $generateResponse = $this->withHeader('Authorization', 'Bearer ' . $this->teacherToken)
            ->postJson("/api/v1/sessions/{$this->session->session_id}/token");

        $validToken = $generateResponse->json('token');

        // 1. Verify valid token
        $verifyResponse = $this->postJson("/api/v1/sessions/{$this->session->session_id}/token/verify", [
            'token' => $validToken,
        ]);

        $verifyResponse->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('valid', true);

        // 2. Tampered token fails verification
        $tamperedToken = $validToken . 'tampered';
        $tamperedResponse = $this->postJson("/api/v1/sessions/{$this->session->session_id}/token/verify", [
            'token' => $tamperedToken,
        ]);

        $tamperedResponse->assertStatus(422)
            ->assertJsonPath('status', 'error')
            ->assertJsonPath('valid', false);
    }

    /**
     * Test student token contains anti-piracy watermark text.
     */
    public function test_student_token_contains_watermark_text(): void
    {
        $this->session->start();

        $response = $this->withHeader('Authorization', 'Bearer ' . $this->studentToken)
            ->postJson("/api/v1/sessions/{$this->session->session_id}/token");

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success');

        $watermark = $response->json('participant.watermark_text');
        $this->assertNotEmpty($watermark);
        $this->assertStringContainsString($this->student->name, $watermark);
    }

    /**
     * Test cohort live session blocks unenrolled student without session credits.
     */
    public function test_cohort_session_blocks_unenrolled_student_without_credits(): void
    {
        $cohort = \App\Models\StudyCohort::create([
            'cohort_code' => 'COH-TEST-99',
            'teacher_id' => $this->teacher->id,
            'name' => 'BAC Math VIP Cohort',
            'subject' => 'Mathématiques',
            'academic_level' => '3AS',
            'stream' => 'Mathématiques',
            'max_students' => 50,
            'monthly_price' => 3000,
            'is_active' => true,
        ]);

        $cohortSession = $this->teacher->classroomSessions()->create([
            'title' => 'Cohort Differential Equations Live',
            'status' => ClassroomSession::STATUS_ACTIVE,
            'cohort_id' => $cohort->id,
            'max_participants' => 100,
        ]);

        // Unenrolled student with 0 credits tries to join
        $response = $this->withHeader('Authorization', 'Bearer ' . $this->studentToken)
            ->postJson("/api/v1/sessions/{$cohortSession->session_id}/token");

        $response->assertStatus(403)
            ->assertJsonPath('status', 'error')
            ->assertJsonPath('requires_enrollment', true)
            ->assertJsonPath('cohort_id', $cohort->id);
    }

    /**
     * Test cohort live session allows enrolled student or student with session credit.
     */
    public function test_cohort_session_allows_enrolled_student_and_credits_deduction(): void
    {
        $cohort = \App\Models\StudyCohort::create([
            'cohort_code' => 'COH-TEST-100',
            'teacher_id' => $this->teacher->id,
            'name' => 'BAC Sciences Cohort',
            'subject' => 'Sciences',
            'academic_level' => '3AS',
            'stream' => 'Sciences Expérimentales',
            'max_students' => 50,
            'monthly_price' => 3500,
            'is_active' => true,
        ]);

        $cohortSession = $this->teacher->classroomSessions()->create([
            'title' => 'Cohort Genetics Live Session',
            'status' => ClassroomSession::STATUS_ACTIVE,
            'cohort_id' => $cohort->id,
            'max_participants' => 100,
        ]);

        // Give student 2 session credits in ledger
        \App\Models\CreditLedger::create([
            'student_id' => $this->student->id,
            'type' => 'voucher_grant',
            'credits_amount' => 2,
            'balance_after' => 2,
            'notes' => 'Test voucher credit',
        ]);

        $this->assertEquals(2, \App\Models\CreditLedger::getStudentBalance($this->student->id));

        // Now student requests LiveKit token
        $response = $this->withHeader('Authorization', 'Bearer ' . $this->studentToken)
            ->postJson("/api/v1/sessions/{$cohortSession->session_id}/token");

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('participant.role', 'student');

        // Verify 1 credit was deducted
        $this->assertEquals(1, \App\Models\CreditLedger::getStudentBalance($this->student->id));

        // Re-requesting token does not deduct a second credit for same session
        $this->withHeader('Authorization', 'Bearer ' . $this->studentToken)
            ->postJson("/api/v1/sessions/{$cohortSession->session_id}/token");

        $this->assertEquals(1, \App\Models\CreditLedger::getStudentBalance($this->student->id));
    }
}
