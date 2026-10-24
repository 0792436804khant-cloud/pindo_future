<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class StudyCohort extends Model
{
    use HasFactory;

    protected $table = 'study_cohorts';

    protected $fillable = [
        'cohort_code',
        'teacher_id',
        'name',
        'subject',
        'academic_level',
        'stream',
        'max_students',
        'enrolled_count',
        'monthly_price',
        'schedule',
        'is_active',
        'description',
    ];

    protected $casts = [
        'max_students' => 'integer',
        'enrolled_count' => 'integer',
        'monthly_price' => 'float',
        'schedule' => 'array',
        'is_active' => 'boolean',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function (StudyCohort $cohort) {
            if (empty($cohort->cohort_code)) {
                $cohort->cohort_code = 'COHORT_' . strtoupper(Str::random(8));
            }
        });
    }

    /**
     * Teacher hosting this study cohort.
     */
    public function teacher(): BelongsTo
    {
        return $this->belongsTo(User::class, 'teacher_id');
    }

    /**
     * Memberships in this cohort.
     */
    public function members(): HasMany
    {
        return $this->hasMany(CohortMember::class, 'cohort_id');
    }

    /**
     * Enrolled students in this cohort.
     */
    public function students(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'cohort_members', 'cohort_id', 'student_id')
            ->withPivot(['status', 'joined_at'])
            ->withTimestamps();
    }

    /**
     * Classroom sessions bound to this cohort.
     */
    public function sessions(): HasMany
    {
        return $this->hasMany(ClassroomSession::class, 'cohort_id');
    }

    /**
     * Recorded live sessions in the cohort library.
     */
    public function recordings(): HasMany
    {
        return $this->hasMany(SessionRecording::class, 'cohort_id');
    }

    /**
     * Educational materials & PDFs attached to this cohort.
     */
    public function materials(): HasMany
    {
        return $this->hasMany(CohortMaterial::class, 'cohort_id');
    }

    /**
     * Check if cohort has reached max capacity.
     */
    public function isFull(): bool
    {
        return $this->enrolled_count >= $this->max_students;
    }

    /**
     * Check if a specific student is an active member.
     */
    public function hasStudent(int $studentId): bool
    {
        return $this->members()
            ->where('student_id', $studentId)
            ->where('status', 'active')
            ->exists();
    }

    /**
     * Recalculate and update the enrolled students count.
     */
    public function recalculateEnrolledCount(): int
    {
        $count = $this->members()->where('status', 'active')->count();
        $this->update(['enrolled_count' => $count]);
        return $count;
    }
}
