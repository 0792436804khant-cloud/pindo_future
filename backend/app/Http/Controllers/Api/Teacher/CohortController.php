<?php

namespace App\Http\Controllers\Api\Teacher;

use App\Http\Controllers\Controller;
use App\Models\ClassroomSession;
use App\Models\CohortMember;
use App\Models\StudyCohort;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class CohortController extends Controller
{
    /**
     * List all study cohorts for the authenticated teacher.
     */
    public function index(Request $request): JsonResponse
    {
        $teacher = $request->user();

        $cohorts = $teacher->cohorts()
            ->withCount(['members as active_students_count' => fn ($q) => $q->where('status', 'active')])
            ->withCount('sessions')
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $cohorts,
        ]);
    }

    /**
     * Create a new study cohort (فوج تعليمي).
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'subject' => ['required', 'string', 'max:100'],
            'academic_level' => ['required', 'string', 'max:50'],
            'stream' => ['nullable', 'string', 'max:100'],
            'max_students' => ['nullable', 'integer', 'min:1', 'max:5000'],
            'monthly_price' => ['nullable', 'numeric', 'min:0'],
            'schedule' => ['nullable', 'array'],
            'description' => ['nullable', 'string'],
        ]);

        $teacher = $request->user();

        $cohort = $teacher->cohorts()->create([
            'name' => $validated['name'],
            'subject' => $validated['subject'],
            'academic_level' => $validated['academic_level'],
            'stream' => $validated['stream'] ?? null,
            'max_students' => $validated['max_students'] ?? 100,
            'enrolled_count' => 0,
            'monthly_price' => $validated['monthly_price'] ?? 0.00,
            'schedule' => $validated['schedule'] ?? [],
            'description' => $validated['description'] ?? null,
            'is_active' => true,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم إنشاء الفوج التعليمي بنجاح',
            'data' => $cohort,
        ], 201);
    }

    /**
     * Display the specified cohort.
     */
    public function show(int $id, Request $request): JsonResponse
    {
        $teacher = $request->user();

        $cohort = $teacher->cohorts()
            ->with(['members.student', 'sessions' => fn ($q) => $q->orderByDesc('scheduled_at')])
            ->findOrFail($id);

        return response()->json([
            'status' => 'success',
            'data' => $cohort,
        ]);
    }

    /**
     * Update cohort information.
     */
    public function update(int $id, Request $request): JsonResponse
    {
        $teacher = $request->user();
        $cohort = $teacher->cohorts()->findOrFail($id);

        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'subject' => ['sometimes', 'string', 'max:100'],
            'academic_level' => ['sometimes', 'string', 'max:50'],
            'stream' => ['nullable', 'string', 'max:100'],
            'max_students' => ['sometimes', 'integer', 'min:1', 'max:5000'],
            'monthly_price' => ['sometimes', 'numeric', 'min:0'],
            'schedule' => ['nullable', 'array'],
            'is_active' => ['sometimes', 'boolean'],
            'description' => ['nullable', 'string'],
        ]);

        $cohort->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'تم تحديث بيانات الفوج بنجاح',
            'data' => $cohort,
        ]);
    }

    /**
     * Delete cohort.
     */
    public function destroy(int $id, Request $request): JsonResponse
    {
        $teacher = $request->user();
        $cohort = $teacher->cohorts()->findOrFail($id);

        $cohort->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'تم حذف الفوج التعليمي بنجاح',
        ]);
    }

    /**
     * List students in a cohort.
     */
    public function members(int $id, Request $request): JsonResponse
    {
        $teacher = $request->user();
        $cohort = $teacher->cohorts()->findOrFail($id);

        $members = $cohort->members()
            ->with('student:id,name,email,student_id,wilaya,stream')
            ->orderByDesc('joined_at')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $members,
        ]);
    }

    /**
     * Teacher manually adds a student to cohort.
     */
    public function addMember(int $id, Request $request): JsonResponse
    {
        $teacher = $request->user();
        $cohort = $teacher->cohorts()->findOrFail($id);

        if ($cohort->isFull()) {
            return response()->json([
                'status' => 'error',
                'message' => 'الفوج ممتلئ، لقد تم الوصول إلى الحد الأقصى لعدد التلاميذ',
            ], 422);
        }

        $validated = $request->validate([
            'student_identifier' => ['required', 'string'], // can be email or student_id
        ]);

        $identifier = trim($validated['student_identifier']);
        $student = User::where('role', 'student')
            ->where(function ($q) use ($identifier) {
                $q->where('email', $identifier)
                  ->orWhere('student_id', $identifier)
                  ->orWhere('guardian_link_code', $identifier);
            })
            ->first();

        if (! $student) {
            return response()->json([
                'status' => 'error',
                'message' => 'لم يتم العثور على التلميذ بالمحدد المدخل',
            ], 404);
        }

        if ($cohort->hasStudent($student->id)) {
            return response()->json([
                'status' => 'error',
                'message' => 'التلميذ مسجل بالفعل في هذا الفوج',
            ], 422);
        }

        $membership = CohortMember::create([
            'cohort_id' => $cohort->id,
            'student_id' => $student->id,
            'status' => 'active',
            'joined_at' => now(),
        ]);

        $cohort->recalculateEnrolledCount();

        return response()->json([
            'status' => 'success',
            'message' => 'تمت إضافة التلميذ إلى الفوج بنجاح',
            'data' => $membership->load('student'),
        ], 201);
    }

    /**
     * Teacher removes student from cohort.
     */
    public function removeMember(int $id, int $studentId, Request $request): JsonResponse
    {
        $teacher = $request->user();
        $cohort = $teacher->cohorts()->findOrFail($id);

        $deleted = $cohort->members()->where('student_id', $studentId)->delete();

        if (! $deleted) {
            return response()->json([
                'status' => 'error',
                'message' => 'التلميذ غير موجود في هذا الفوج',
            ], 404);
        }

        $cohort->recalculateEnrolledCount();

        return response()->json([
            'status' => 'success',
            'message' => 'تم حذف التلميذ من الفوج',
        ]);
    }

    /**
     * Schedule a live classroom session bound to this specific cohort.
     */
    public function createSession(int $id, Request $request): JsonResponse
    {
        $teacher = $request->user();
        $cohort = $teacher->cohorts()->findOrFail($id);

        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'scheduled_at' => ['nullable', 'date'],
            'settings' => ['nullable', 'array'],
        ]);

        $session = ClassroomSession::create([
            'user_id' => $teacher->id,
            'cohort_id' => $cohort->id,
            'title' => $validated['title'],
            'description' => $validated['description'] ?? null,
            'status' => ClassroomSession::STATUS_SCHEDULED,
            'max_participants' => $cohort->max_students,
            'settings' => $validated['settings'] ?? [
                'allow_chat' => true,
                'mute_on_entry' => true,
                'recording_enabled' => false,
            ],
            'scheduled_at' => $validated['scheduled_at'] ?? now(),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تمت جدولة الحصة المباشرة للفوج بنجاح',
            'data' => $session,
        ], 201);
    }
}
