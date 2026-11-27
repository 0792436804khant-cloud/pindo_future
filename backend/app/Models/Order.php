<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Support\Str;

class Order extends Model
{
    use HasFactory;

    public const STATUS_PENDING = 'pending';
    public const STATUS_COMPLETED = 'completed';
    public const STATUS_FAILED = 'failed';
    public const STATUS_REFUNDED = 'refunded';

    protected $fillable = [
        'order_number',
        'user_id',
        'course_id',
        'cohort_id',
        'package_type',
        'amount',
        'currency',
        'status',
        'payment_method',
        'gateway_transaction_id',
        'receipt_number',
        'receipt_image_path',
        'receipt_hash',
        'tx_reference',
        'rejection_reason',
        'payment_metadata',
        'paid_at',
        'subscription_ends_at',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'payment_metadata' => 'array',
            'paid_at' => 'datetime',
            'subscription_ends_at' => 'datetime',
        ];
    }

    protected static function boot()
    {
        parent::boot();

        static::creating(function (Order $order) {
            if (empty($order->order_number)) {
                $order->order_number = 'ORD_' . date('Ymd') . '_' . strtoupper(Str::random(6));
            }
            if (empty($order->receipt_number)) {
                $order->receipt_number = 'RCP_' . strtoupper(Str::random(10));
            }
        });
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function course(): BelongsTo
    {
        return $this->belongsTo(Course::class);
    }

    public function cohort(): BelongsTo
    {
        return $this->belongsTo(StudyCohort::class, 'cohort_id');
    }

    public function earning(): HasOne
    {
        return $this->hasOne(TeacherEarning::class);
    }
}
