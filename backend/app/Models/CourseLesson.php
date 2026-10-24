<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CourseLesson extends Model
{
    use HasFactory;

    public const TYPE_LIVE_SESSION = 'live_session';
    public const TYPE_VIDEO = 'video';
    public const TYPE_DOCUMENT = 'document';

    public const ALL_TYPES = [
        self::TYPE_LIVE_SESSION,
        self::TYPE_VIDEO,
        self::TYPE_DOCUMENT,
    ];

    protected $fillable = [
        'course_module_id',
        'title',
        'type',
        'classroom_session_id',
        'duration_minutes',
        'order',
        'content_url',
    ];

    protected function casts(): array
    {
        return [
            'duration_minutes' => 'integer',
            'order' => 'integer',
        ];
    }

    /**
     * Parent module.
     */
    public function module(): BelongsTo
    {
        return $this->belongsTo(CourseModule::class, 'course_module_id');
    }

    /**
     * Linked LiveKit classroom session (if this is a live lesson).
     */
    public function classroomSession(): BelongsTo
    {
        return $this->belongsTo(ClassroomSession::class, 'classroom_session_id');
    }

    /**
     * Check if lesson is an interactive live stream.
     */
    public function isLiveSession(): bool
    {
        return $this->type === self::TYPE_LIVE_SESSION;
    }
}
