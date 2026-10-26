<?php

namespace App\Http\Controllers\Api\Teacher;

use App\Http\Controllers\Controller;
use App\Models\ClassroomAttendance;
use App\Models\ClassroomSession;
use App\Models\CohortMember;
use App\Models\CreditLedger;
use App\Models\SessionRecording;
use App\Models\StudyCohort;
use App\Models\TeacherEarning;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class TeacherDashboardController extends Controller
{
    /**
     * Unified Teacher Dashboard Payload
     * Supplies comprehensive metrics for KPIs, Upcoming/Live session,
     * Today's schedule, Groups summary, Finance overview, and Alerts.
     */
    public function index(Request $request): JsonResponse
    {
        $teacher = $request->user();

        // 1. Cohorts and Students Metrics
        $cohorts = StudyCohort::where('teacher_id', $teacher->id)->get();
        $cohortIds = $cohorts->pluck('id')->toArray();

        $enrolledStudentsCount = CohortMember::whereIn('cohort_id', $cohortIds)
            ->where('status', 'active')
            ->distinct('student_id')
            ->count('student_id');

        $activeCohortsCount = $cohorts->where('is_active', true)->count();

        // 2. Classroom Sessions Metrics
        $sessionsQuery = ClassroomSession::where('user_id', $teacher->id);
        $scheduledSessionsCount = (clone $sessionsQuery)
            ->where('status', ClassroomSession::STATUS_SCHEDULED)
            ->where('scheduled_at', '>=', now())
            ->count();

        $completedSessionsCount = (clone $sessionsQuery)
            ->where('status', ClassroomSession::STATUS_ENDED)
            ->count();

        // 3. Expired Credits Students Count (students with 0 balance)
        $memberStudentIds = CohortMember::whereIn('cohort_id', $cohortIds)
            ->pluck('student_id')
            ->unique();

        $expiredCreditsCount = 0;
        foreach ($memberStudentIds as $sId) {
            if (CreditLedger::getStudentBalance($sId) <= 0) {
                $expiredCreditsCount++;
            }
        }

        // 4. Financial KPIs (DZD)
        $earningsQuery = TeacherEarning::where('teacher_id', $teacher->id);
        $totalEarnings = (float) (clone $earningsQuery)->sum('net_amount');
        $grossSales = (float) (clone $earningsQuery)->sum('gross_amount');
        $pendingEarnings = (float) TeacherEarning::where('teacher_id', $teacher->id)
            ->where('status', TeacherEarning::STATUS_PENDING)
            ->sum('net_amount');

        // 5. Educational Library Recordings
        $libraryRecordingsCount = SessionRecording::whereIn('cohort_id', $cohortIds)->count();

        // 6. Next Upcoming or Currently Live Session
        $upcomingSession = ClassroomSession::where('user_id', $teacher->id)
            ->whereIn('status', [ClassroomSession::STATUS_ACTIVE, ClassroomSession::STATUS_SCHEDULED])
            ->where(function ($q) {
                $q->where('status', ClassroomSession::STATUS_ACTIVE)
                  ->orWhere('scheduled_at', '>=', now()->subMinutes(30));
            })
            ->with('cohort')
            ->orderByRaw("CASE WHEN status = 'active' THEN 1 ELSE 2 END")
            ->orderBy('scheduled_at', 'asc')
            ->first();

        $upcomingSessionData = null;
        if ($upcomingSession) {
            $upcomingSessionData = [
                'id' => $upcomingSession->id,
                'session_id' => $upcomingSession->session_id,
                'title' => $upcomingSession->title,
                'cohort_id' => $upcomingSession->cohort_id,
                'cohort_name' => $upcomingSession->cohort?->name ?? 'فوج عام',
                'subject' => $upcomingSession->cohort?->subject ?? 'مادة دراسية',
                'scheduled_at' => $upcomingSession->scheduled_at?->toIso8601String(),
                'status' => $upcomingSession->status,
                'is_live' => $upcomingSession->status === ClassroomSession::STATUS_ACTIVE,
                'max_participants' => $upcomingSession->max_participants,
                'enrolled_students' => $upcomingSession->cohort?->enrolled_count ?? 0,
            ];
        }

        // 7. Today's Schedule
        $todayStart = Carbon::today()->startOfDay();
        $todayEnd = Carbon::today()->endOfDay();

        $todaySessions = ClassroomSession::where('user_id', $teacher->id)
            ->whereBetween('scheduled_at', [$todayStart, $todayEnd])
            ->with('cohort')
            ->orderBy('scheduled_at', 'asc')
            ->get()
            ->map(function ($s) {
                return [
                    'id' => $s->id,
                    'session_id' => $s->session_id,
                    'title' => $s->title,
                    'cohort_name' => $s->cohort?->name ?? 'فوج عام',
                    'subject' => $s->cohort?->subject ?? 'مادة تعليمية',
                    'scheduled_at' => $s->scheduled_at?->toIso8601String(),
                    'time_formatted' => $s->scheduled_at?->format('H:i') ?? '00:00',
                    'status' => $s->status,
                ];
            });

        // 8. Alerts & Notifications
        $notifications = [
            [
                'id' => 'alert_1',
                'title' => 'تذكير بالحصة المجدولة',
                'body' => $upcomingSessionData ? 'لديك حصة قادمة: ' . $upcomingSessionData['title'] : 'جدول حصصك منتظم هذا الأسبوع',
                'type' => 'session',
                'time' => 'منذ 10 دقائق',
                'is_read' => false,
            ],
            [
                'id' => 'alert_2',
                'title' => 'تأكيد عملية دفع جديدة',
                'body' => 'تم استلام وتأكيد اشتراك طالب جديد في فوج البكالوريا.',
                'type' => 'payment',
                'time' => 'منذ ساعة',
                'is_read' => true,
            ],
            [
                'id' => 'alert_3',
                'title' => 'تنبيه انتهاء رصيد طالب',
                'body' => $expiredCreditsCount > 0 ? "يوجد {$expiredCreditsCount} طالب استنفدوا رصيد الحصص وبانتظار التجديد." : 'جميع اشتراكات الطلاب نشطة حالياً.',
                'type' => 'credit',
                'time' => 'منذ 3 ساعات',
                'is_read' => true,
            ],
        ];

        // 9. Cohorts Summary
        $cohortsList = $cohorts->map(function ($c) {
            return [
                'id' => $c->id,
                'cohort_code' => $c->cohort_code,
                'name' => $c->name,
                'subject' => $c->subject,
                'academic_level' => $c->academic_level,
                'stream' => $c->stream,
                'enrolled_count' => $c->enrolled_count,
                'max_students' => $c->max_students,
                'monthly_price' => (float) $c->monthly_price,
                'is_active' => $c->is_active,
                'has_library' => true,
            ];
        });

        // 10. Recent Transactions
        $recentTransactions = TeacherEarning::where('teacher_id', $teacher->id)
            ->with(['order.user', 'course'])
            ->orderBy('created_at', 'desc')
            ->limit(5)
            ->get()
            ->map(function ($e) {
                return [
                    'id' => $e->id,
                    'student_name' => $e->order?->user?->name ?? 'طالب جديد',
                    'title' => $e->course?->title ?? 'اشتراك فوج دراسي',
                    'amount' => (float) $e->net_amount,
                    'status' => $e->status,
                    'date' => $e->created_at->format('Y-m-d H:i'),
                ];
            });

        return response()->json([
            'status' => 'success',
            'data' => [
                'teacher' => [
                    'id' => $teacher->id,
                    'name' => $teacher->name,
                    'email' => $teacher->email,
                    'teacher_id' => $teacher->teacherId ?? 'TCH_' . $teacher->id,
                    'avatar_url' => $teacher->avatarUrl,
                    'is_verified' => (bool) $teacher->isTeacherVerified,
                    'years_of_experience' => $teacher->yearsOfExperience ?? 5,
                    'headline' => $teacher->headline ?? 'أستاذ معتمد في المنصة',
                    'subjects' => $teacher->teachingSubjects ?? ['الرياضيات'],
                    'levels' => $teacher->teachingLevels ?? ['ثانوي'],
                ],
                'stats' => [
                    'enrolled_students_count' => $enrolledStudentsCount,
                    'active_cohorts_count' => $activeCohortsCount,
                    'scheduled_sessions_count' => $scheduledSessionsCount,
                    'completed_sessions_count' => $completedSessionsCount,
                    'expired_credits_students_count' => $expiredCreditsCount,
                    'total_earnings' => $totalEarnings,
                    'gross_sales' => $grossSales,
                    'pending_earnings' => $pendingEarnings,
                    'library_recordings_count' => $libraryRecordingsCount,
                ],
                'upcoming_session' => $upcomingSessionData,
                'today_schedule' => $todaySessions,
                'notifications' => $notifications,
                'cohorts' => $cohortsList,
                'recent_transactions' => $recentTransactions,
            ],
        ]);
    }
}
