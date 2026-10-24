<?php

namespace App\Http\Controllers\Api\Teacher;

use App\Http\Controllers\Controller;
use App\Models\ClassroomSession;
use App\Models\Course;
use App\Models\CourseLesson;
use App\Models\CourseModule;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class TeacherCourseController extends Controller
{
    /**
     * List all courses owned by the authenticated teacher.
     */
    public function index(Request $request): JsonResponse
    {
        $courses = Course::where('teacher_id', $request->user()->id)
            ->withCount(['modules', 'lessons', 'students'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $courses,
        ]);
    }

    /**
     * Create a new course.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'category' => 'nullable|string|max:100',
            'price' => 'nullable|numeric|min:0',
            'thumbnail_url' => 'nullable|url',
            'status' => ['nullable', Rule::in(Course::ALL_STATUSES)],
        ]);

        $course = Course::create([
            'teacher_id' => $request->user()->id,
            'title' => $validated['title'],
            'description' => $validated['description'] ?? null,
            'category' => $validated['category'] ?? 'General',
            'price' => $validated['price'] ?? 0.00,
            'thumbnail_url' => $validated['thumbnail_url'] ?? null,
            'status' => $validated['status'] ?? Course::STATUS_DRAFT,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Course created successfully.',
            'data' => $course->load(['modules', 'lessons']),
        ], 201);
    }

    /**
     * Show full course details including curriculum modules and lessons.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $course = Course::where('teacher_id', $request->user()->id)
            ->with(['modules.lessons.classroomSession'])
            ->withCount(['students'])
            ->findOrFail($id);

        return response()->json([
            'status' => 'success',
            'data' => $course,
        ]);
    }

    /**
     * Update course metadata.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $course = Course::where('teacher_id', $request->user()->id)->findOrFail($id);

        $validated = $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'category' => 'nullable|string|max:100',
            'price' => 'nullable|numeric|min:0',
            'thumbnail_url' => 'nullable|url',
            'status' => ['nullable', Rule::in(Course::ALL_STATUSES)],
        ]);

        $course->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Course updated successfully.',
            'data' => $course->fresh(['modules.lessons']),
        ]);
    }

    /**
     * Delete course and all curriculum elements.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $course = Course::where('teacher_id', $request->user()->id)->findOrFail($id);
        $course->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Course deleted successfully.',
        ]);
    }

    /**
     * Add a module/chapter to the course curriculum.
     */
    public function storeModule(Request $request, int $courseId): JsonResponse
    {
        $course = Course::where('teacher_id', $request->user()->id)->findOrFail($courseId);

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'order' => 'nullable|integer|min:1',
        ]);

        $order = $validated['order'] ?? ($course->modules()->max('order') + 1);

        $module = $course->modules()->create([
            'title' => $validated['title'],
            'order' => $order,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Module added to course.',
            'data' => $module->load('lessons'),
        ], 201);
    }

    /**
     * Update module details.
     */
    public function updateModule(Request $request, int $moduleId): JsonResponse
    {
        $module = CourseModule::whereHas('course', function ($q) use ($request) {
            $q->where('teacher_id', $request->user()->id);
        })->findOrFail($moduleId);

        $validated = $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'order' => 'nullable|integer|min:1',
        ]);

        $module->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Module updated successfully.',
            'data' => $module,
        ]);
    }

    /**
     * Delete module.
     */
    public function destroyModule(Request $request, int $moduleId): JsonResponse
    {
        $module = CourseModule::whereHas('course', function ($q) use ($request) {
            $q->where('teacher_id', $request->user()->id);
        })->findOrFail($moduleId);

        $module->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Module deleted successfully.',
        ]);
    }

    /**
     * Add a lesson to a module.
     */
    public function storeLesson(Request $request, int $moduleId): JsonResponse
    {
        $module = CourseModule::whereHas('course', function ($q) use ($request) {
            $q->where('teacher_id', $request->user()->id);
        })->findOrFail($moduleId);

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'type' => ['nullable', Rule::in(CourseLesson::ALL_TYPES)],
            'classroom_session_id' => 'nullable|exists:classroom_sessions,id',
            'duration_minutes' => 'nullable|integer|min:1',
            'order' => 'nullable|integer|min:1',
            'content_url' => 'nullable|url',
        ]);

        // If classroom_session_id is provided, ensure it belongs to the teacher
        if (!empty($validated['classroom_session_id'])) {
            $session = ClassroomSession::where('user_id', $request->user()->id)
                ->findOrFail($validated['classroom_session_id']);
        }

        $order = $validated['order'] ?? ($module->lessons()->max('order') + 1);

        $lesson = $module->lessons()->create([
            'title' => $validated['title'],
            'type' => $validated['type'] ?? CourseLesson::TYPE_LIVE_SESSION,
            'classroom_session_id' => $validated['classroom_session_id'] ?? null,
            'duration_minutes' => $validated['duration_minutes'] ?? 45,
            'order' => $order,
            'content_url' => $validated['content_url'] ?? null,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Lesson created successfully.',
            'data' => $lesson->load('classroomSession'),
        ], 201);
    }

    /**
     * Update lesson.
     */
    public function updateLesson(Request $request, int $lessonId): JsonResponse
    {
        $lesson = CourseLesson::whereHas('module.course', function ($q) use ($request) {
            $q->where('teacher_id', $request->user()->id);
        })->findOrFail($lessonId);

        $validated = $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'type' => ['nullable', Rule::in(CourseLesson::ALL_TYPES)],
            'classroom_session_id' => 'nullable|exists:classroom_sessions,id',
            'duration_minutes' => 'nullable|integer|min:1',
            'order' => 'nullable|integer|min:1',
            'content_url' => 'nullable|url',
        ]);

        if (array_key_exists('classroom_session_id', $validated) && !empty($validated['classroom_session_id'])) {
            ClassroomSession::where('user_id', $request->user()->id)
                ->findOrFail($validated['classroom_session_id']);
        }

        $lesson->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Lesson updated successfully.',
            'data' => $lesson->fresh('classroomSession'),
        ]);
    }

    /**
     * Delete lesson.
     */
    public function destroyLesson(Request $request, int $lessonId): JsonResponse
    {
        $lesson = CourseLesson::whereHas('module.course', function ($q) use ($request) {
            $q->where('teacher_id', $request->user()->id);
        })->findOrFail($lessonId);

        $lesson->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Lesson deleted successfully.',
        ]);
    }
}
