<?php

namespace Tests\Feature;

use App\Models\ClassroomSession;
use App\Models\ClassroomWhiteboardSnapshot;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WhiteboardSnapshotTest extends TestCase
{
    use RefreshDatabase;

    protected User $teacher;
    protected string $teacherToken;
    protected User $student;
    protected string $studentToken;
    protected ClassroomSession $session;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();

        $this->teacher = User::where('email', 'teacher.demo@pindofuture.com')->first();
        $this->teacherToken = $this->teacher->createToken('TeacherDevice')->plainTextToken;

        $this->student = User::where('email', 'student.demo@pindofuture.com')->first();
        $this->studentToken = $this->student->createToken('StudentDevice')->plainTextToken;

        $this->session = ClassroomSession::create([
            'session_id' => 'SES_WHITEBOARD_TEST',
            'user_id' => $this->teacher->id,
            'title' => 'Interactive Calculus & Graphing Masterclass',
            'status' => ClassroomSession::STATUS_ACTIVE,
            'scheduled_at' => now(),
            'started_at' => now(),
        ]);
    }

    public function test_teacher_can_save_whiteboard_vector_snapshot(): void
    {
        $vectorPayload = [
            [
                'id' => 'stk_1',
                'tool' => 'pen',
                'color_value' => 0xFF0D9488,
                'stroke_width' => 4.0,
                'points' => [
                    ['x' => 0.1, 'y' => 0.2],
                    ['x' => 0.15, 'y' => 0.25],
                ],
                'author_identity' => 'TEA-DEMO-01',
                'author_name' => 'Demo Instructor',
            ],
            [
                'id' => 'stk_2',
                'tool' => 'coordinateSystem',
                'color_value' => 0xFF2563EB,
                'stroke_width' => 2.0,
                'points' => [
                    ['x' => 0.5, 'y' => 0.5],
                ],
                'author_identity' => 'TEA-DEMO-01',
                'author_name' => 'Demo Instructor',
            ],
        ];

        $response = $this->withHeader('Authorization', 'Bearer ' . $this->teacherToken)
            ->postJson("/api/v1/sessions/{$this->session->session_id}/whiteboard/snapshots", [
                'snapshot_title' => 'Functions & Limits Derivation Slide 1',
                'vector_data' => $vectorPayload,
                'stroke_count' => 2,
            ]);

        $response->assertStatus(201)
            ->assertJson([
                'status' => 'success',
                'message' => 'Whiteboard snapshot saved successfully.',
                'snapshot' => [
                    'snapshot_title' => 'Functions & Limits Derivation Slide 1',
                    'version' => 1,
                    'stroke_count' => 2,
                    'author_name' => $this->teacher->name,
                ],
            ]);

        $this->assertDatabaseHas('classroom_whiteboard_snapshots', [
            'session_id' => $this->session->session_id,
            'version' => 1,
            'snapshot_title' => 'Functions & Limits Derivation Slide 1',
        ]);
    }

    public function test_unauthenticated_user_cannot_save_snapshot(): void
    {
        $response = $this->postJson("/api/v1/sessions/{$this->session->session_id}/whiteboard/snapshots", [
            'vector_data' => [['id' => '1']],
        ]);

        $response->assertStatus(401);
    }

    public function test_saving_snapshot_validates_vector_data(): void
    {
        $response = $this->withHeader('Authorization', 'Bearer ' . $this->teacherToken)
            ->postJson("/api/v1/sessions/{$this->session->session_id}/whiteboard/snapshots", [
                'snapshot_title' => 'Empty Slide',
                // vector_data is missing
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['vector_data']);
    }

    public function test_can_retrieve_latest_whiteboard_snapshot(): void
    {
        // 1. When no snapshot exists
        $emptyResponse = $this->getJson("/api/v1/sessions/{$this->session->session_id}/whiteboard/latest");
        $emptyResponse->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'session_id' => $this->session->session_id,
                'has_snapshot' => false,
                'snapshot' => null,
            ]);

        // 2. When snapshot exists
        ClassroomWhiteboardSnapshot::create([
            'session_id' => $this->session->session_id,
            'author_id' => $this->teacher->id,
            'snapshot_title' => 'Trigonometry Review Slide v1',
            'vector_data' => [['id' => 'stk_sample']],
            'stroke_count' => 1,
            'version' => 1,
        ]);

        $response = $this->getJson("/api/v1/sessions/{$this->session->session_id}/whiteboard/latest");
        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'session_id' => $this->session->session_id,
                'has_snapshot' => true,
                'snapshot' => [
                    'snapshot_title' => 'Trigonometry Review Slide v1',
                    'version' => 1,
                    'stroke_count' => 1,
                ],
            ]);
    }

    public function test_version_auto_increments_for_subsequent_snapshots(): void
    {
        // Snapshot 1
        $this->withHeader('Authorization', 'Bearer ' . $this->teacherToken)
            ->postJson("/api/v1/sessions/{$this->session->session_id}/whiteboard/snapshots", [
                'snapshot_title' => 'Part 1',
                'vector_data' => [['id' => '1']],
            ])->assertStatus(201);

        // Snapshot 2
        $resp2 = $this->withHeader('Authorization', 'Bearer ' . $this->teacherToken)
            ->postJson("/api/v1/sessions/{$this->session->session_id}/whiteboard/snapshots", [
                'snapshot_title' => 'Part 2',
                'vector_data' => [['id' => '2'], ['id' => '3']],
            ]);

        $resp2->assertStatus(201)
            ->assertJsonPath('snapshot.version', 2);

        // Verify latest returns version 2
        $latest = $this->getJson("/api/v1/sessions/{$this->session->session_id}/whiteboard/latest");
        $latest->assertStatus(200)
            ->assertJsonPath('snapshot.version', 2)
            ->assertJsonPath('snapshot.snapshot_title', 'Part 2');
    }

    public function test_can_retrieve_snapshot_history(): void
    {
        ClassroomWhiteboardSnapshot::create([
            'session_id' => $this->session->session_id,
            'author_id' => $this->teacher->id,
            'snapshot_title' => 'Slide 1',
            'vector_data' => [],
            'stroke_count' => 0,
            'version' => 1,
        ]);

        ClassroomWhiteboardSnapshot::create([
            'session_id' => $this->session->session_id,
            'author_id' => $this->teacher->id,
            'snapshot_title' => 'Slide 2',
            'vector_data' => [],
            'stroke_count' => 5,
            'version' => 2,
        ]);

        $response = $this->getJson("/api/v1/sessions/{$this->session->session_id}/whiteboard/history");
        $response->assertStatus(200)
            ->assertJsonStructure([
                'status',
                'session_id',
                'snapshots' => [
                    '*' => ['id', 'snapshot_title', 'version', 'stroke_count', 'author_name', 'created_at'],
                ],
            ]);

        $snapshots = $response->json('snapshots');
        $this->assertCount(2, $snapshots);
        $this->assertEquals(2, $snapshots[0]['version']); // Descending version order
        $this->assertEquals(1, $snapshots[1]['version']);
    }
}
