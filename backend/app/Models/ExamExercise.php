<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ExamExercise extends Model
{
    use HasFactory;

    protected $table = 'exam_exercises';

    protected $fillable = [
        'exam_paper_id',
        'exercise_number',
        'title',
        'topic',
        'points',
        'instructions',
        'official_marking_rubric',
        'solution_explanation',
    ];

    protected $casts = [
        'exercise_number' => 'integer',
        'points' => 'float',
        'official_marking_rubric' => 'array',
    ];

    /**
     * Parent exam paper.
     */
    public function examPaper(): BelongsTo
    {
        return $this->belongsTo(ExamPaper::class, 'exam_paper_id');
    }
}
