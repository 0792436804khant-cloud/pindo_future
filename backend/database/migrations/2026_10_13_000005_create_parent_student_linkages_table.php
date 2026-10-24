<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations for Phase 6: Parent-Student Linkages & Guardian Oversight.
     */
    public function up(): void
    {
        // 1. Parent-Student Linkage Pivot Table
        Schema::create('parent_student', function (Blueprint $table) {
            $table->id();
            $table->foreignId('parent_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('student_id')->constrained('users')->cascadeOnDelete();
            $table->string('relationship')->default('Legal Guardian'); // 'Mother', 'Father', 'Guardian'
            $table->enum('status', ['active', 'pending', 'revoked'])->default('active')->index();
            $table->string('linking_code', 16)->nullable()->index();
            $table->timestamp('linked_at')->useCurrent();
            $table->timestamps();

            $table->unique(['parent_id', 'student_id']);
        });

        // 2. Guardian Notes & Instructor Feedback
        Schema::create('guardian_notes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('parent_id')->nullable()->constrained('users')->cascadeOnDelete();
            $table->foreignId('author_id')->constrained('users')->cascadeOnDelete(); // Teacher or Parent
            $table->string('title');
            $table->text('content');
            $table->enum('type', ['progress_report', 'attendance_alert', 'general'])->default('general');
            $table->boolean('is_acknowledged')->default(false);
            $table->timestamps();

            $table->index(['student_id', 'created_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('guardian_notes');
        Schema::dropIfExists('parent_student');
    }
};
