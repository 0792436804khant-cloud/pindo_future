<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Collection;
use Illuminate\Support\Str;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'role', // 'admin', 'teacher', 'student', 'parent'
        'teacher_id', // unique ID for teacher deep links (e.g., TCH_123)
        'student_id', // unique ID for student verification & guardian linking (e.g., STU_ADA_2026)
        'teaching_levels',
        'teaching_years',
        'teaching_subjects',
        'wilaya',
        'academic_level',
        'stream',
        'guardian_link_code',
        'is_verified',
        'verification_status',
        'verified_at',
        'national_id_or_diploma',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'teaching_levels' => 'array',
            'teaching_years' => 'array',
            'teaching_subjects' => 'array',
            'wilaya' => 'integer',
            'is_verified' => 'boolean',
            'verified_at' => 'datetime',
        ];
    }

    /**
     * Boot model logic: auto-assign teacher_id if teacher, student_id and guardian_link_code if student.
     */
    protected static function boot()
    {
        parent::boot();

        static::creating(function (User $user) {
            if ($user->role === Role::TEACHER && empty($user->teacher_id)) {
                $user->teacher_id = 'TCH_' . strtoupper(Str::random(6));
            }

            if ($user->role === Role::STUDENT) {
                if (empty($user->student_id)) {
                    $user->student_id = 'STU_' . strtoupper(Str::random(6));
                }
                if (empty($user->guardian_link_code)) {
                    $user->guardian_link_code = 'PINDO-STU-' . strtoupper(Str::random(5));
                }
            }
        });
    }

    /**
     * Roles relationship.
     */
    public function roles(): BelongsToMany
    {
        return $this->belongsToMany(Role::class, 'role_user');
    }

    /**
     * Classroom sessions hosted by this user.
     */
    public function classroomSessions(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(ClassroomSession::class, 'user_id');
    }

    /**
     * Teacher platform configuration profile.
     */
    public function teacherPlatform(): \Illuminate\Database\Eloquent\Relations\HasOne
    {
        return $this->hasOne(TeacherPlatform::class, 'user_id');
    }

    /**
     * Courses created and taught by this user (teacher).
     */
    public function taughtCourses(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Course::class, 'teacher_id');
    }

    /**
     * Study cohorts hosted by this teacher.
     */
    public function cohorts(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(StudyCohort::class, 'teacher_id');
    }

    /**
     * Enrollments for this user (student).
     */
    public function enrollments(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Enrollment::class, 'user_id');
    }

    /**
     * Cohort memberships for this user (student).
     */
    public function cohortMemberships(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(CohortMember::class, 'student_id');
    }

    /**
     * Cohorts this user is enrolled in (student).
     */
    public function enrolledCohorts(): BelongsToMany
    {
        return $this->belongsToMany(StudyCohort::class, 'cohort_members', 'student_id', 'cohort_id')
            ->withPivot(['status', 'joined_at'])
            ->withTimestamps();
    }

    /**
     * Courses this user is enrolled in (student).
     */
    public function enrolledCourses(): \Illuminate\Database\Eloquent\Relations\BelongsToMany
    {
        return $this->belongsToMany(Course::class, 'enrollments', 'user_id', 'course_id')
            ->withPivot(['status', 'enrolled_at', 'progress_percentage'])
            ->withTimestamps();
    }

    /**
     * Children linked to this user (for parent role).
     */
    public function children(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'parent_student', 'parent_id', 'student_id')
            ->withPivot(['relationship', 'status', 'linking_code', 'linked_at'])
            ->withTimestamps();
    }

    /**
     * Guardians linked to this user (for student role).
     */
    public function guardians(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'parent_student', 'student_id', 'parent_id')
            ->withPivot(['relationship', 'status', 'linking_code', 'linked_at'])
            ->withTimestamps();
    }

    /**
     * Guardian notes for this student.
     */
    public function guardianNotes(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(GuardianNote::class, 'student_id');
    }

    /**
     * Orders made by this user (as student / purchaser).
     */
    public function orders(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Order::class);
    }

    /**
     * Earnings for courses taught by this user (as teacher).
     */
    public function teacherEarnings(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(TeacherEarning::class, 'teacher_id');
    }

    /**
     * Payout requests created by this teacher.
     */
    public function teacherPayouts(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(TeacherPayout::class, 'teacher_id');
    }

    /**
     * Get available net earnings balance for withdrawal.
     */
    public function getAvailableEarningsBalance(): float
    {
        return (float) $this->teacherEarnings()
            ->where('status', TeacherEarning::STATUS_AVAILABLE)
            ->sum('net_amount');
    }

    /**
     * Get deep link URL for teacher.
     */
    public function getDeepLinkUrlAttribute(): ?string
    {
        if (empty($this->teacher_id)) {
            return null;
        }

        $baseUrl = config('app.url', 'https://pindofuture.com');
        return "{$baseUrl}/teacher/{$this->teacher_id}";
    }

    /**
     * Check if user has a specific role.
     */
    public function hasRole(string|array $roles): bool
    {
        if (is_string($roles)) {
            return $this->role === $roles || $this->roles->contains('name', $roles);
        }

        return in_array($this->role, $roles) || $this->roles->whereIn('name', $roles)->isNotEmpty();
    }

    /**
     * Check if user has permission through assigned roles.
     */
    public function hasPermission(string $permission): bool
    {
        if ($this->hasRole(Role::ADMIN)) {
            return true; // Admins inherit full access
        }

        return $this->allPermissions()->contains('name', $permission);
    }

    /**
     * Retrieve all distinct permissions for this user.
     */
    public function allPermissions(): Collection
    {
        return $this->roles->loadMissing('permissions')
            ->flatMap(fn (Role $role) => $role->permissions)
            ->unique('id');
    }

    /**
     * Assign a role to the user and keep role column synchronized.
     */
    public function assignRole(Role|string $role): void
    {
        if (is_string($role)) {
            $roleModel = Role::where('name', $role)->firstOrFail();
        } else {
            $roleModel = $role;
        }

        $this->role = $roleModel->name;
        $this->save();

        $this->roles()->syncWithoutDetaching([$roleModel->id]);
    }
}
