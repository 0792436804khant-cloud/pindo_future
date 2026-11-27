<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class CohortAttendanceSession extends Model
{
    protected $fillable = [
        'cohort_id',
        'month_key',
        'label',
        'session_date',
    ];

    protected $casts = [
        'session_date' => 'date',
    ];

    public function cohort(): BelongsTo
    {
        return $this->belongsTo(StudyCohort::class, 'cohort_id');
    }

    public function records(): HasMany
    {
        return $this->hasMany(CohortAttendanceRecord::class, 'attendance_session_id');
    }
}
