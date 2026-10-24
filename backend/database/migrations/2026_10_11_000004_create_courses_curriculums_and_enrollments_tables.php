<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations for Phase 5: Courses, Modules, Lessons, and Enrollments.
     */
    public function up(): void
    {
        // 1. Courses Table
        Schema::create('courses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('teacher_id')->constrained('users')->cascadeOnDelete();
            $table->string('title');
            $table->string('slug')->unique()->index();
            $table->text('description')->nullable();
            $table->string('category')->default('General');
            $table->decimal('price', 8, 2)->default(0.00); // 0.00 = Free
            $table->string('thumbnail_url')->nullable();
            $table->enum('status', ['draft', 'published', 'archived'])->default('draft')->index();
            $table->timestamps();
        });

        // 2. Course Modules (Chapters / Sections)
        Schema::create('course_modules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('course_id')->constrained('courses')->cascadeOnDelete();
            $table->string('title');
            $table->unsignedInteger('order')->default(1);
            $table->timestamps();
        });

        // 3. Course Lessons (Live Classroom Sessions, Video Recordings, Resources)
        Schema::create('course_lessons', function (Blueprint $table) {
            $table->id();
            $table->foreignId('course_module_id')->constrained('course_modules')->cascadeOnDelete();
            $table->string('title');
            $table->enum('type', ['live_session', 'video', 'document'])->default('live_session');
            $table->foreignId('classroom_session_id')->nullable()->constrained('classroom_sessions')->nullOnDelete();
            $table->unsignedInteger('duration_minutes')->default(45);
            $table->unsignedInteger('order')->default(1);
            $table->string('content_url')->nullable();
            $table->timestamps();
        });

        // 4. Student Course Enrollments
        Schema::create('enrollments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete(); // Student
            $table->foreignId('course_id')->constrained('courses')->cascadeOnDelete();
            $table->enum('status', ['active', 'completed', 'cancelled'])->default('active')->index();
            $table->timestamp('enrolled_at')->useCurrent();
            $table->unsignedTinyInteger('progress_percentage')->default(0); // 0 - 100%
            $table->timestamps();

            $table->unique(['user_id', 'course_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('enrollments');
        Schema::dropIfExists('course_lessons');
        Schema::dropIfExists('course_modules');
        Schema::dropIfExists('courses');
    }
};
