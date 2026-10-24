<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TeacherPlatform extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'headline',
        'bio',
        'website_url',
        'settings',
    ];

    protected function casts(): array
    {
        return [
            'settings' => 'array',
        ];
    }

    /**
     * Teacher / Host relationship.
     */
    public function teacher(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * Courses created by this teacher.
     */
    public function courses(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Course::class, 'teacher_id', 'user_id');
    }

    /**
     * Get platform deep link URL.
     */
    public function getDeepLinkUrlAttribute(): string
    {
        $baseUrl = config('app.url', 'https://pindofuture.com');
        $teacherId = $this->teacher?->teacher_id ?? 'TCH_UNKNOWN';

        return "{$baseUrl}/teacher/{$teacherId}";
    }
}
