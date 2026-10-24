<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class ExamSimulation extends Model
{
    use HasFactory;

    protected $table = 'exam_simulations';

    protected $fillable = [
        'simulation_code',
        'user_id',
        'exam_paper_id',
        'started_at',
        'ended_at',
        'time_spent_seconds',
        'completed_exercises',
        'self_assessment_score',
        'student_notes',
        'status',
    ];

    protected $casts = [
        'started_at' => 'datetime',
        'ended_at' => 'datetime',
        'time_spent_seconds' => 'integer',
        'completed_exercises' => 'array',
        'self_assessment_score' => 'float',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function (ExamSimulation $simulation) {
            if (empty($simulation->simulation_code)) {
                $simulation->simulation_code = 'SIM_' . strtoupper(Str::random(10));
            }
        });
    }

    /**
     * Student who performed the simulation.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * The exam paper simulated.
     */
    public function examPaper(): BelongsTo
    {
        return $this->belongsTo(ExamPaper::class, 'exam_paper_id');
    }
}
