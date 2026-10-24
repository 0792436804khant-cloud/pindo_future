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
        // 1. Real-Time Classroom Messages / Q&A Archive
        Schema::create('classroom_messages', function (Blueprint $table) {
            $table->id();
            $table->string('session_id')->index();
            $table->foreign('session_id')->references('session_id')->on('classroom_sessions')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->text('message');
            $table->boolean('is_pinned')->default(false);
            $table->timestamps();

            $table->index(['session_id', 'created_at']);
        });

        // 2. Real-Time Classroom Attendances & Entry/Exit Tracking
        Schema::create('classroom_attendances', function (Blueprint $table) {
            $table->id();
            $table->string('session_id')->index();
            $table->foreign('session_id')->references('session_id')->on('classroom_sessions')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('role', 20)->default('student');
            $table->timestamp('joined_at')->useCurrent();
            $table->timestamp('left_at')->nullable();
            $table->unsignedInteger('duration_seconds')->default(0);
            $table->timestamps();

            $table->index(['session_id', 'user_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('classroom_attendances');
        Schema::dropIfExists('classroom_messages');
    }
};
