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
        // 1. Apple App Store Guideline 1.2 UGC Moderation & Content Reporting
        Schema::create('content_reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('reporter_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('reported_user_id')->nullable()->constrained('users')->cascadeOnDelete();
            $table->foreignId('classroom_session_id')->nullable()->constrained('classroom_sessions')->cascadeOnDelete();
            $table->foreignId('classroom_message_id')->nullable()->constrained('classroom_messages')->cascadeOnDelete();
            $table->string('reason'); // 'harassment', 'inappropriate_content', 'hate_speech', 'spam', 'other'
            $table->text('details')->nullable();
            $table->string('status')->default('pending'); // 'pending', 'investigating', 'resolved', 'dismissed'
            $table->foreignId('resolved_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('resolved_at')->nullable();
            $table->timestamps();

            $table->index(['status', 'created_at']);
        });

        // 2. High-Integrity Double-Entry Session Credit Ledger
        Schema::create('credit_ledgers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('order_id')->nullable()->constrained('orders')->nullOnDelete();
            $table->foreignId('classroom_session_id')->nullable()->constrained('classroom_sessions')->nullOnDelete();
            $table->string('type'); // 'credit_purchase', 'session_debit', 'refund', 'bonus_adjustment'
            $table->integer('credits_amount'); // positive (+N) or negative (-1)
            $table->integer('balance_after');
            $table->string('notes')->nullable();
            $table->timestamps();

            $table->index(['student_id', 'created_at']);
        });

        // 3. External Teacher Websites & Platform Deep-Linking
        Schema::create('external_platforms', function (Blueprint $table) {
            $table->id();
            $table->foreignId('teacher_id')->constrained('users')->cascadeOnDelete();
            $table->string('platform_name');
            $table->string('website_url');
            $table->string('api_key', 64)->unique();
            $table->string('webhook_url')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index(['teacher_id', 'is_active']);
        });

        // 4. External Platform Referral & Conversion Tracking
        Schema::create('referral_events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('teacher_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('external_platform_id')->nullable()->constrained('external_platforms')->nullOnDelete();
            $table->string('visitor_ip', 45)->nullable();
            $table->string('user_agent')->nullable();
            $table->string('referrer_url')->nullable();
            $table->foreignId('registered_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('converted_order_id')->nullable()->constrained('orders')->nullOnDelete();
            $table->timestamps();

            $table->index(['teacher_id', 'created_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('referral_events');
        Schema::dropIfExists('external_platforms');
        Schema::dropIfExists('credit_ledgers');
        Schema::dropIfExists('content_reports');
    }
};
