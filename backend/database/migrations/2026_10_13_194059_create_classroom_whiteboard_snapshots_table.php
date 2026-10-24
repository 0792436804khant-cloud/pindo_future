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
        Schema::create('classroom_whiteboard_snapshots', function (Blueprint $table) {
            $table->id();
            $table->string('session_id')->index();
            $table->foreignId('classroom_session_id')->nullable()->constrained('classroom_sessions')->nullOnDelete();
            $table->foreignId('author_id')->constrained('users')->cascadeOnDelete();
            $table->string('snapshot_title')->nullable();
            $table->json('vector_data');
            $table->integer('stroke_count')->default(0);
            $table->integer('version')->default(1);
            $table->string('thumbnail_url', 500)->nullable();
            $table->timestamps();

            $table->index(['session_id', 'created_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('classroom_whiteboard_snapshots');
    }
};
