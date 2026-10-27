<?php

namespace App\Services;

use App\Models\AppNotification;
use App\Models\ClassroomSession;
use App\Models\CohortMember;
use App\Models\Enrollment;
use App\Models\ParentStudent;
use App\Models\StudyCohort;
use App\Models\User;
use Illuminate\Support\Collection;

class NotificationService
{
    /**
     * Send a single notification to a user.
     */
    public function create(
        int $userId,
        string $type,
        string $title,
        string $body,
        array $data = []
    ): AppNotification {
        return AppNotification::create([
            'user_id' => $userId,
            'type' => $type,
            'title' => $title,
            'body' => $body,
            'data' => $data,
        ]);
    }

    /**
     * Notify all active students in a cohort.
     */
    public function notifyCohort(
        int $cohortId,
        string $type,
        string $title,
        string $body,
        array $data = []
    ): int {
        $studentIds = CohortMember::where('cohort_id', $cohortId)
            ->where('status', 'active')
            ->pluck('student_id')
            ->unique();

        if ($studentIds->isEmpty()) {
            return 0;
        }

        $now = now();
        $notifications = $studentIds->map(function (int $studentId) use ($type, $title, $body, $data, $now) {
            return [
                'user_id' => $studentId,
                'type' => $type,
                'title' => $title,
                'body' => $body,
                'data' => json_encode($data, JSON_UNESCAPED_UNICODE),
                'created_at' => $now,
                'updated_at' => $now,
            ];
        })->toArray();

        AppNotification::insert($notifications);

        return count($notifications);
    }

    /**
     * Trigger live alerts when a classroom session goes live.
     */
    public function notifySessionLive(ClassroomSession $session): int
    {
        $teacher = $session->teacher ?? User::find($session->user_id);
        $teacherName = $teacher?->name ?? 'الأستاذ';
        $sessionTitle = $session->title;

        $targetStudentIds = collect();

        // 1. If linked to a cohort
        if ($session->cohort_id) {
            $cohortStudentIds = CohortMember::where('cohort_id', $session->cohort_id)
                ->where('status', 'active')
                ->pluck('student_id');
            $targetStudentIds = $targetStudentIds->merge($cohortStudentIds);
        }

        // 2. If linked to a course/lesson
        if ($session->lesson?->module?->course_id) {
            $courseId = $session->lesson->module->course_id;
            $courseStudentIds = Enrollment::where('course_id', $courseId)
                ->where('status', Enrollment::STATUS_ACTIVE)
                ->pluck('user_id');
            $targetStudentIds = $targetStudentIds->merge($courseStudentIds);
        }

        $uniqueStudentIds = $targetStudentIds->unique()->values();

        if ($uniqueStudentIds->isEmpty()) {
            return 0;
        }

        $alertData = [
            'session_id' => $session->session_id,
            'cohort_id' => $session->cohort_id,
            'teacher_name' => $teacherName,
            'is_live' => true,
            'priority' => 'high',
            'action' => 'join_live_room',
        ];

        $title = "🔴 الحصة المباشرة بدأت الآن!";
        $body = "الأستاذ {$teacherName} بدأ البث المباشر لحصة: {$sessionTitle}. انضم الآن للمشاركة والتفاعل.";

        $now = now();
        $notifications = [];

        foreach ($uniqueStudentIds as $studentId) {
            $notifications[] = [
                'user_id' => $studentId,
                'type' => AppNotification::TYPE_LIVE_SESSION_STARTED,
                'title' => $title,
                'body' => $body,
                'data' => json_encode($alertData, JSON_UNESCAPED_UNICODE),
                'created_at' => $now,
                'updated_at' => $now,
            ];
        }

        // Also notify linked parents of these students
        $parentIds = ParentStudent::whereIn('student_id', $uniqueStudentIds)
            ->where('status', 'active')
            ->pluck('parent_id')
            ->unique();

        $parentTitle = "🎥 تنبيه ولي الأمر: بدأت حصة ابنكم المباشرة";
        $parentBody = "بدأت حصة ({$sessionTitle}) مع الأستاذ {$teacherName}. يمكنكم متابعة التزام ابنكم بالحضور عبر البوابة.";

        foreach ($parentIds as $parentId) {
            $notifications[] = [
                'user_id' => $parentId,
                'type' => AppNotification::TYPE_GUARDIAN_ALERT,
                'title' => $parentTitle,
                'body' => $parentBody,
                'data' => json_encode($alertData, JSON_UNESCAPED_UNICODE),
                'created_at' => $now,
                'updated_at' => $now,
            ];
        }

        if (!empty($notifications)) {
            AppNotification::insert($notifications);
        }

        return count($notifications);
    }
}
