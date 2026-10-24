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
        Schema::table('users', function (Blueprint $table) {
            $table->json('teaching_levels')->nullable()->after('teacher_id');
            $table->json('teaching_years')->nullable()->after('teaching_levels');
            $table->json('teaching_subjects')->nullable()->after('teaching_years');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['teaching_levels', 'teaching_years', 'teaching_subjects']);
        });
    }
};
