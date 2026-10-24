<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CreditLedger extends Model
{
    use HasFactory;

    protected $fillable = [
        'student_id',
        'order_id',
        'classroom_session_id',
        'type',
        'credits_amount',
        'balance_after',
        'notes',
    ];

    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_id');
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class, 'order_id');
    }

    public function classroomSession(): BelongsTo
    {
        return $this->belongsTo(ClassroomSession::class, 'classroom_session_id');
    }

    /**
     * Get the latest credit balance for a student.
     */
    public static function getStudentBalance(int $studentId): int
    {
        $latest = static::where('student_id', $studentId)
            ->latest('id')
            ->first();

        return $latest ? (int) $latest->balance_after : 0;
    }
}
