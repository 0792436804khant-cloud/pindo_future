<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class ClassroomSession extends Model
{
    use HasFactory;

    public const STATUS_SCHEDULED = 'scheduled';
    public const STATUS_ACTIVE = 'active';
    public const STATUS_ENDED = 'ended';
    public const STATUS_CANCELLED = 'cancelled';

    public const ALL_STATUSES = [
        self::STATUS_SCHEDULED,
        self::STATUS_ACTIVE,
        self::STATUS_ENDED,
        self::STATUS_CANCELLED,
    ];

    protected $fillable = [
        'session_id',
        'user_id',
        'cohort_id',
        'title',
        'description',
        'status',
        'max_participants',
        'settings',
        'scheduled_at',
        'started_at',
        'ended_at',
    ];

    protected function casts(): array
    {
        return [
            'settings' => 'array',
            'max_participants' => 'integer',
            'scheduled_at' => 'datetime',
            'started_at' => 'datetime',
            'ended_at' => 'datetime',
        ];
    }

    /**
     * Auto-generate unique Session ID upon creation if not provided.
     */
    protected static function boot()
    {
        parent::boot();

        static::creating(function (ClassroomSession $session) {
            if (empty($session->session_id)) {
                $session->session_id = self::generateUniqueSessionId();
            }
        });
    }

    /**
     * Generate collision-free Session ID formatted as SES_XXXXXXXX.
     */
    public static function generateUniqueSessionId(): string
    {
        do {
            $candidate = 'SES_' . strtoupper(Str::random(8));
        } while (self::where('session_id', $candidate)->exists());

        return $candidate;
    }

    /**
     * Teacher / Host relationship.
     */
    public function teacher(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * Study cohort relationship.
     */
    public function cohort(): BelongsTo
    {
        return $this->belongsTo(StudyCohort::class, 'cohort_id');
    }

    public function messages(): HasMany
    {
        return $this->hasMany(ClassroomMessage::class, 'session_id', 'session_id');
    }

    public function attendances(): HasMany
    {
        return $this->hasMany(ClassroomAttendance::class, 'session_id', 'session_id');
    }

    public function recordings(): HasMany
    {
        return $this->hasMany(SessionRecording::class, 'classroom_session_id');
    }

    /**
     * Associated course curriculum lesson (if session is part of a course).
     */
    public function lesson(): \Illuminate\Database\Eloquent\Relations\HasOne
    {
        return $this->hasOne(CourseLesson::class, 'classroom_session_id');
    }

    /**
     * Transition session to active state.
     */
    public function start(): void
    {
        $this->update([
            'status' => self::STATUS_ACTIVE,
            'started_at' => now(),
        ]);
    }

    /**
     * Transition session to ended state.
     */
    public function end(): void
    {
        $this->update([
            'status' => self::STATUS_ENDED,
            'ended_at' => now(),
        ]);
    }

    public function isActive(): bool
    {
        return $this->status === self::STATUS_ACTIVE;
    }

    public function isScheduled(): bool
    {
        return $this->status === self::STATUS_SCHEDULED;
    }

    public function isEnded(): bool
    {
        return $this->status === self::STATUS_ENDED;
    }

    /**
     * Scopes.
     */
    public function scopeActive(Builder $query): Builder
    {
        return $query->where('status', self::STATUS_ACTIVE);
    }

    public function scopeUpcoming(Builder $query): Builder
    {
        return $query->where('status', self::STATUS_SCHEDULED);
    }

    public function scopeBySessionId(Builder $query, string $sessionId): Builder
    {
        return $query->where('session_id', $sessionId);
    }
}
