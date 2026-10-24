<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Course;
use App\Models\Enrollment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StudentEnrollmentController extends Controller
{
    /**
     * Enroll authenticated student in a published course.
     */
    public function enroll(Request $request, int $courseId): JsonResponse
    {
        $user = $request->user();

        $course = Course::published()
            ->with(['teacher.teacherPlatform'])
            ->withCount(['modules', 'lessons'])
            ->find($courseId);

        if (!$course) {
            return response()->json([
                'status' => 'error',
                'message' => 'Course not found or is not currently open for enrollment.',
            ], 404);
        }

        // Prevent bypassing checkout on paid courses
        if ((float) $course->price > 0) {
            $hasPaidOrder = \App\Models\Order::where('user_id', $user->id)
                ->where('course_id', $course->id)
                ->where('status', \App\Models\Order::STATUS_COMPLETED)
                ->exists();

            if (!$hasPaidOrder) {
                return response()->json([
                    'status' => 'error',
                    'message' => "Payment required for '{$course->title}' ({$course->price} DZD). Please complete checkout to enroll.",
                    'requires_payment' => true,
                    'course_id' => $course->id,
                    'price' => (float) $course->price,
                    'currency' => 'DZD',
                ], 402);
            }
        }

        $existing = Enrollment::where('user_id', $user->id)
            ->where('course_id', $course->id)
            ->first();

        if ($existing) {
            if ($existing->status === Enrollment::STATUS_ACTIVE || $existing->status === Enrollment::STATUS_COMPLETED) {
                return response()->json([
                    'status' => 'success',
                    'message' => 'You are already enrolled in this course.',
                    'already_enrolled' => true,
                    'enrollment' => $existing->load('course'),
                ], 200);
            }

            // Reactivate cancelled enrollment
            $existing->update([
                'status' => Enrollment::STATUS_ACTIVE,
                'enrolled_at' => now(),
            ]);

            return response()->json([
                'status' => 'success',
                'message' => 'Enrollment reactivated successfully.',
                'enrollment' => $existing->fresh('course'),
            ], 200);
        }

        $enrollment = Enrollment::create([
            'user_id' => $user->id,
            'course_id' => $course->id,
            'status' => Enrollment::STATUS_ACTIVE,
            'enrolled_at' => now(),
            'progress_percentage' => 0,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => "Successfully enrolled in '{$course->title}'.",
            'enrollment' => [
                'id' => $enrollment->id,
                'course_id' => $course->id,
                'course_title' => $course->title,
                'course_slug' => $course->slug,
                'status' => $enrollment->status,
                'enrolled_at' => $enrollment->enrolled_at->toIso8601String(),
                'progress_percentage' => $enrollment->progress_percentage,
                'modules_count' => $course->modules_count,
                'lessons_count' => $course->lessons_count,
            ],
        ], 201);
    }

    /**
     * List all courses the authenticated student is currently enrolled in.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $enrollments = Enrollment::where('user_id', $user->id)
            ->whereIn('status', [Enrollment::STATUS_ACTIVE, Enrollment::STATUS_COMPLETED])
            ->with([
                'course.teacher.teacherPlatform',
                'course.modules.lessons.classroomSession',
            ])
            ->orderBy('enrolled_at', 'desc')
            ->get()
            ->map(function (Enrollment $enrollment) {
                $course = $enrollment->course;
                $allLessons = $course->modules->flatMap->lessons;
                $liveLessons = $allLessons->where('type', 'live_session');
                $nextLiveSession = $liveLessons->firstWhere('classroomSession.status', 'active') 
                    ?? $liveLessons->firstWhere('classroomSession.status', 'scheduled');

                return [
                    'enrollment_id' => $enrollment->id,
                    'status' => $enrollment->status,
                    'enrolled_at' => $enrollment->enrolled_at->toIso8601String(),
                    'progress_percentage' => $enrollment->progress_percentage,
                    'course' => [
                        'id' => $course->id,
                        'title' => $course->title,
                        'slug' => $course->slug,
                        'description' => $course->description,
                        'category' => $course->category,
                        'thumbnail_url' => $course->thumbnail_url,
                        'teacher' => [
                            'id' => $course->teacher->id,
                            'name' => $course->teacher->name,
                            'teacher_id' => $course->teacher->teacher_id,
                            'headline' => $course->teacher->teacherPlatform?->headline,
                        ],
                        'total_modules' => $course->modules->count(),
                        'total_lessons' => $allLessons->count(),
                        'live_lessons_count' => $liveLessons->count(),
                        'next_live_session' => $nextLiveSession?->classroomSession ? [
                            'session_id' => $nextLiveSession->classroomSession->session_id,
                            'title' => $nextLiveSession->classroomSession->title,
                            'status' => $nextLiveSession->classroomSession->status,
                            'is_live' => $nextLiveSession->classroomSession->status === 'active',
                            'scheduled_at' => $nextLiveSession->classroomSession->scheduled_at?->toIso8601String(),
                        ] : null,
                    ],
                ];
            });

        return response()->json([
            'status' => 'success',
            'data' => $enrollments,
        ]);
    }

    /**
     * Update student progress percentage for an enrolled course.
     */
    public function updateProgress(Request $request, int $courseId): JsonResponse
    {
        $validated = $request->validate([
            'progress_percentage' => 'required|integer|min:0|max:100',
        ]);

        $enrollment = Enrollment::where('user_id', $request->user()->id)
            ->where('course_id', $courseId)
            ->first();

        if (!$enrollment) {
            return response()->json([
                'status' => 'error',
                'message' => 'Active enrollment not found for this course.',
            ], 404);
        }

        $newPercentage = $validated['progress_percentage'];
        $newStatus = $newPercentage === 100 ? Enrollment::STATUS_COMPLETED : Enrollment::STATUS_ACTIVE;

        $enrollment->update([
            'progress_percentage' => $newPercentage,
            'status' => $newStatus,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Course progress updated successfully.',
            'enrollment' => [
                'id' => $enrollment->id,
                'course_id' => $enrollment->course_id,
                'progress_percentage' => $enrollment->progress_percentage,
                'status' => $enrollment->status,
            ],
        ]);
    }
}
