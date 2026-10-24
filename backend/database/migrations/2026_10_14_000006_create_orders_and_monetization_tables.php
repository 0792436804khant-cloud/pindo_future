<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations for Phase 7: Course Checkout, Payment Gateway & Monetization Engine.
     */
    public function up(): void
    {
        // 1. Orders & Invoices Table
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('order_number', 32)->unique(); // e.g. ORD_2026_XXXXXX
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete(); // Student/Purchaser
            $table->foreignId('course_id')->constrained('courses')->cascadeOnDelete();
            $table->decimal('amount', 10, 2);
            $table->string('currency', 3)->default('DZD');
            $table->enum('status', ['pending', 'completed', 'failed', 'refunded'])->default('pending')->index();
            $table->string('payment_method', 50)->default('card'); // 'card', 'stripe', 'paypal'
            $table->string('gateway_transaction_id', 100)->nullable()->index();
            $table->string('receipt_number', 64)->nullable()->unique();
            $table->json('payment_metadata')->nullable(); // card brand, last4, charge ID
            $table->timestamp('paid_at')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'status']);
        });

        // 2. Teacher Earnings & Revenue Split Table (80% Teacher / 20% Platform)
        Schema::create('teacher_earnings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('teacher_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('order_id')->constrained('orders')->cascadeOnDelete();
            $table->foreignId('course_id')->constrained('courses')->cascadeOnDelete();
            $table->decimal('gross_amount', 10, 2); // 100%
            $table->decimal('platform_fee', 10, 2); // 20%
            $table->decimal('net_amount', 10, 2); // 80%
            $table->enum('status', ['available', 'pending', 'paid_out'])->default('available')->index();
            $table->foreignId('payout_id')->nullable(); // linked when paid out
            $table->timestamps();

            $table->index(['teacher_id', 'status']);
        });

        // 3. Teacher Payout Disbursements Table
        Schema::create('teacher_payouts', function (Blueprint $table) {
            $table->id();
            $table->string('payout_reference', 32)->unique(); // e.g. PO_2026_XXXXXX
            $table->foreignId('teacher_id')->constrained('users')->cascadeOnDelete();
            $table->decimal('amount', 10, 2);
            $table->string('currency', 3)->default('DZD');
            $table->enum('status', ['requested', 'processing', 'completed', 'rejected'])->default('requested')->index();
            $table->string('payout_method', 50)->default('bank_transfer'); // 'stripe_connect', 'bank_transfer', 'paypal'
            $table->string('destination_account', 100)->nullable(); // e.g. IBAN or email
            $table->timestamp('processed_at')->nullable();
            $table->timestamps();

            $table->index(['teacher_id', 'created_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('teacher_payouts');
        Schema::dropIfExists('teacher_earnings');
        Schema::dropIfExists('orders');
    }
};
