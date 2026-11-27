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

        $data = \Illuminate\Support\Facades\Cache::remember(
            "teacher:dashboard:{$teacher->id}",
            \App\Services\CacheManagerService::TTL_TEACHER_DASHBOARD,
            function () use ($teacher) {
                // 1. Cohorts and Students Metrics
                $cohorts = StudyCohort::where('teacher_id', $teacher->id)
                    ->orderByDesc('created_at')
                    ->get();
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
        $liveGrossSales = (float) (clone $earningsQuery)->sum('live_gross_amount');
        $libraryGrossSales = (float) (clone $earningsQuery)->sum('library_gross_amount');
        $livePlatformFees = (float) (clone $earningsQuery)->sum('live_platform_fee');
        $libraryPlatformFees = (float) (clone $earningsQuery)->sum('library_platform_fee');
        $totalPlatformFees = (float) (clone $earningsQuery)->sum('platform_fee');
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

        // 8. Real In-App Alerts & Notifications
        $notifications = \App\Models\AppNotification::forUser($teacher->id)
            ->latest()
            ->limit(10)
            ->get()
            ->map(function ($n) {
                return [
                    'id' => (string) $n->id,
                    'title' => $n->title,
                    'body' => $n->body,
                    'type' => $n->type,
                    'time' => $n->created_at?->diffForHumans() ?? 'مؤخراً',
                    'is_read' => $n->read_at !== null,
                ];
            })->toArray();

        if (empty($notifications) && $upcomingSessionData) {
            $notifications[] = [
                'id' => 'alert_upcoming',
                'title' => 'تذكير بالحصة المجدولة',
                'body' => 'لديك حصة قادمة: ' . $upcomingSessionData['title'],
                'type' => 'session',
                'time' => 'مؤخراً',
                'is_read' => false,
            ];
        }

        // 9. Cohorts Summary
        $cohortsList = $cohorts->map(function ($c) {
            $livePrice = (float) ($c->live_sessions_price > 0 ? $c->live_sessions_price : $c->monthly_price);
            $libPrice = $c->include_library ? (float) $c->library_price : 0.0;
            $bundlePrice = (float) ($c->bundle_price > 0 ? $c->bundle_price : ($livePrice + $libPrice));

            return [
                'id' => $c->id,
                'cohort_code' => $c->cohort_code,
                'name' => $c->name,
                'subject' => $c->subject,
                'academic_level' => $c->academic_level,
                'stream' => $c->stream,
                'enrolled_count' => $c->enrolled_count,
                'max_students' => $c->max_students,
                'monthly_price' => (float) ($c->monthly_price > 0 ? $c->monthly_price : $bundlePrice),
                'live_sessions_price' => $livePrice,
                'library_price' => $libPrice,
                'bundle_price' => $bundlePrice,
                'is_active' => $c->is_active,
                'has_library' => (bool) $c->include_library,
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
                    'student_name' => $e->order?->user?->name ?? 'طالب',
                    'title' => $e->course?->title ?? 'اشتراك فوج دراسي',
                    'amount' => (float) $e->net_amount,
                    'status' => $e->status,
                    'date' => $e->created_at->format('Y-m-d H:i'),
                ];
            });

                $teacher->loadMissing('teacherPlatform');
                $platformSettings = $teacher->teacherPlatform?->settings ?? [];

                return [
                    'teacher' => [
                        'id' => $teacher->id,
                        'name' => $teacher->name,
                        'email' => $teacher->email,
                        'teacher_id' => $teacher->teacher_id ?? 'TCH_' . $teacher->id,
                        'avatar_url' => $platformSettings['avatar_url'] ?? null,
                        'is_verified' => (bool) $teacher->is_verified,
                        'years_of_experience' => (int) ($platformSettings['years_of_experience'] ?? 0),
                        'headline' => $teacher->teacherPlatform?->headline ?? '',
                        'subjects' => $teacher->teaching_subjects ?? [],
                        'levels' => $teacher->teaching_levels ?? [],
                        'teaching_years' => $teacher->teaching_years ?? [],
                    ],
                    'stats' => [
                        'enrolled_students_count' => $enrolledStudentsCount,
                        'active_cohorts_count' => $activeCohortsCount,
                        'scheduled_sessions_count' => $scheduledSessionsCount,
                        'completed_sessions_count' => $completedSessionsCount,
                        'expired_credits_students_count' => $expiredCreditsCount,
                        'total_earnings' => $totalEarnings,
                        'gross_sales' => $grossSales,
                        'live_gross_sales' => $liveGrossSales,
                        'library_gross_sales' => $libraryGrossSales,
                        'live_platform_fees' => $livePlatformFees,
                        'library_platform_fees' => $libraryPlatformFees,
                        'total_platform_fees' => $totalPlatformFees,
                        'pending_earnings' => $pendingEarnings,
                        'library_recordings_count' => $libraryRecordingsCount,
                    ],
                    'upcoming_session' => $upcomingSessionData,
                    'today_schedule' => $todaySessions,
                    'notifications' => $notifications,
                    'cohorts' => $cohortsList,
                    'recent_transactions' => $recentTransactions,
                ];
            }
        );

        return response()->json([
            'status' => 'success',
            'data' => $data,
        ]);
    }
}
