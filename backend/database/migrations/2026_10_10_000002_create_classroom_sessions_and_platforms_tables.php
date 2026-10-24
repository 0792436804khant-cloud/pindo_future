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
        // 1. Dynamic Classroom Sessions Table (Bound to Session ID, Decoupled for 30k users)
        Schema::create('classroom_sessions', function (Blueprint $table) {
            $table->id();
            $table->string('session_id')->unique()->index(); // e.g. SES_A1B2C3
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete(); // Host / Teacher
            $table->string('title');
            $table->text('description')->nullable();
            $table->enum('status', ['scheduled', 'active', 'ended', 'cancelled'])->default('scheduled')->index();
            $table->unsignedInteger('max_participants')->default(30000);
            $table->json('settings')->nullable(); // Chat, audio permissions, recording flags
            $table->timestamp('scheduled_at')->nullable();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('ended_at')->nullable();
            $table->timestamps();
        });

        // 2. Teacher Platforms Table (Teacher ID Branding & Deep Linking)
        Schema::create('teacher_platforms', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained('users')->cascadeOnDelete();
            $table->string('headline')->nullable();
            $table->text('bio')->nullable();
            $table->string('website_url')->nullable();
            $table->json('settings')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('teacher_platforms');
        Schema::dropIfExists('classroom_sessions');
    }
};
