<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cohort_attendance_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cohort_id')->constrained('study_cohorts')->cascadeOnDelete();
            $table->string('month_key', 7)->index(); // e.g. 2026-11
            $table->string('label', 120);
            $table->date('session_date');
            $table->timestamps();

            $table->index(['cohort_id', 'month_key', 'session_date']);
        });

        Schema::create('cohort_attendance_records', function (Blueprint $table) {
            $table->id();
            $table->foreignId('attendance_session_id')->constrained('cohort_attendance_sessions')->cascadeOnDelete();
            $table->foreignId('student_id')->constrained('users')->cascadeOnDelete();
            $table->string('status', 4)->default('P'); // P, L, A, E
            $table->timestamps();

            $table->unique(['attendance_session_id', 'student_id']);
        });

        Schema::create('cohort_chat_messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cohort_id')->constrained('study_cohorts')->cascadeOnDelete();
            $table->foreignId('sender_id')->constrained('users')->cascadeOnDelete();
            $table->string('sender_role', 20)->default('student');
            $table->text('text')->nullable();
            $table->string('message_type', 20)->default('text'); // text, image, link, file
            $table->text('image_url')->nullable();
            $table->string('link_url', 500)->nullable();
            $table->string('link_title', 255)->nullable();
            $table->string('file_name', 255)->nullable();
            $table->unsignedBigInteger('file_size_bytes')->nullable();
            $table->boolean('is_pinned')->default(false);
            $table->json('reactions')->nullable();
            $table->timestamps();

            $table->index(['cohort_id', 'created_at']);
        });

        Schema::create('cohort_message_reads', function (Blueprint $table) {
            $table->id();
            $table->foreignId('message_id')->constrained('cohort_chat_messages')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->timestamp('delivered_at')->nullable();
            $table->timestamp('read_at')->nullable();
            $table->timestamps();

            $table->unique(['message_id', 'user_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cohort_message_reads');
        Schema::dropIfExists('cohort_chat_messages');
        Schema::dropIfExists('cohort_attendance_records');
        Schema::dropIfExists('cohort_attendance_sessions');
    }
};
