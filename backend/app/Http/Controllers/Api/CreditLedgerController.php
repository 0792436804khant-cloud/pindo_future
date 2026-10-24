<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CreditLedger;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CreditLedgerController extends Controller
{
    /**
     * Get authenticated student's session credit balance and ledger history.
     */
    public function index(Request $request): JsonResponse
    {
        $student = $request->user();

        $balance = CreditLedger::getStudentBalance($student->id);

        $transactions = CreditLedger::where('student_id', $student->id)
            ->with(['order.course', 'classroomSession'])
            ->latest('id')
            ->limit(50)
            ->get()
            ->map(function (CreditLedger $entry) {
                return [
                    'id' => $entry->id,
                    'type' => $entry->type,
                    'credits_amount' => $entry->credits_amount,
                    'balance_after' => $entry->balance_after,
                    'notes' => $entry->notes,
                    'course_title' => $entry->order?->course?->title,
                    'session_title' => $entry->classroomSession?->title,
                    'created_at' => $entry->created_at->toIso8601String(),
                ];
            });

        return response()->json([
            'status' => 'success',
            'data' => [
                'student_id' => $student->student_id ?? (string) $student->id,
                'available_credits' => $balance,
                'transactions' => $transactions,
            ],
        ]);
    }
}
