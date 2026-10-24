<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class SessionRecording extends Model
{
    use HasFactory;

    protected $fillable = [
        'recording_code',
        'classroom_session_id',
        'cohort_id',
        'teacher_id',
        'title',
        'description',
        'video_storage_path',
        'duration_seconds',
        'file_size_bytes',
        'is_published',
        'views_count',
    ];

    protected function casts(): array
    {
        return [
            'is_published' => 'boolean',
            'duration_seconds' => 'integer',
            'views_count' => 'integer',
            'file_size_bytes' => 'integer',
        ];
    }

    protected static function boot()
    {
        parent::boot();

        static::creating(function (SessionRecording $recording) {
            if (empty($recording->recording_code)) {
                $recording->recording_code = self::generateUniqueRecordingCode();
            }
        });
    }

    public static function generateUniqueRecordingCode(): string
    {
        do {
            $code = 'REC_' . strtoupper(Str::random(8));
        } while (self::where('recording_code', $code)->exists());

        return $code;
    }

    public function session(): BelongsTo
    {
        return $this->belongsTo(ClassroomSession::class, 'classroom_session_id');
    }

    public function cohort(): BelongsTo
    {
        return $this->belongsTo(StudyCohort::class, 'cohort_id');
    }

    public function teacher(): BelongsTo
    {
        return $this->belongsTo(User::class, 'teacher_id');
    }

    public function scopePublished(Builder $query): Builder
    {
        return $query->where('is_published', true);
    }
}
