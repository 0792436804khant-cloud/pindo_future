<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations for Phase 7: Real-time Notifications & Live Class Alerts.
     */
    public function up(): void
    {
        Schema::create('app_notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('type', 64)->index(); // 'live_session_started', 'payment_confirmed', 'course_enrolled', 'guardian_alert', etc.
            $table->string('title');
            $table->text('body');
            $table->json('data')->nullable(); // metadata e.g. {session_id, cohort_id, course_id, priority}
            $table->timestamp('read_at')->nullable()->index();
            $table->timestamps();

            $table->index(['user_id', 'created_at']);
            $table->index(['user_id', 'read_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('app_notifications');
    }
};
