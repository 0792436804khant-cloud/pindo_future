<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Course;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PublicCourseController extends Controller
{
    /**
     * List published courses with category and search filters.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Course::published()
            ->with(['teacher.teacherPlatform'])
            ->withCount(['modules', 'lessons', 'students']);

        if ($request->filled('category')) {
            $query->category($request->category);
        }

        if ($request->filled('teacher_id')) {
            $query->byTeacher((int) $request->teacher_id);
        }

        if ($request->filled('search')) {
            $search = '%' . $request->search . '%';
            $query->where(function ($q) use ($search) {
                $q->where('title', 'ilike', $search)
                    ->orWhere('description', 'ilike', $search);
            });
        }

        $courses = $query->orderBy('created_at', 'desc')->paginate(20);

        return response()->json([
            'status' => 'success',
            'data' => $courses,
        ]);
    }

    /**
     * Show detailed course view with full syllabus and modules.
     */
    public function show(string $identifier): JsonResponse
    {
        $course = Course::where(function ($q) use ($identifier) {
            $q->where('slug', $identifier);
            if (is_numeric($identifier)) {
                $q->orWhere('id', (int) $identifier);
            }
        })
        ->published()
        ->with([
            'teacher.teacherPlatform',
            'modules.lessons.classroomSession',
        ])
        ->withCount(['students', 'modules', 'lessons'])
        ->first();

        if (!$course) {
            return response()->json([
                'status' => 'error',
                'message' => 'Course not found or is not currently published.',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => $course,
        ]);
    }
}
