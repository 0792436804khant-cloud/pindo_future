<?php

namespace Tests\Feature;

use App\Models\ExamExercise;
use App\Models\ExamPaper;
use App\Models\ExamSimulation;
use App\Models\ParentStudent;
use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ExamBankTest extends TestCase
{
    use RefreshDatabase;

    private User $student;
    private User $parent;
    private ExamPaper $bacMath;
    private ExamPaper $bemMath;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed();

        $this->student = User::where('email', 'student.demo@pindofuture.com')->first();
        $this->parent = User::where('email', 'parent.demo@pindofuture.com')->first();

        $this->bacMath = ExamPaper::where('exam_code', 'BAC-2024-EXPSC-MATH-S1')->first();
        $this->bemMath = ExamPaper::where('exam_code', 'BEM-2024-MATH-S1')->first();
    }

    public function test_can_list_exam_papers_with_curriculum_filters(): void
    {
        // 1. All exams
        $response = $this->getJson('/api/v1/exams');
        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonCount(3, 'data');

        // 2. Filter by cycle: bac
        $bacResponse = $this->getJson('/api/v1/exams?cycle=bac');
        $bacResponse->assertStatus(200)
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('data.0.cycle', 'bac');

        // 3. Filter by cycle: bem
        $bemResponse = $this->getJson('/api/v1/exams?cycle=bem');
        $bemResponse->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.cycle', 'bem');

        // 4. Filter by stream
        $streamResponse = $this->getJson('/api/v1/exams?stream=experimental_sciences');
        $streamResponse->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.stream', 'experimental_sciences');

        // 5. Search
        $searchResponse = $this->getJson('/api/v1/exams?search=المتوسط');
        $searchResponse->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.exam_code', 'BEM-2024-MATH-S1');
    }

    public function test_can_retrieve_single_exam_paper_with_exercises(): void
    {
        $response = $this->getJson("/api/v1/exams/{$this->bacMath->id}");

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.exam.id', $this->bacMath->id)
            ->assertJsonPath('data.has_official_solution', true)
            ->assertJsonCount(4, 'data.exercises')
            ->assertJsonPath('data.exercises.0.title', 'التمرين الأول (04.5 نقاط) - المتتاليات العددية');

        // Verify view count increment
        $this->assertDatabaseHas('exam_papers', [
            'id' => $this->bacMath->id,
            'views_count' => 1,
        ]);
    }

    public function test_returns_404_for_non_existent_exam(): void
    {
        $response = $this->getJson('/api/v1/exams/99999');
        $response->assertStatus(404)
            ->assertJsonPath('status', 'error');
    }

    public function test_can_get_curriculum_subjects_and_streams_metadata(): void
    {
        $response = $this->getJson('/api/v1/exams/subjects');

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonStructure([
                'data' => [
                    'cycles',
                    'available_years',
                ],
            ]);
    }

    public function test_student_can_start_and_resume_simulation(): void
    {
        // 1. Unauthenticated request rejected
        $this->postJson("/api/v1/exams/{$this->bacMath->id}/simulations/start")
            ->assertStatus(401);

        // 2. Authenticated student starts simulation
        $startResponse = $this->actingAs($this->student, 'sanctum')
            ->postJson("/api/v1/exams/{$this->bacMath->id}/simulations/start");

        $startResponse->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.is_resumed', false)
            ->assertJsonPath('data.simulation.status', 'in_progress');

        $simulationId = $startResponse->json('data.simulation.id');

        // 3. Starting again resumes in-progress simulation
        $resumeResponse = $this->actingAs($this->student, 'sanctum')
            ->postJson("/api/v1/exams/{$this->bacMath->id}/simulations/start");

        $resumeResponse->assertStatus(200)
            ->assertJsonPath('data.is_resumed', true)
            ->assertJsonPath('data.simulation.id', $simulationId);
    }

    public function test_student_can_update_simulation_progress(): void
    {
        $simulation = ExamSimulation::create([
            'user_id' => $this->student->id,
            'exam_paper_id' => $this->bacMath->id,
            'started_at' => now(),
            'status' => 'in_progress',
        ]);

        $response = $this->actingAs($this->student, 'sanctum')
            ->putJson("/api/v1/exams/simulations/{$simulation->id}/progress", [
                'time_spent_seconds' => 3600,
                'completed_exercises' => [1, 2],
                'student_notes' => 'انتهيت من التمرين الأول في 40 دقيقة',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.time_spent_seconds', 3600)
            ->assertJsonPath('data.completed_exercises', [1, 2]);

        $this->assertDatabaseHas('exam_simulations', [
            'id' => $simulation->id,
            'time_spent_seconds' => 3600,
        ]);
    }

    public function test_student_can_finish_simulation_with_self_assessment(): void
    {
        $simulation = ExamSimulation::create([
            'user_id' => $this->student->id,
            'exam_paper_id' => $this->bacMath->id,
            'started_at' => now()->subMinutes(180),
            'status' => 'in_progress',
        ]);

        // Validation error on score > 20
        $this->actingAs($this->student, 'sanctum')
            ->postJson("/api/v1/exams/simulations/{$simulation->id}/finish", [
                'self_assessment_score' => 25.0,
            ])
            ->assertStatus(422);

        // Valid submission
        $response = $this->actingAs($this->student, 'sanctum')
            ->postJson("/api/v1/exams/simulations/{$simulation->id}/finish", [
                'self_assessment_score' => 17.50,
                'time_spent_seconds' => 10800,
                'student_notes' => 'راجعت سلم التنقيط الوزاري وحصلت على 17.5/20',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('data.simulation.status', 'completed')
            ->assertJsonPath('data.simulation.self_assessment_score', 17.5);

        $this->assertDatabaseHas('exam_simulations', [
            'id' => $simulation->id,
            'status' => 'completed',
            'self_assessment_score' => 17.50,
        ]);
    }

    public function test_student_can_view_personal_simulation_history_and_metrics(): void
    {
        ExamSimulation::create([
            'user_id' => $this->student->id,
            'exam_paper_id' => $this->bacMath->id,
            'started_at' => now()->subDays(1),
            'ended_at' => now()->subDays(1)->addMinutes(180),
            'time_spent_seconds' => 10800,
            'self_assessment_score' => 16.0,
            'status' => 'completed',
        ]);

        $response = $this->actingAs($this->student, 'sanctum')
            ->getJson('/api/v1/student/exam-simulations');

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('metrics.total_simulations_completed', 1)
            ->assertJsonPath('metrics.average_score', 16)
            ->assertJsonPath('metrics.total_study_minutes', 180);
    }

    public function test_parent_oversight_includes_student_exam_simulations(): void
    {
        ExamSimulation::create([
            'user_id' => $this->student->id,
            'exam_paper_id' => $this->bacMath->id,
            'started_at' => now()->subDays(1),
            'ended_at' => now()->subDays(1)->addMinutes(120),
            'time_spent_seconds' => 7200,
            'self_assessment_score' => 18.0,
            'status' => 'completed',
        ]);

        $response = $this->actingAs($this->parent, 'sanctum')
            ->getJson("/api/v1/parent/children/{$this->student->id}/academics");

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonCount(1, 'exam_simulations')
            ->assertJsonPath('exam_simulations.0.score', 18)
            ->assertJsonPath('exam_simulations.0.exam_title', $this->bacMath->title);
    }
}
