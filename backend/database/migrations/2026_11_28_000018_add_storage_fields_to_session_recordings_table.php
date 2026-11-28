<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('session_recordings', function (Blueprint $table) {
            if (! Schema::hasColumn('session_recordings', 'storage_disk')) {
                $table->string('storage_disk', 40)->default('public')->after('video_storage_path');
            }
            if (! Schema::hasColumn('session_recordings', 'save_mode')) {
                $table->string('save_mode', 40)->default('cloud_library')->after('storage_disk');
            }
            if (! Schema::hasColumn('session_recordings', 'mime_type')) {
                $table->string('mime_type', 100)->nullable()->default('video/webm')->after('save_mode');
            }
            if (! Schema::hasColumn('session_recordings', 'processing_status')) {
                $table->string('processing_status', 40)->default('ready')->after('mime_type');
            }
        });
    }

    public function down(): void
    {
        Schema::table('session_recordings', function (Blueprint $table) {
            $cols = array_filter(
                ['storage_disk', 'save_mode', 'mime_type', 'processing_status'],
                fn (string $c) => Schema::hasColumn('session_recordings', $c)
            );
            if (! empty($cols)) {
                $table->dropColumn(array_values($cols));
            }
        });
    }
};
