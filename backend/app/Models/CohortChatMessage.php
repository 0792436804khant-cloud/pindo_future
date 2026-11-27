<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class CohortChatMessage extends Model
{
    protected $fillable = [
        'cohort_id',
        'sender_id',
        'sender_role',
        'text',
        'message_type',
        'image_url',
        'link_url',
        'link_title',
        'file_name',
        'file_size_bytes',
        'is_pinned',
        'reactions',
    ];

    protected $casts = [
        'is_pinned' => 'boolean',
        'reactions' => 'array',
        'file_size_bytes' => 'integer',
    ];

    public function cohort(): BelongsTo
    {
        return $this->belongsTo(StudyCohort::class, 'cohort_id');
    }

    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    public function reads(): HasMany
    {
        return $this->hasMany(CohortMessageRead::class, 'message_id');
    }
}
