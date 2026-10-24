<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class CohortMaterial extends Model
{
    use HasFactory;

    protected $fillable = [
        'material_code',
        'cohort_id',
        'teacher_id',
        'title',
        'description',
        'file_path',
        'file_type',
        'file_size_bytes',
        'is_published',
        'downloads_count',
    ];

    protected function casts(): array
    {
        return [
            'is_published' => 'boolean',
            'downloads_count' => 'integer',
            'file_size_bytes' => 'integer',
        ];
    }

    protected static function boot()
    {
        parent::boot();

        static::creating(function (CohortMaterial $material) {
            if (empty($material->material_code)) {
                $material->material_code = self::generateUniqueMaterialCode();
            }
        });
    }

    public static function generateUniqueMaterialCode(): string
    {
        do {
            $code = 'MAT_' . strtoupper(Str::random(8));
        } while (self::where('material_code', $code)->exists());

        return $code;
    }

    public function cohort(): BelongsTo
    {
        return $this->belongsTo(StudyCohort::class, 'cohort_id');
    }

    public function teacher(): BelongsTo
    {
        return $this->belongsTo(User::class, 'teacher_id');
    }

    public function scopePublished(Builder $query): Builder
    {
        return $query->where('is_published', true);
    }
}
