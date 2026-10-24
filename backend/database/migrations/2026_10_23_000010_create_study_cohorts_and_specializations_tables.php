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
        // 1. Add Algerian academic specializations, Wilaya & Verification Badge to users
        Schema::table('users', function (Blueprint $table) {
            $table->unsignedTinyInteger('wilaya')->nullable()->after('student_id'); // 1 to 58
            $table->string('academic_level', 50)->nullable()->after('wilaya'); // e.g., 'primary', 'cem', '3as_bac'
            $table->string('stream', 100)->nullable()->after('academic_level'); // e.g., 'علوم تجريبية', 'رياضيات', 'تقني رياضي'
            $table->string('guardian_link_code', 30)->nullable()->unique()->after('stream'); // e.g., 'PINDO-STU-XXXX'
            $table->boolean('is_verified')->default(false)->after('guardian_link_code');
            $table->enum('verification_status', ['unverified', 'pending', 'verified', 'rejected'])->default('unverified')->after('is_verified');
            $table->timestamp('verified_at')->nullable()->after('verification_status');
            $table->string('national_id_or_diploma')->nullable()->after('verified_at');
        });

        // 2. Study Cohorts Table (Independent Teacher Spaces & Group Management)
        Schema::create('study_cohorts', function (Blueprint $table) {
            $table->id();
            $table->string('cohort_code', 50)->unique()->index();
            $table->foreignId('teacher_id')->constrained('users')->cascadeOnDelete();
            $table->string('name');
            $table->string('subject');
            $table->string('academic_level', 50); // e.g. '3AS BAC', '4AM BEM'
            $table->string('stream', 100)->nullable();
            $table->unsignedInteger('max_students')->default(100);
            $table->unsignedInteger('enrolled_count')->default(0);
            $table->decimal('monthly_price', 10, 2)->default(0.00); // In DZD
            $table->json('schedule')->nullable(); // e.g. [{"day": "Friday", "time": "18:00", "duration_minutes": 120}]
            $table->boolean('is_active')->default(true)->index();
            $table->text('description')->nullable();
            $table->timestamps();
        });

        // 3. Cohort Members Table (Student Enrollments in Cohorts)
        Schema::create('cohort_members', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cohort_id')->constrained('study_cohorts')->cascadeOnDelete();
            $table->foreignId('student_id')->constrained('users')->cascadeOnDelete();
            $table->enum('status', ['active', 'pending', 'suspended', 'cancelled'])->default('active');
            $table->timestamp('joined_at')->useCurrent();
            $table->timestamps();

            $table->unique(['cohort_id', 'student_id']);
        });

        // 4. Bind Live Classroom Sessions to Study Cohorts (Teacher -> Cohort -> Session -> LiveKit Room)
        Schema::table('classroom_sessions', function (Blueprint $table) {
            $table->foreignId('cohort_id')->nullable()->after('user_id')->constrained('study_cohorts')->nullOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('classroom_sessions', function (Blueprint $table) {
            $table->dropForeign(['cohort_id']);
            $table->dropColumn('cohort_id');
        });

        Schema::dropIfExists('cohort_members');
        Schema::dropIfExists('study_cohorts');

        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'wilaya',
                'academic_level',
                'stream',
                'guardian_link_code',
                'is_verified',
                'verification_status',
                'verified_at',
                'national_id_or_diploma',
            ]);
        });
    }
};
