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

    public const PACKAGE_LIVE_ONLY = 'live_only';
    public const PACKAGE_LIBRARY_ONLY = 'library_only';
    public const PACKAGE_FULL_BUNDLE = 'full_bundle';

    public const LIVE_PLATFORM_FEE_RATE = 0.15;
    public const LIBRARY_PLATFORM_FEE_RATE = 0.10;

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
        'live_sessions_price',
        'library_price',
        'bundle_price',
        'include_library',
        'schedule',
        'is_active',
        'description',
    ];

    protected $casts = [
        'max_students' => 'integer',
        'enrolled_count' => 'integer',
        'monthly_price' => 'float',
        'live_sessions_price' => 'float',
        'library_price' => 'float',
        'bundle_price' => 'float',
        'include_library' => 'boolean',
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

    /**
     * Resolve authoritative package pricing & platform/teacher split breakdown for a cohort.
     * - live_only: 15% platform / 85% teacher
     * - library_only: 10% platform / 90% teacher
     * - full_bundle: proportional live (15%) + library (10%) split based on component prices
     */
    public function resolvePackagePricing(string $packageType = self::PACKAGE_FULL_BUNDLE): array
    {
        $livePrice = (float) ($this->live_sessions_price > 0 ? $this->live_sessions_price : $this->monthly_price);
        $libPrice = $this->include_library ? (float) $this->library_price : 0.0;
        $bundlePrice = (float) ($this->bundle_price > 0 ? $this->bundle_price : ($livePrice + $libPrice));

        if ($packageType === self::PACKAGE_LIVE_ONLY) {
            $gross = $livePrice;
            $liveGross = $gross;
            $libraryGross = 0.0;
            $liveAccess = true;
            $libraryAccess = false;
        } elseif ($packageType === self::PACKAGE_LIBRARY_ONLY) {
            $gross = $libPrice > 0 ? $libPrice : $bundlePrice;
            $liveGross = 0.0;
            $libraryGross = $gross;
            $liveAccess = false;
            $libraryAccess = true;
        } else {
            $packageType = self::PACKAGE_FULL_BUNDLE;
            $gross = $bundlePrice > 0 ? $bundlePrice : ($livePrice + $libPrice);
            $componentSum = $livePrice + $libPrice;
            if ($gross > 0 && $componentSum > 0 && $libPrice > 0) {
                $liveGross = round($gross * ($livePrice / $componentSum), 2);
                $libraryGross = round($gross - $liveGross, 2);
            } elseif ($gross > 0 && $libPrice > 0) {
                $liveGross = round($gross * 0.65, 2);
                $libraryGross = round($gross - $liveGross, 2);
            } else {
                $liveGross = $gross;
                $libraryGross = 0.0;
            }
            $liveAccess = true;
            $libraryAccess = $this->include_library;
        }

        $liveFee = round($liveGross * self::LIVE_PLATFORM_FEE_RATE, 2);
        $libraryFee = round($libraryGross * self::LIBRARY_PLATFORM_FEE_RATE, 2);
        $platformFee = round($liveFee + $libraryFee, 2);
        $teacherNet = round($gross - $platformFee, 2);

        return [
            'package_type' => $packageType,
            'gross_amount' => round($gross, 2),
            'live_gross_amount' => round($liveGross, 2),
            'library_gross_amount' => round($libraryGross, 2),
            'live_platform_fee' => $liveFee,
            'library_platform_fee' => $libraryFee,
            'platform_fee' => $platformFee,
            'teacher_net_amount' => $teacherNet,
            'live_access' => $liveAccess,
            'library_access' => $libraryAccess,
        ];
    }
}
