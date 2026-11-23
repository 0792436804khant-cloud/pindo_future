<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Production Admin Panel & Operations Hardening Migrations.
     * Prevents duplicate receipts, tracks rejection reasons, and enforces subscription auto-expiry.
     */
    public function up(): void
    {
        // 1. Teacher KYC Rejection Reason & Documents
        if (Schema::hasTable('users')) {
            Schema::table('users', function (Blueprint $table) {
                if (!Schema::hasColumn('users', 'rejection_reason')) {
                    $table->text('rejection_reason')->nullable()->after('verification_status');
                }
                if (!Schema::hasColumn('users', 'diploma_preview_url')) {
                    $table->string('diploma_preview_url')->nullable()->after('national_id_or_diploma');
                }
            });
        }

        // 2. BaridiMob Anti-Fraud Receipt Deduplication & Expiry
        if (Schema::hasTable('orders')) {
            Schema::table('orders', function (Blueprint $table) {
                if (!Schema::hasColumn('orders', 'receipt_image_path')) {
                    $table->string('receipt_image_path')->nullable()->after('receipt_number');
                }
                if (!Schema::hasColumn('orders', 'receipt_hash')) {
                    $table->string('receipt_hash', 64)->nullable()->index()->after('receipt_image_path');
                }
                if (!Schema::hasColumn('orders', 'tx_reference')) {
                    $table->string('tx_reference', 64)->nullable()->index()->after('receipt_hash');
                }
                if (!Schema::hasColumn('orders', 'rejection_reason')) {
                    $table->text('rejection_reason')->nullable()->after('status');
                }
                if (!Schema::hasColumn('orders', 'subscription_ends_at')) {
                    $table->timestamp('subscription_ends_at')->nullable()->after('paid_at');
                }
            });
        }

        // 3. Cohort Members Auto-Expiry
        if (Schema::hasTable('cohort_members')) {
            Schema::table('cohort_members', function (Blueprint $table) {
                if (!Schema::hasColumn('cohort_members', 'ends_at')) {
                    $table->timestamp('ends_at')->nullable()->after('joined_at');
                }
            });
        }

        // 4. Enrollments Auto-Expiry
        if (Schema::hasTable('enrollments')) {
            Schema::table('enrollments', function (Blueprint $table) {
                if (!Schema::hasColumn('enrollments', 'ends_at')) {
                    $table->timestamp('ends_at')->nullable()->after('enrolled_at');
                }
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['rejection_reason', 'diploma_preview_url']);
        });

        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn(['receipt_image_path', 'receipt_hash', 'tx_reference', 'rejection_reason', 'subscription_ends_at']);
        });

        Schema::table('cohort_members', function (Blueprint $table) {
            $table->dropColumn(['ends_at']);
        });

        Schema::table('enrollments', function (Blueprint $table) {
            $table->dropColumn(['ends_at']);
        });
    }
};
