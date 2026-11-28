<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('study_cohorts')) {
            Schema::table('study_cohorts', function (Blueprint $table) {
                if (! Schema::hasColumn('study_cohorts', 'included_sessions_count')) {
                    $table->unsignedInteger('included_sessions_count')->default(8)->after('include_library');
                }
                if (! Schema::hasColumn('study_cohorts', 'extra_sessions_count')) {
                    $table->unsignedInteger('extra_sessions_count')->default(0)->after('included_sessions_count');
                }
                if (! Schema::hasColumn('study_cohorts', 'extra_sessions_is_paid')) {
                    $table->boolean('extra_sessions_is_paid')->default(false)->after('extra_sessions_count');
                }
                if (! Schema::hasColumn('study_cohorts', 'extra_session_price_dzd')) {
                    $table->decimal('extra_session_price_dzd', 10, 2)->default(0.00)->after('extra_sessions_is_paid');
                }
            });
        }

        if (Schema::hasTable('classroom_sessions')) {
            Schema::table('classroom_sessions', function (Blueprint $table) {
                if (! Schema::hasColumn('classroom_sessions', 'session_number')) {
                    $table->unsignedInteger('session_number')->nullable()->after('cohort_id');
                }
                if (! Schema::hasColumn('classroom_sessions', 'session_category')) {
                    $table->string('session_category', 30)->default('regular')->after('session_number');
                }
                if (! Schema::hasColumn('classroom_sessions', 'extra_price_dzd')) {
                    $table->decimal('extra_price_dzd', 10, 2)->default(0.00)->after('session_category');
                }
            });
        }

        if (Schema::hasTable('cohort_members')) {
            Schema::table('cohort_members', function (Blueprint $table) {
                if (! Schema::hasColumn('cohort_members', 'sessions_quota')) {
                    $table->unsignedInteger('sessions_quota')->default(8)->after('library_access');
                }
                if (! Schema::hasColumn('cohort_members', 'sessions_attended')) {
                    $table->unsignedInteger('sessions_attended')->default(0)->after('sessions_quota');
                }
                if (! Schema::hasColumn('cohort_members', 'first_session_number')) {
                    $table->unsignedInteger('first_session_number')->default(1)->after('sessions_attended');
                }
                if (! Schema::hasColumn('cohort_members', 'last_session_number')) {
                    $table->unsignedInteger('last_session_number')->nullable()->after('first_session_number');
                }
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('cohort_members')) {
            Schema::table('cohort_members', function (Blueprint $table) {
                $cols = array_filter([
                    'sessions_quota',
                    'sessions_attended',
                    'first_session_number',
                    'last_session_number',
                ], fn ($col) => Schema::hasColumn('cohort_members', $col));
                if (! empty($cols)) {
                    $table->dropColumn($cols);
                }
            });
        }

        if (Schema::hasTable('classroom_sessions')) {
            Schema::table('classroom_sessions', function (Blueprint $table) {
                $cols = array_filter([
                    'session_number',
                    'session_category',
                    'extra_price_dzd',
                ], fn ($col) => Schema::hasColumn('classroom_sessions', $col));
                if (! empty($cols)) {
                    $table->dropColumn($cols);
                }
            });
        }

        if (Schema::hasTable('study_cohorts')) {
            Schema::table('study_cohorts', function (Blueprint $table) {
                $cols = array_filter([
                    'included_sessions_count',
                    'extra_sessions_count',
                    'extra_sessions_is_paid',
                    'extra_session_price_dzd',
                ], fn ($col) => Schema::hasColumn('study_cohorts', $col));
                if (! empty($cols)) {
                    $table->dropColumn($cols);
                }
            });
        }
    }
};
