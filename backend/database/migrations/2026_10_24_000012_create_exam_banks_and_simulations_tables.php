<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. Exam Papers Table (National Exam Papers: BEM & BAC Official Papers & Solutions)
        Schema::create('exam_papers', function (Blueprint $table) {
            $table->id();
            $table->string('exam_code', 60)->unique()->index();
            $table->string('title');
            $table->enum('cycle', ['bem', 'bac'])->index();
            $table->string('stream', 100)->nullable()->index(); // Nullable for BEM (unified cycle)
            $table->string('subject', 50)->index();
            $table->string('subject_name_ar', 100);
            $table->unsignedSmallInteger('year')->index();
            $table->string('session_type', 30)->default('main'); // main, exceptional
            $table->unsignedTinyInteger('option_number')->default(1); // 1 = Sujet 1, 2 = Sujet 2
            $table->unsignedSmallInteger('duration_minutes')->default(180); // in minutes
            $table->unsignedTinyInteger('coefficient')->default(5);
            $table->unsignedTinyInteger('total_score')->default(20);
            $table->string('paper_pdf_url')->nullable();
            $table->string('solution_pdf_url')->nullable();
            $table->text('description')->nullable();
            $table->string('difficulty_level', 20)->default('medium'); // easy, medium, hard
            $table->unsignedTinyInteger('exercise_count')->default(4);
            $table->unsignedInteger('views_count')->default(0);
            $table->unsignedInteger('downloads_count')->default(0);
            $table->boolean('is_published')->default(true)->index();
            $table->timestamps();
        });

        // 2. Exam Exercises Table (Individual Exercises & Official Ministerial Marking Rubrics)
        Schema::create('exam_exercises', function (Blueprint $table) {
            $table->id();
            $table->foreignId('exam_paper_id')->constrained('exam_papers')->cascadeOnDelete();
            $table->unsignedTinyInteger('exercise_number');
            $table->string('title');
            $table->string('topic')->nullable();
            $table->decimal('points', 4, 2)->default(4.00);
            $table->text('instructions')->nullable();
            $table->json('official_marking_rubric')->nullable();
            $table->text('solution_explanation')->nullable();
            $table->timestamps();

            $table->index(['exam_paper_id', 'exercise_number']);
        });

        // 3. Exam Simulations Table (Student Timed Mocks & Self-Assessments)
        Schema::create('exam_simulations', function (Blueprint $table) {
            $table->id();
            $table->string('simulation_code', 50)->unique()->index();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('exam_paper_id')->constrained('exam_papers')->cascadeOnDelete();
            $table->timestamp('started_at');
            $table->timestamp('ended_at')->nullable();
            $table->unsignedInteger('time_spent_seconds')->default(0);
            $table->json('completed_exercises')->nullable();
            $table->decimal('self_assessment_score', 4, 2)->nullable();
            $table->text('student_notes')->nullable();
            $table->enum('status', ['in_progress', 'completed', 'abandoned'])->default('in_progress')->index();
            $table->timestamps();

            $table->index(['user_id', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('exam_simulations');
        Schema::dropIfExists('exam_exercises');
        Schema::dropIfExists('exam_papers');
    }
};
