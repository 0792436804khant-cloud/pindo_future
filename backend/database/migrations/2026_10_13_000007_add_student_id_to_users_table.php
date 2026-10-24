<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('student_id', 50)->nullable()->unique()->index()->after('teacher_id');
        });

        // Set student_id for existing student accounts
        DB::table('users')
            ->where('role', 'student')
            ->whereNull('student_id')
            ->update(['student_id' => 'STU_ADA_2026']);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex(['student_id']);
            $table->dropColumn('student_id');
        });
    }
};
