<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class ExternalPlatform extends Model
{
    use HasFactory;

    protected $fillable = [
        'teacher_id',
        'platform_name',
        'website_url',
        'api_key',
        'webhook_url',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($model) {
            if (empty($model->api_key)) {
                $model->api_key = 'pf_live_' . Str::random(40);
            }
        });
    }

    public function teacher(): BelongsTo
    {
        return $this->belongsTo(User::class, 'teacher_id');
    }

    public function referrals(): HasMany
    {
        return $this->hasMany(ReferralEvent::class, 'external_platform_id');
    }
}
