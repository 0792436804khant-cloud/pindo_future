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
        'joined_at',
    ];

    protected $casts = [
        'joined_at' => 'datetime',
    ];

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
