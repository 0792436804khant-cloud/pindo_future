<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ReferralEvent extends Model
{
    use HasFactory;

    protected $fillable = [
        'teacher_id',
        'external_platform_id',
        'visitor_ip',
        'user_agent',
        'referrer_url',
        'registered_user_id',
        'converted_order_id',
    ];

    public function teacher(): BelongsTo
    {
        return $this->belongsTo(User::class, 'teacher_id');
    }

    public function platform(): BelongsTo
    {
        return $this->belongsTo(ExternalPlatform::class, 'external_platform_id');
    }

    public function registeredUser(): BelongsTo
    {
        return $this->belongsTo(User::class, 'registered_user_id');
    }

    public function convertedOrder(): BelongsTo
    {
        return $this->belongsTo(Order::class, 'converted_order_id');
    }
}
