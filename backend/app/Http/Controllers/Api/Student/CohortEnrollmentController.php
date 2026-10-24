<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Models\CohortMember;
use App\Models\StudyCohort;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CohortEnrollmentController extends Controller
{
    /**
     * Search and discover study cohorts.
     */
    public function index(Request $request): JsonResponse
    {
        $query = StudyCohort::where('is_active', true)
            ->with(['teacher:id,name,teacher_id,is_verified,verification_status,wilaya']);

        if ($request->filled('academic_level')) {
            $query->where('academic_level', $request->query('academic_level'));
        }

        if ($request->filled('stream')) {
            $query->where('stream', $request->query('stream'));
        }

        if ($request->filled('subject')) {
            $query->where('subject', 'like', '%' . $request->query('subject') . '%');
        }

        if ($request->filled('teacher_id')) {
            $query->where('teacher_id', $request->query('teacher_id'));
        }

        if ($request->filled('wilaya')) {
            $wilaya = (int) $request->query('wilaya');
            $query->whereHas('teacher', fn ($q) => $q->where('wilaya', $wilaya));
        }

        if ($request->filled('search')) {
            $searchTerm = '%' . $request->query('search') . '%';
            $query->where(function ($q) use ($searchTerm) {
                $q->where('name', 'like', $searchTerm)
                  ->orWhere('subject', 'like', $searchTerm)
                  ->orWhere('description', 'like', $searchTerm)
                  ->orWhereHas('teacher', fn ($t) => $t->where('name', 'like', $searchTerm));
            });
        }

        $cohorts = $query->orderByDesc('created_at')->paginate($request->query('per_page', 20));

        return response()->json([
            'status' => 'success',
            'data' => $cohorts->items(),
            'meta' => [
                'current_page' => $cohorts->currentPage(),
                'last_page' => $cohorts->lastPage(),
                'total' => $cohorts->total(),
            ],
        ]);
    }

    /**
     * List all cohorts the student is currently enrolled in.
     */
    public function myCohorts(Request $request): JsonResponse
    {
        $student = $request->user();

        $cohorts = $student->enrolledCohorts()
            ->with(['teacher:id,name,teacher_id,is_verified,verification_status,wilaya', 'sessions' => fn ($q) => $q->where('status', 'scheduled')->orderBy('scheduled_at')])
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $cohorts,
        ]);
    }

    /**
     * Student joins a study cohort.
     */
    public function join(int $id, Request $request): JsonResponse
    {
        $student = $request->user();

        if ($student->role !== 'student') {
            return response()->json([
                'status' => 'error',
                'message' => 'فقط حسابات التلاميذ يمكنها الانضمام إلى الأفواج التعليمية',
            ], 403);
        }

        $cohort = StudyCohort::where('is_active', true)->findOrFail($id);

        if ($cohort->isFull()) {
            return response()->json([
                'status' => 'error',
                'message' => 'عذراً، هذا الفوج ممتلئ حالياً',
            ], 422);
        }

        if ($cohort->hasStudent($student->id)) {
            return response()->json([
                'status' => 'error',
                'message' => 'أنت مسجل بالفعل في هذا الفوج التعليمي',
            ], 422);
        }

        $member = CohortMember::create([
            'cohort_id' => $cohort->id,
            'student_id' => $student->id,
            'status' => 'active',
            'joined_at' => now(),
        ]);

        $cohort->recalculateEnrolledCount();

        return response()->json([
            'status' => 'success',
            'message' => 'تم الانضمام إلى الفوج بنجاح! مرحباً بك',
            'data' => $cohort->fresh(['teacher:id,name,teacher_id,is_verified', 'sessions']),
        ], 201);
    }

    /**
     * Student leaves a cohort.
     */
    public function leave(int $id, Request $request): JsonResponse
    {
        $student = $request->user();
        $cohort = StudyCohort::findOrFail($id);

        $deleted = CohortMember::where('cohort_id', $cohort->id)
            ->where('student_id', $student->id)
            ->delete();

        if (! $deleted) {
            return response()->json([
                'status' => 'error',
                'message' => 'أنت لست مسجلاً في هذا الفوج',
            ], 404);
        }

        $cohort->recalculateEnrolledCount();

        return response()->json([
            'status' => 'success',
            'message' => 'تمت مغادرة الفوج بنجاح',
        ]);
    }
}
