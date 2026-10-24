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
        Schema::create('session_recordings', function (Blueprint $table) {
            $table->id();
            $table->string('recording_code', 30)->unique();
            $table->foreignId('classroom_session_id')->constrained('classroom_sessions')->cascadeOnDelete();
            $table->foreignId('cohort_id')->nullable()->constrained('study_cohorts')->cascadeOnDelete();
            $table->foreignId('teacher_id')->constrained('users')->cascadeOnDelete();
            $table->string('title', 200);
            $table->text('description')->nullable();
            $table->string('video_storage_path', 500);
            $table->integer('duration_seconds')->default(0);
            $table->unsignedBigInteger('file_size_bytes')->nullable();
            $table->boolean('is_published')->default(true);
            $table->unsignedInteger('views_count')->default(0);
            $table->timestamps();

            $table->index(['cohort_id', 'is_published']);
            $table->index(['teacher_id', 'created_at']);
        });

        Schema::create('cohort_materials', function (Blueprint $table) {
            $table->id();
            $table->string('material_code', 30)->unique();
            $table->foreignId('cohort_id')->constrained('study_cohorts')->cascadeOnDelete();
            $table->foreignId('teacher_id')->constrained('users')->cascadeOnDelete();
            $table->string('title', 200);
            $table->text('description')->nullable();
            $table->string('file_path', 500);
            $table->string('file_type', 50)->default('pdf'); // 'pdf', 'summary', 'exercise', 'exam'
            $table->unsignedBigInteger('file_size_bytes')->default(0);
            $table->boolean('is_published')->default(true);
            $table->unsignedInteger('downloads_count')->default(0);
            $table->timestamps();

            $table->index(['cohort_id', 'is_published']);
            $table->index(['teacher_id', 'created_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('cohort_materials');
        Schema::dropIfExists('session_recordings');
    }
};
