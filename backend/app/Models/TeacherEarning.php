<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TeacherEarning extends Model
{
    use HasFactory;

    public const STATUS_AVAILABLE = 'available';
    public const STATUS_PENDING = 'pending';
    public const STATUS_PAID_OUT = 'paid_out';

    protected $fillable = [
        'teacher_id',
        'order_id',
        'course_id',
        'cohort_id',
        'package_type',
        'live_gross_amount',
        'library_gross_amount',
        'live_platform_fee',
        'library_platform_fee',
        'gross_amount',
        'platform_fee',
        'net_amount',
        'status',
        'payout_id',
    ];

    protected function casts(): array
    {
        return [
            'live_gross_amount' => 'decimal:2',
            'library_gross_amount' => 'decimal:2',
            'live_platform_fee' => 'decimal:2',
            'library_platform_fee' => 'decimal:2',
            'gross_amount' => 'decimal:2',
            'platform_fee' => 'decimal:2',
            'net_amount' => 'decimal:2',
        ];
    }

    public function teacher(): BelongsTo
    {
        return $this->belongsTo(User::class, 'teacher_id');
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    public function course(): BelongsTo
    {
        return $this->belongsTo(Course::class);
    }

    public function payout(): BelongsTo
    {
        return $this->belongsTo(TeacherPayout::class, 'payout_id');
    }
}
