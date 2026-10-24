<?php

namespace App\Http\Controllers\Api\Teacher;

use App\Http\Controllers\Controller;
use App\Models\TeacherEarning;
use App\Models\TeacherPayout;
use Exception;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TeacherEarningsController extends Controller
{
    /**
     * Get instructor revenue summary, earnings breakdown, and payout history.
     */
    public function index(Request $request): JsonResponse
    {
        $teacher = $request->user();

        // 1. Aggregated Financial KPIs
        $earningsQuery = TeacherEarning::where('teacher_id', $teacher->id);

        $grossSales = (float) $earningsQuery->sum('gross_amount');
        $platformFees = (float) $earningsQuery->sum('platform_fee');
        $totalNetEarned = (float) $earningsQuery->sum('net_amount');

        $availableBalance = (float) TeacherEarning::where('teacher_id', $teacher->id)
            ->where('status', TeacherEarning::STATUS_AVAILABLE)
            ->sum('net_amount');

        $pendingPayoutBalance = (float) TeacherEarning::where('teacher_id', $teacher->id)
            ->where('status', TeacherEarning::STATUS_PENDING)
            ->sum('net_amount');

        $completedPayoutBalance = (float) TeacherEarning::where('teacher_id', $teacher->id)
            ->where('status', TeacherEarning::STATUS_PAID_OUT)
            ->sum('net_amount');

        $totalSalesCount = $earningsQuery->count();

        // 2. Recent Sales Transactions
        $transactions = TeacherEarning::where('teacher_id', $teacher->id)
            ->with(['order.user', 'course'])
            ->orderBy('created_at', 'desc')
            ->limit(20)
            ->get()
            ->map(function (TeacherEarning $e) {
                return [
                    'id' => $e->id,
                    'order_number' => $e->order?->order_number,
                    'course_id' => $e->course_id,
                    'course_title' => $e->course?->title ?? 'Course',
                    'student_name' => $e->order?->user?->name ?? 'Student',
                    'gross_amount' => $e->gross_amount,
                    'platform_fee' => $e->platform_fee,
                    'net_amount' => $e->net_amount,
                    'status' => $e->status,
                    'created_at' => $e->created_at->toIso8601String(),
                ];
            });

        // 3. Payout Disbursements
        $payouts = TeacherPayout::where('teacher_id', $teacher->id)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function (TeacherPayout $p) {
                return [
                    'id' => $p->id,
                    'payout_reference' => $p->payout_reference,
                    'amount' => $p->amount,
                    'currency' => $p->currency,
                    'status' => $p->status,
                    'payout_method' => $p->payout_method,
                    'destination_account' => $p->destination_account,
                    'processed_at' => $p->processed_at?->toIso8601String(),
                    'created_at' => $p->created_at->toIso8601String(),
                ];
            });

        return response()->json([
            'status' => 'success',
            'summary' => [
                'gross_sales' => round($grossSales, 2),
                'platform_fees' => round($platformFees, 2),
                'total_net_earned' => round($totalNetEarned, 2),
                'available_balance' => round($availableBalance, 2),
                'pending_payout' => round($pendingPayoutBalance, 2),
                'paid_out' => round($completedPayoutBalance, 2),
                'total_sales_count' => $totalSalesCount,
                'revenue_split' => '80% Instructor / 20% Platform',
            ],
            'transactions' => $transactions,
            'payouts' => $payouts,
        ]);
    }

    /**
     * Request a payout disbursement of available earnings.
     */
    public function requestPayout(Request $request): JsonResponse
    {
        $teacher = $request->user();

        $validated = $request->validate([
            'amount' => 'required|numeric|min:1000.00',
            'payout_method' => 'nullable|string|in:stripe_connect,bank_transfer,paypal',
            'destination_account' => 'required|string|max:100',
        ]);

        $requestedAmount = (float) $validated['amount'];
        $availableBalance = (float) TeacherEarning::where('teacher_id', $teacher->id)
            ->where('status', TeacherEarning::STATUS_AVAILABLE)
            ->sum('net_amount');

        if ($requestedAmount > $availableBalance) {
            return response()->json([
                'status' => 'error',
                'message' => "Requested payout amount ({$requestedAmount} DZD) exceeds your available balance ({$availableBalance} DZD).",
            ], 422);
        }

        return DB::transaction(function () use ($teacher, $requestedAmount, $validated) {
            // Create payout record
            $payout = TeacherPayout::create([
                'teacher_id' => $teacher->id,
                'amount' => $requestedAmount,
                'currency' => 'DZD',
                'status' => TeacherPayout::STATUS_REQUESTED,
                'payout_method' => $validated['payout_method'] ?? 'bank_transfer',
                'destination_account' => $validated['destination_account'],
            ]);

            // Allocate and lock available earnings up to requested amount
            $availableEarnings = TeacherEarning::where('teacher_id', $teacher->id)
                ->where('status', TeacherEarning::STATUS_AVAILABLE)
                ->orderBy('created_at', 'asc')
                ->lockForUpdate()
                ->get();

            $accumulated = 0.0;
            foreach ($availableEarnings as $earning) {
                if ($accumulated >= $requestedAmount) {
                    break;
                }
                $accumulated += (float) $earning->net_amount;
                $earning->update([
                    'status' => TeacherEarning::STATUS_PENDING,
                    'payout_id' => $payout->id,
                ]);
            }

            return response()->json([
                'status' => 'success',
                'message' => "Payout request '{$payout->payout_reference}' of {$payout->amount} DZD submitted successfully.",
                'payout' => [
                    'id' => $payout->id,
                    'payout_reference' => $payout->payout_reference,
                    'amount' => $payout->amount,
                    'status' => $payout->status,
                    'created_at' => $payout->created_at->toIso8601String(),
                ],
            ], 201);
        });
    }
}
