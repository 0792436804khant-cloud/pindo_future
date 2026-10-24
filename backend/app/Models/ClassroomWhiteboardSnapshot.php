<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ClassroomWhiteboardSnapshot extends Model
{
    use HasFactory;

    protected $table = 'classroom_whiteboard_snapshots';

    protected $fillable = [
        'session_id',
        'classroom_session_id',
        'author_id',
        'snapshot_title',
        'vector_data',
        'stroke_count',
        'version',
        'thumbnail_url',
    ];

    protected function casts(): array
    {
        return [
            'vector_data' => 'array',
            'stroke_count' => 'integer',
            'version' => 'integer',
        ];
    }

    public function classroomSession(): BelongsTo
    {
        return $this->belongsTo(ClassroomSession::class, 'classroom_session_id');
    }

    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class, 'author_id');
    }
}
