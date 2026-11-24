<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use App\Models\ClassroomAttendance;
use App\Models\ClassroomSession;
use App\Models\CohortMember;
use App\Models\CreditLedger;
use App\Models\SessionRecording;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StudentDashboardController extends Controller
{
    /**
     * Retrieve complete unified student dashboard payload.
     * Aligns with Pindo Future Student Module Specification.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $data = \Illuminate\Support\Facades\Cache::remember(
            "student:dashboard:{$user->id}",
            \App\Services\CacheManagerService::TTL_STUDENT_DASHBOARD,
            function () use ($user) {
                $now = Carbon::now();

                // 1. Active Cohort Memberships & Real Credit Ledger Balance
                $activeMemberships = CohortMember::where('student_id', $user->id)
                    ->active()
                    ->get(['cohort_id', 'ends_at']);
                $cohortIds = $activeMemberships->pluck('cohort_id')->toArray();
                $activeCohortsCount = count($cohortIds);
                $remainingCredits = CreditLedger::getStudentBalance($user->id);

                // 2. Next Upcoming or Active Classroom Session in Student's Enrolled Cohorts
                $nextSession = !empty($cohortIds)
                    ? ClassroomSession::with(['teacher:id,name', 'cohort:id,name,stream,subject'])
                        ->whereIn('cohort_id', $cohortIds)
                        ->where(function ($q) {
                            $q->where('status', 'active')
                              ->orWhere(function ($sub) {
                                  $sub->where('status', 'scheduled')
                                      ->where('scheduled_at', '>=', Carbon::now()->subHours(2));
                              });
                        })
                        ->orderByRaw("CASE WHEN status = 'active' THEN 1 ELSE 2 END")
                        ->orderBy('scheduled_at', 'asc')
                        ->first()
                    : null;

                $nextSessionData = null;
                if ($nextSession) {
                    $isLive = $nextSession->status === 'active';
                    $scheduledAt = Carbon::parse($nextSession->scheduled_at);
                    $minutesRemaining = $now->diffInMinutes($scheduledAt, false);

                    $statusLabel = 'scheduled';
                    if ($isLive) {
                        $statusLabel = 'live';
                    } elseif ($minutesRemaining < 0 && abs($minutesRemaining) > 15) {
                        $statusLabel = 'delayed';
                    } elseif ($minutesRemaining <= 30 && $minutesRemaining >= 0) {
                        $statusLabel = 'imminent';
                    }

                    $nextSessionData = [
                        'id' => $nextSession->id,
                        'session_id' => $nextSession->session_id,
                        'title' => $nextSession->title,
                        'subject' => $nextSession->cohort?->subject ?? 'مادة دراسية',
                        'teacher_name' => $nextSession->teacher?->name ?? 'الأستاذ',
                        'cohort_name' => $nextSession->cohort?->name ?? 'فوج عام',
                        'scheduled_at' => $scheduledAt->toIso8601String(),
                        'status' => $statusLabel,
                        'is_live' => $isLive,
                        'minutes_remaining' => (int) $minutesRemaining,
                    ];
                }

                // 3. Today's Real Schedule
                $todayStart = Carbon::today()->startOfDay();
                $todayEnd = Carbon::today()->endOfDay();
                $todaySchedule = !empty($cohortIds)
                    ? ClassroomSession::whereIn('cohort_id', $cohortIds)
                        ->whereBetween('scheduled_at', [$todayStart, $todayEnd])
                        ->with(['teacher:id,name', 'cohort:id,name,subject'])
                        ->orderBy('scheduled_at', 'asc')
                        ->get()
                        ->map(function ($s) {
                            return [
                                'time' => $s->scheduled_at?->format('H:i') ?? '00:00',
                                'subject' => $s->cohort?->subject ?? 'مادة تعليمية',
                                'teacher' => $s->teacher?->name ?? 'الأستاذ',
                                'topic' => $s->title,
                                'status' => $s->status === 'active' ? 'live' : 'scheduled',
                            ];
                        })->toArray()
                    : [];

                // 4. Recent Protected Recordings (Real Data)
                $recentRecordings = !empty($cohortIds)
                    ? SessionRecording::whereIn('cohort_id', $cohortIds)
                        ->where('is_published', true)
                        ->with(['session.cohort', 'session.teacher'])
                        ->latest()
                        ->take(4)
                        ->get()
                        ->map(function ($rec) {
                            return [
                                'id' => $rec->id,
                                'title' => $rec->title,
                                'subject' => $rec->session?->cohort?->subject ?? 'العلوم',
                                'teacher_name' => $rec->session?->teacher?->name ?? 'الأستاذ',
                                'duration_minutes' => $rec->duration_seconds ? (int) max(1, round($rec->duration_seconds / 60)) : 0,
                                'created_at' => $rec->created_at ? $rec->created_at->diffForHumans() : 'مؤخراً',
                                'is_accessible' => true,
                            ];
                        })->toArray()
                    : [];

                // 5. Attendance Summary (Real Data matching classroom_attendances schema)
                $attendanceCount = ClassroomAttendance::where('user_id', $user->id)->count();
                $endedCohortSessionsCount = !empty($cohortIds)
                    ? ClassroomSession::whereIn('cohort_id', $cohortIds)
                        ->where('status', ClassroomSession::STATUS_ENDED)
                        ->count()
                    : 0;
                $totalSessions = max($attendanceCount, $endedCohortSessionsCount);
                $attendanceRate = $totalSessions > 0
                    ? (int) min(100, round(($attendanceCount / $totalSessions) * 100))
                    : 100;

                // 6. Recent Notifications (Real DB Notifications)
                $notifications = AppNotification::forUser($user->id)
                    ->latest()
                    ->take(10)
                    ->get()
                    ->map(function (AppNotification $n) {
                        return [
                            'id' => $n->id,
                            'title' => $n->title,
                            'body' => $n->body,
                            'type' => $n->type,
                            'time' => $n->created_at?->diffForHumans() ?? 'مؤخراً',
                            'is_read' => $n->read_at !== null,
                        ];
                    })->toArray();

                if (empty($notifications) && $nextSessionData) {
                    $notifications[] = [
                        'id' => 1,
                        'title' => 'تذكير بموعد الحصة القادمة',
                        'body' => 'حصة ' . ($nextSessionData['subject'] ?? 'المادة') . ' تبدأ قريباً في الفوج التعليمي.',
                        'type' => 'reminder',
                        'time' => 'مؤخراً',
                        'is_read' => false,
                    ];
                }

                $hasActiveSub = $activeCohortsCount > 0 || $remainingCredits > 0;
                $latestEndDate = $activeMemberships->pluck('ends_at')->filter()->sortDesc()->first();

                return [
                    'student' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'email' => $user->email,
                        'role' => $user->role ?? 'student',
                    ],
                    'next_session' => $nextSessionData,
                    'subscriptions' => [
                        'package_name' => $hasActiveSub
                            ? 'باقة الأفواج النشطة والمكتبة الرقمية'
                            : 'لا يوجد اشتراك نشط',
                        'remaining_credits' => (int) $remainingCredits,
                        'active_cohorts_count' => (int) $activeCohortsCount,
                        'library_access' => $hasActiveSub,
                        'status' => $hasActiveSub ? 'active' : 'inactive',
                        'expires_at' => $latestEndDate?->toDateString() ?? '',
                    ],
                    'today_schedule' => $todaySchedule,
                    'recent_recordings' => $recentRecordings,
                    'attendance' => [
                        'attendance_rate' => $attendanceRate,
                        'attended_sessions' => $attendanceCount,
                        'total_sessions' => $totalSessions,
                    ],
                    'notifications' => $notifications,
                ];
            }
        );

        return response()->json([
            'status' => 'success',
            'data' => $data,
        ]);
    }
}
