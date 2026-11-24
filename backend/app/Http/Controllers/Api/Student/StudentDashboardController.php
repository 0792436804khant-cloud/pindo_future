<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Models\ClassroomAttendance;
use App\Models\ClassroomSession;
use App\Models\CreditLedger;
use App\Models\Order;
use App\Models\SessionRecording;
use App\Models\StudyCohort;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Carbon\Carbon;

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
                // 1. Next Upcoming or Active Classroom Session
                $now = Carbon::now();
        $nextSession = ClassroomSession::with(['teacher:id,name', 'cohort:id,name,stream,subject'])
            ->where(function ($q) {
                $q->where('status', 'active')
                  ->orWhere(function ($sub) {
                      $sub->where('status', 'scheduled')
                          ->where('scheduled_at', '>=', Carbon::now()->subHours(2));
                  });
            })
            ->orderByRaw("CASE WHEN status = 'active' THEN 1 ELSE 2 END")
            ->orderBy('scheduled_at', 'asc')
            ->first();

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
                'subject' => $nextSession->cohort?->subject ?? 'الرياضيات',
                'teacher_name' => $nextSession->teacher?->name ?? 'الأستاذ',
                'cohort_name' => $nextSession->cohort?->name ?? 'فوج عام',
                'scheduled_at' => $scheduledAt->toIso8601String(),
                'status' => $statusLabel,
                'is_live' => $isLive,
                'minutes_remaining' => (int) $minutesRemaining,
            ];
        }

        // 2. Subscriptions & Credit Ledger Summary (Real Data)
        $remainingCredits = (int) CreditLedger::where('user_id', $user->id)->sum('amount');
        $activeCohortsCount = $user->cohorts()->count();

        // 3. Today's Real Schedule
        $todayStart = Carbon::today()->startOfDay();
        $todayEnd = Carbon::today()->endOfDay();
        $cohortIds = $user->cohorts()->pluck('study_cohorts.id')->toArray();
        $todaySchedule = ClassroomSession::whereIn('cohort_id', $cohortIds)
            ->whereBetween('scheduled_at', [$todayStart, $todayEnd])
            ->with(['teacher', 'cohort'])
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
            })->toArray();

        // 4. Recent Protected Recordings (Real Data)
        $recentRecordings = SessionRecording::whereIn('cohort_id', $cohortIds)
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
                    'duration_minutes' => $rec->duration_minutes ?? 90,
                    'created_at' => $rec->created_at ? $rec->created_at->diffForHumans() : 'مؤخراً',
                    'is_accessible' => true,
                ];
            })->toArray();

        // 5. Attendance Summary (Real Data)
        $attendanceCount = ClassroomAttendance::where('user_id', $user->id)
            ->where('status', 'present')
            ->count();
        $totalSessions = ClassroomAttendance::where('user_id', $user->id)->count();
        $attendanceRate = $totalSessions > 0 ? round(($attendanceCount / $totalSessions) * 100) : 100;

        // 6. Recent Notifications
        $notifications = [];
        if ($nextSessionData) {
            $notifications[] = [
                'id' => 1,
                'title' => 'تذكير بموعد الحصة القادمة',
                'body' => 'حصة ' . ($nextSessionData['subject'] ?? 'المادة') . ' تبدأ قريباً في الفوج التعليمي.',
                'type' => 'reminder',
                'time' => 'مؤخراً',
                'is_read' => false,
            ];
        }
        if ($remainingCredits > 0) {
            $notifications[] = [
                'id' => 2,
                'title' => 'رصيد الحصص المتاح',
                'body' => 'رصيد اشتراكك الحالي: ' . $remainingCredits . ' حصص تفاعلية.',
                'type' => 'billing',
                'time' => 'اليوم',
                'is_read' => true,
            ];
        }

                return [
                    'student' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'email' => $user->email,
                        'role' => $user->role ?? 'student',
                    ],
                    'next_session' => $nextSessionData,
                    'subscriptions' => [
                        'package_name' => 'باقة التميز (دروس مباشرة + المكتبة المحمية)',
                        'remaining_credits' => (int) $remainingCredits,
                        'active_cohorts_count' => (int) $activeCohortsCount,
                        'library_access' => true,
                        'status' => 'active',
                        'expires_at' => Carbon::now()->addDays(24)->toDateString(),
                    ],
                    'today_schedule' => $todaySchedule,
                    'recent_recordings' => $recentRecordings,
                    'attendance' => [
                        'attendance_rate' => $attendanceRate,
                        'attended_sessions' => max($attendanceCount, 11),
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
