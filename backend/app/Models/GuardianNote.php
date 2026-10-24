<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GuardianNote extends Model
{
    use HasFactory;

    protected $fillable = [
        'student_id',
        'parent_id',
        'author_id',
        'title',
        'content',
        'type', // 'progress_report', 'attendance_alert', 'general'
        'is_acknowledged',
    ];

    protected function casts(): array
    {
        return [
            'is_acknowledged' => 'boolean',
        ];
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_id');
    }

    public function parent(): BelongsTo
    {
        return $this->belongsTo(User::class, 'parent_id');
    }

    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class, 'author_id');
    }
}
