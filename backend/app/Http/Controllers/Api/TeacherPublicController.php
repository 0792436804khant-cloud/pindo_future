<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Course;
use App\Models\Enrollment;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TeacherPublicController extends Controller
{
    /**
     * List and filter teachers by academic level, year, and subject.
     */
    public function index(Request $request): JsonResponse
    {
        $level = $request->query('level');
        $year = $request->query('year');
        $subject = $request->query('subject');
        $search = $request->query('q');

        $query = User::where('role', 'teacher')
            ->with(['teacherPlatform', 'classroomSessions' => function ($q) {
                $q->whereIn('status', ['active', 'scheduled'])
                  ->orderByRaw("CASE WHEN status = 'active' THEN 1 ELSE 2 END")
                  ->orderBy('scheduled_at', 'asc');
            }]);

        if ($search) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'ilike', "%{$search}%")
                  ->orWhere('email', 'ilike', "%{$search}%")
                  ->orWhere('teacher_id', 'ilike', "%{$search}%");
            });
        }

        $teachers = $query->get()->filter(function (User $teacher) use ($level, $year, $subject) {
            $levels = (array) ($teacher->teaching_levels ?? []);
            $years = (array) ($teacher->teaching_years ?? []);
            $subjects = (array) ($teacher->teaching_subjects ?? []);

            if ($level && !empty($levels)) {
                $hasLevel = false;
                foreach ($levels as $l) {
                    if (stripos($l, $level) !== false || stripos($level, $l) !== false) {
                        $hasLevel = true;
                        break;
                    }
                }
                if (!$hasLevel) return false;
            }

            if ($year && !empty($years)) {
                $hasYear = false;
                foreach ($years as $y) {
                    if (stripos($y, $year) !== false || stripos($year, $y) !== false) {
                        $hasYear = true;
                        break;
                    }
                }
                if (!$hasYear) return false;
            }

            if ($subject && !empty($subjects)) {
                $hasSubject = false;
                foreach ($subjects as $s) {
                    if (stripos($s, $subject) !== false || stripos($subject, $s) !== false) {
                        $hasSubject = true;
                        break;
                    }
                }
                if (!$hasSubject) return false;
            }

            return true;
        })->values();

        $data = $teachers->map(function (User $teacher) {
            $platform = $teacher->teacherPlatform;
            $settings = $platform?->settings ?? [];
            $activeSession = $teacher->classroomSessions->firstWhere('status', 'active');
            $totalStudents = Enrollment::whereIn('course_id', Course::where('teacher_id', $teacher->id)->pluck('id'))
                ->distinct('user_id')
                ->count('user_id');

            return [
                'id' => $teacher->id,
                'name' => $teacher->name,
                'email' => $teacher->email,
                'teacher_id' => $teacher->teacher_id,
                'deep_link_url' => $teacher->deep_link_url,
                'teaching_levels' => $teacher->teaching_levels ?? [],
                'teaching_years' => $teacher->teaching_years ?? [],
                'teaching_subjects' => $teacher->teaching_subjects ?? [],
                'avatar_url' => $settings['avatar_url'] ?? null,
                'years_of_experience' => $settings['years_of_experience'] ?? null,
                'student_achievements' => $settings['student_achievements'] ?? [],
                'headline' => $platform?->headline ?? 'Verified Instructor at Pindo Future',
                'bio' => $platform?->bio ?? '',
                'active_session' => $activeSession ? [
                    'id' => $activeSession->id,
                    'session_id' => $activeSession->session_id,
                    'title' => $activeSession->title,
                    'is_live' => true,
                ] : null,
                'metrics' => [
                    'total_courses' => Course::where('teacher_id', $teacher->id)->published()->count(),
                    'total_enrolled_students' => $totalStudents,
                ],
            ];
        });

        return response()->json([
            'status' => 'success',
            'data' => $data,
        ]);
    }

    /**
     * Retrieve public teacher showcase and landing details by teacher_id.
     * Serves deep links: pindofuture.com/teacher/{teacher_id}
     */
    public function show(string $teacherId): JsonResponse
    {
        $teacher = User::where('teacher_id', $teacherId)
            ->with(['teacherPlatform'])
            ->first();

        if (!$teacher) {
            return response()->json([
                'status' => 'error',
                'message' => "Teacher showcase not found for ID: {$teacherId}",
            ], 404);
        }

        // 1. Published Courses with Curriculum Structure
        $courses = Course::where('teacher_id', $teacher->id)
            ->published()
            ->with(['modules.lessons'])
            ->withCount(['students', 'modules', 'lessons'])
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function (Course $course) {
                return [
                    'id' => $course->id,
                    'title' => $course->title,
                    'slug' => $course->slug,
                    'description' => $course->description,
                    'category' => $course->category,
                    'price' => (float) $course->price,
                    'is_free' => (float) $course->price === 0.0,
                    'thumbnail_url' => $course->thumbnail_url,
                    'modules_count' => $course->modules_count,
                    'lessons_count' => $course->lessons_count,
                    'enrolled_students_count' => $course->students_count,
                    'created_at' => $course->created_at->toIso8601String(),
                ];
            });

        // 2. Upcoming & Active Dynamic Sessions (SES_...)
        $sessions = $teacher->classroomSessions()
            ->whereIn('status', ['active', 'scheduled'])
            ->orderByRaw("CASE WHEN status = 'active' THEN 1 ELSE 2 END")
            ->orderBy('scheduled_at', 'asc')
            ->get()
            ->map(function ($session) {
                return [
                    'id' => $session->id,
                    'session_id' => $session->session_id,
                    'title' => $session->title,
                    'description' => $session->description,
                    'status' => $session->status,
                    'is_live' => $session->status === 'active',
                    'max_participants' => $session->max_participants,
                    'scheduled_at' => $session->scheduled_at?->toIso8601String(),
                    'started_at' => $session->started_at?->toIso8601String(),
                ];
            });

        $activeSession = $sessions->firstWhere('is_live', true);

        // 3. Platform Profile & Branding
        $platform = $teacher->teacherPlatform;
        $settings = $platform?->settings ?? [];

        // 4. Aggregate Metrics
        $totalStudents = Enrollment::whereIn('course_id', Course::where('teacher_id', $teacher->id)->pluck('id'))
            ->distinct('user_id')
            ->count('user_id');

        return response()->json([
            'status' => 'success',
            'data' => [
                'teacher' => [
                    'id' => $teacher->id,
                    'name' => $teacher->name,
                    'email' => $teacher->email,
                    'teacher_id' => $teacher->teacher_id,
                    'deep_link_url' => $teacher->deep_link_url,
                    'teaching_levels' => $teacher->teaching_levels ?? [],
                    'teaching_years' => $teacher->teaching_years ?? [],
                    'teaching_subjects' => $teacher->teaching_subjects ?? [],
                    'avatar_url' => $settings['avatar_url'] ?? null,
                    'years_of_experience' => $settings['years_of_experience'] ?? null,
                    'student_achievements' => $settings['student_achievements'] ?? [],
                ],
                'platform' => [
                    'headline' => $platform?->headline ?? 'Verified Instructor at Pindo Future',
                    'bio' => $platform?->bio ?? 'Welcome to my educational studio! Explore my published courses and join dynamic live classroom streams.',
                    'website_url' => $platform?->website_url,
                    'settings' => $settings,
                    'avatar_url' => $settings['avatar_url'] ?? null,
                    'years_of_experience' => $settings['years_of_experience'] ?? null,
                    'student_achievements' => $settings['student_achievements'] ?? [],
                ],
                'metrics' => [
                    'total_courses' => $courses->count(),
                    'total_sessions_hosted' => $teacher->classroomSessions()->count(),
                    'total_enrolled_students' => $totalStudents,
                ],
                'active_session' => $activeSession,
                'upcoming_sessions' => $sessions->values(),
                'courses' => $courses->values(),
            ],
        ]);
    }
}
