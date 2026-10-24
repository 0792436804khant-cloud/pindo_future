<?php

namespace Tests\Feature;

use App\Models\ClassroomSession;
use App\Models\ContentReport;
use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ComplianceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    public function test_authenticated_user_can_submit_ugc_report(): void
    {
        $student = User::where('role', Role::STUDENT)->first();
        $teacher = User::where('role', Role::TEACHER)->first();

        $response = $this->actingAs($student, 'sanctum')
            ->postJson('/api/v1/compliance/report', [
                'reported_user_id' => $teacher->id,
                'reason' => 'inappropriate_content',
                'details' => 'This session had inappropriate material shared on whiteboard.',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('status', 'pending');

        $this->assertDatabaseHas('content_reports', [
            'reporter_id' => $student->id,
            'reported_user_id' => $teacher->id,
            'reason' => 'inappropriate_content',
            'status' => 'pending',
        ]);
    }

    public function test_unauthenticated_user_cannot_submit_report(): void
    {
        $response = $this->postJson('/api/v1/compliance/report', [
            'reason' => 'spam',
        ]);

        $response->assertStatus(401);
    }

    public function test_report_fails_with_invalid_reason(): void
    {
        $student = User::where('role', Role::STUDENT)->first();

        $response = $this->actingAs($student, 'sanctum')
            ->postJson('/api/v1/compliance/report', [
                'reason' => 'invalid_reason_string',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['reason']);
    }
}
