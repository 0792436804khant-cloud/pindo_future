<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('study_cohorts', function (Blueprint $table) {
            if (! Schema::hasColumn('study_cohorts', 'live_sessions_price')) {
                $table->decimal('live_sessions_price', 10, 2)->default(0.00)->after('monthly_price');
            }
            if (! Schema::hasColumn('study_cohorts', 'library_price')) {
                $table->decimal('library_price', 10, 2)->default(0.00)->after('live_sessions_price');
            }
            if (! Schema::hasColumn('study_cohorts', 'bundle_price')) {
                $table->decimal('bundle_price', 10, 2)->default(0.00)->after('library_price');
            }
            if (! Schema::hasColumn('study_cohorts', 'include_library')) {
                $table->boolean('include_library')->default(true)->after('bundle_price');
            }
        });

        Schema::table('cohort_members', function (Blueprint $table) {
            if (! Schema::hasColumn('cohort_members', 'package_type')) {
                $table->string('package_type', 30)->default('full_bundle')->after('status');
            }
            if (! Schema::hasColumn('cohort_members', 'price_paid_dzd')) {
                $table->decimal('price_paid_dzd', 10, 2)->default(0.00)->after('package_type');
            }
            if (! Schema::hasColumn('cohort_members', 'live_access')) {
                $table->boolean('live_access')->default(true)->after('price_paid_dzd');
            }
            if (! Schema::hasColumn('cohort_members', 'library_access')) {
                $table->boolean('library_access')->default(true)->after('live_access');
            }
        });

        Schema::table('orders', function (Blueprint $table) {
            if (Schema::hasColumn('orders', 'course_id')) {
                $table->unsignedBigInteger('course_id')->nullable()->change();
            }
            if (! Schema::hasColumn('orders', 'cohort_id')) {
                $table->foreignId('cohort_id')->nullable()->after('course_id')->constrained('study_cohorts')->nullOnDelete();
            }
            if (! Schema::hasColumn('orders', 'package_type')) {
                $table->string('package_type', 30)->default('full_bundle')->after('cohort_id');
            }
        });

        Schema::table('teacher_earnings', function (Blueprint $table) {
            if (Schema::hasColumn('teacher_earnings', 'course_id')) {
                $table->unsignedBigInteger('course_id')->nullable()->change();
            }
            if (! Schema::hasColumn('teacher_earnings', 'cohort_id')) {
                $table->foreignId('cohort_id')->nullable()->after('course_id')->constrained('study_cohorts')->nullOnDelete();
            }
            if (! Schema::hasColumn('teacher_earnings', 'package_type')) {
                $table->string('package_type', 30)->default('full_bundle')->after('cohort_id');
            }
            if (! Schema::hasColumn('teacher_earnings', 'live_gross_amount')) {
                $table->decimal('live_gross_amount', 10, 2)->default(0.00)->after('package_type');
            }
            if (! Schema::hasColumn('teacher_earnings', 'library_gross_amount')) {
                $table->decimal('library_gross_amount', 10, 2)->default(0.00)->after('live_gross_amount');
            }
            if (! Schema::hasColumn('teacher_earnings', 'live_platform_fee')) {
                $table->decimal('live_platform_fee', 10, 2)->default(0.00)->after('library_gross_amount');
            }
            if (! Schema::hasColumn('teacher_earnings', 'library_platform_fee')) {
                $table->decimal('library_platform_fee', 10, 2)->default(0.00)->after('live_platform_fee');
            }
        });
    }

    public function down(): void
    {
        Schema::table('teacher_earnings', function (Blueprint $table) {
            if (Schema::hasColumn('teacher_earnings', 'cohort_id')) {
                $table->dropConstrainedForeignId('cohort_id');
            }
            $columns = array_filter([
                'package_type',
                'live_gross_amount',
                'library_gross_amount',
                'live_platform_fee',
                'library_platform_fee',
            ], fn ($col) => Schema::hasColumn('teacher_earnings', $col));
            if (! empty($columns)) {
                $table->dropColumn($columns);
            }
        });

        Schema::table('orders', function (Blueprint $table) {
            if (Schema::hasColumn('orders', 'cohort_id')) {
                $table->dropConstrainedForeignId('cohort_id');
            }
            if (Schema::hasColumn('orders', 'package_type')) {
                $table->dropColumn('package_type');
            }
        });

        Schema::table('cohort_members', function (Blueprint $table) {
            $columns = array_filter([
                'package_type',
                'price_paid_dzd',
                'live_access',
                'library_access',
            ], fn ($col) => Schema::hasColumn('cohort_members', $col));
            if (! empty($columns)) {
                $table->dropColumn($columns);
            }
        });

        Schema::table('study_cohorts', function (Blueprint $table) {
            $columns = array_filter([
                'live_sessions_price',
                'library_price',
                'bundle_price',
                'include_library',
            ], fn ($col) => Schema::hasColumn('study_cohorts', $col));
            if (! empty($columns)) {
                $table->dropColumn($columns);
            }
        });
    }
};
