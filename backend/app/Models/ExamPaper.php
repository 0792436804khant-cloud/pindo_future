<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class ExamPaper extends Model
{
    use HasFactory;

    protected $table = 'exam_papers';

    protected $fillable = [
        'exam_code',
        'title',
        'cycle',
        'stream',
        'subject',
        'subject_name_ar',
        'year',
        'session_type',
        'option_number',
        'duration_minutes',
        'coefficient',
        'total_score',
        'paper_pdf_url',
        'solution_pdf_url',
        'description',
        'difficulty_level',
        'exercise_count',
        'views_count',
        'downloads_count',
        'is_published',
    ];

    protected $casts = [
        'year' => 'integer',
        'option_number' => 'integer',
        'duration_minutes' => 'integer',
        'coefficient' => 'integer',
        'total_score' => 'integer',
        'exercise_count' => 'integer',
        'views_count' => 'integer',
        'downloads_count' => 'integer',
        'is_published' => 'boolean',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function (ExamPaper $paper) {
            if (empty($paper->exam_code)) {
                $cyclePrefix = strtoupper($paper->cycle ?? 'BAC');
                $streamPrefix = $paper->stream ? strtoupper(substr($paper->stream, 0, 4)) : 'GEN';
                $paper->exam_code = sprintf(
                    '%s-%d-%s-%s',
                    $cyclePrefix,
                    $paper->year ?? date('Y'),
                    $streamPrefix,
                    strtoupper(Str::random(6))
                );
            }
        });
    }

    /**
     * Exercises composing this exam paper.
     */
    public function exercises(): HasMany
    {
        return $this->hasMany(ExamExercise::class, 'exam_paper_id')->orderBy('exercise_number');
    }

    /**
     * Mock simulations attempted by students for this exam.
     */
    public function simulations(): HasMany
    {
        return $this->hasMany(ExamSimulation::class, 'exam_paper_id');
    }

    /**
     * Scope only published exam papers.
     */
    public function scopePublished(Builder $query): Builder
    {
        return $query->where('is_published', true);
    }

    /**
     * Filter by educational cycle (bem, bac).
     */
    public function scopeCycle(Builder $query, ?string $cycle): Builder
    {
        if (!empty($cycle)) {
            return $query->where('cycle', strtolower($cycle));
        }
        return $query;
    }

    /**
     * Filter by secondary stream (BAC).
     */
    public function scopeStream(Builder $query, ?string $stream): Builder
    {
        if (!empty($stream)) {
            return $query->where('stream', $stream);
        }
        return $query;
    }

    /**
     * Filter by subject.
     */
    public function scopeSubject(Builder $query, ?string $subject): Builder
    {
        if (!empty($subject)) {
            return $query->where('subject', $subject);
        }
        return $query;
    }

    /**
     * Filter by year.
     */
    public function scopeYear(Builder $query, ?int $year): Builder
    {
        if (!empty($year)) {
            return $query->where('year', $year);
        }
        return $query;
    }

    /**
     * Human-friendly formatted duration (e.g., "3 سا 30 د").
     */
    public function getFormattedDurationAttribute(): string
    {
        $hours = floor($this->duration_minutes / 60);
        $minutes = $this->duration_minutes % 60;

        if ($hours > 0 && $minutes > 0) {
            return "{$hours} سا {$minutes} د";
        } elseif ($hours > 0) {
            return "{$hours} سا";
        }
        return "{$minutes} دقيقة";
    }
}
