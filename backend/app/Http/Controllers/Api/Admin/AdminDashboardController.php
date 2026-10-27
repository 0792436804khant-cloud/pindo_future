<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\ClassroomSession;
use App\Models\StudyCohort;
use App\Models\TeacherEarning;
use App\Models\TeacherPayout;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminDashboardController extends Controller
{
    /**
     * Unified Admin Operations & Executive Telemetry Payload.
     */
    public function index(Request $request): JsonResponse
    {
        // 1. User & Role Counts
        $totalStudentsCount = User::where('role', 'student')->count();
        $totalTeachersCount = User::where('role', 'teacher')->count();
        $verifiedTeachersCount = User::where('role', 'teacher')
            ->where(function ($q) {
                $q->where('is_verified', true)
                  ->orWhere('isTeacherVerified', true);
            })->count();

        $pendingVerificationsCount = User::where('role', 'teacher')
            ->where('verification_status', 'pending')
            ->count();

        // 2. Academic & Live Classroom Telemetry
        $totalCohortsCount = StudyCohort::count();
        $activeLiveSessionsCount = ClassroomSession::where('status', ClassroomSession::STATUS_ACTIVE)->count();

        // 3. Platform Financials & Revenue Distribution (DZD)
        $grossRevenue = (float) TeacherEarning::sum('gross_amount');
        $platformCommission = (float) TeacherEarning::sum('platform_fee');
        $teacherNetEarnings = (float) TeacherEarning::sum('net_amount');

        // 4. Pending Teacher Payouts
        $pendingPayoutsQuery = TeacherPayout::where('status', TeacherPayout::STATUS_REQUESTED);
        $pendingPayoutsCount = $pendingPayoutsQuery->count();
        $pendingPayoutsAmount = (float) $pendingPayoutsQuery->sum('amount');

        // 5. Pending Verification Applications
        $pendingVerifications = User::where('role', 'teacher')
            ->where('verification_status', 'pending')
            ->orderByDesc('created_at')
            ->limit(10)
            ->get(['id', 'name', 'email', 'teacherId', 'wilaya', 'teaching_subjects', 'teaching_levels', 'created_at'])
            ->map(function ($t) {
                return [
                    'id' => $t->id,
                    'name' => $t->name,
                    'email' => $t->email,
                    'teacher_id' => $t->teacherId ?? 'TCH_' . $t->id,
                    'wilaya' => $t->wilaya ?? 'الجزائر العاصمة',
                    'subjects' => $t->teaching_subjects ?? ['الرياضيات'],
                    'submitted_at' => $t->created_at?->diffForHumans() ?? 'مؤخراً',
                ];
            });

        // 6. Pending Teacher Payout Requests
        $pendingPayouts = TeacherPayout::where('status', TeacherPayout::STATUS_REQUESTED)
            ->with('teacher')
            ->orderByDesc('created_at')
            ->limit(10)
            ->get()
            ->map(function ($p) {
                return [
                    'id' => $p->id,
                    'reference' => $p->payout_reference,
                    'teacher_id' => $p->teacher_id,
                    'teacher_name' => $p->teacher?->name ?? 'أستاذ',
                    'amount' => (float) $p->amount,
                    'currency' => $p->currency ?? 'DZD',
                    'payout_method' => $p->payout_method ?? 'BaridiMob',
                    'destination_account' => $p->destination_account ?? '00799999000123456789',
                    'status' => $p->status,
                    'requested_at' => $p->created_at?->diffForHumans() ?? 'مؤخراً',
                ];
            });

        return response()->json([
            'status' => 'success',
            'data' => [
                'kpis' => [
                    'total_students_count' => $totalStudentsCount,
                    'total_teachers_count' => $totalTeachersCount,
                    'verified_teachers_count' => $verifiedTeachersCount,
                    'pending_verifications_count' => $pendingVerificationsCount,
                    'total_cohorts_count' => $totalCohortsCount,
                    'active_live_sessions_count' => $activeLiveSessionsCount,
                    'gross_revenue' => $grossRevenue,
                    'platform_commission' => $platformCommission,
                    'teacher_net_earnings' => $teacherNetEarnings,
                    'pending_payouts_count' => $pendingPayoutsCount,
                    'pending_payouts_amount' => $pendingPayoutsAmount,
                    'sfu_cluster_capacity' => 30000,
                    'sfu_cluster_status' => 'Operational',
                ],
                'pending_verifications' => $pendingVerifications,
                'pending_payouts' => $pendingPayouts,
            ],
        ]);
    }

    /**
     * List all teacher payout requests.
     */
    public function payouts(Request $request): JsonResponse
    {
        $status = $request->query('status');

        $payouts = TeacherPayout::when($status, fn ($q) => $q->where('status', $status))
            ->with('teacher')
            ->orderByDesc('created_at')
            ->paginate(20);

        return response()->json([
            'status' => 'success',
            'data' => $payouts,
        ]);
    }

    /**
     * Approve and mark payout as completed.
     */
    public function approvePayout(int $id, Request $request): JsonResponse
    {
        $payout = TeacherPayout::findOrFail($id);

        $payout->update([
            'status' => TeacherPayout::STATUS_COMPLETED,
            'processed_at' => now(),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم تأكيد تحويل المستحقات وإتمام عملية السحب بنجاح',
            'data' => $payout,
        ]);
    }

    /**
     * Reject a teacher payout request.
     */
    public function rejectPayout(int $id, Request $request): JsonResponse
    {
        $payout = TeacherPayout::findOrFail($id);

        $payout->update([
            'status' => TeacherPayout::STATUS_REJECTED,
            'processed_at' => now(),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم رفض طلب السحب',
            'data' => $payout,
        ]);
    }
}
