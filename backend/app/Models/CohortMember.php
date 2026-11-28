<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CohortMember extends Model
{
    use HasFactory;

    protected $table = 'cohort_members';

    protected $fillable = [
        'cohort_id',
        'student_id',
        'status',
        'package_type',
        'price_paid_dzd',
        'live_access',
        'library_access',
        'sessions_quota',
        'sessions_attended',
        'first_session_number',
        'last_session_number',
        'joined_at',
        'ends_at',
    ];

    protected $casts = [
        'price_paid_dzd' => 'float',
        'live_access' => 'boolean',
        'library_access' => 'boolean',
        'sessions_quota' => 'integer',
        'sessions_attended' => 'integer',
        'first_session_number' => 'integer',
        'last_session_number' => 'integer',
        'joined_at' => 'datetime',
        'ends_at' => 'datetime',
    ];

    /**
     * Remaining included regular sessions before subscription renewal.
     */
    public function remainingSessions(): int
    {
        $quota = max(0, (int) ($this->sessions_quota ?? 8));
        $attended = max(0, (int) ($this->sessions_attended ?? 0));

        return max(0, $quota - $attended);
    }

    /**
     * Determine whether student still has quota left in current subscription cycle.
     */
    public function hasRemainingQuota(): bool
    {
        return $this->remainingSessions() > 0;
    }

    /**
     * Scope only active memberships where end date has not lapsed.
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'active')
            ->where(function ($q) {
                $q->whereNull('ends_at')
                  ->orWhere('ends_at', '>', now());
            });
    }

    /**
     * Study cohort.
     */
    public function cohort(): BelongsTo
    {
        return $this->belongsTo(StudyCohort::class, 'cohort_id');
    }

    /**
     * Enrolled student.
     */
    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_id');
    }
}
