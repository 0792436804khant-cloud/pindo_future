<?php

namespace App\Http\Controllers\Api\Teacher;

use App\Http\Controllers\Controller;
use App\Models\CohortAttendanceRecord;
use App\Models\CohortAttendanceSession;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CohortAttendanceController extends Controller
{
    /**
     * Get real enrolled students, monthly attendance sessions, and saved records.
     */
    public function index(int $id, Request $request): JsonResponse
    {
        $teacher = $request->user();
        $cohort = $teacher->cohorts()->findOrFail($id);

        $monthKey = $request->query('month', now()->format('Y-m'));
        if (! preg_match('/^\d{4}-\d{2}$/', $monthKey)) {
            $monthKey = now()->format('Y-m');
        }

        $members = $cohort->members()
            ->where('status', 'active')
            ->with('student:id,name,email,student_id')
            ->orderBy('joined_at', 'asc')
            ->get()
            ->values()
            ->map(function ($m, int $index): array {
                return [
                    'number' => $index + 1,
                    'student_id' => $m->student_id,
                    'student_code' => $m->student?->student_id,
                    'name' => $m->student?->name ?? ('طالب #' . $m->student_id),
                    'email' => $m->student?->email ?? '',
                    'package_type' => $m->package_type ?? 'full_bundle',
                    'joined_at' => $m->joined_at?->toIso8601String(),
                ];
            });

        $sessions = CohortAttendanceSession::where('cohort_id', $cohort->id)
            ->where('month_key', $monthKey)
            ->orderBy('session_date', 'asc')
            ->orderBy('id', 'asc')
            ->get(['id', 'label', 'session_date', 'month_key'])
            ->map(fn ($s) => [
                'id' => $s->id,
                'label' => $s->label,
                'session_date' => $s->session_date?->format('Y-m-d'),
                'month_key' => $s->month_key,
            ]);

        $sessionIds = $sessions->pluck('id')->all();
        $recordsMap = [];

        if (! empty($sessionIds)) {
            $records = CohortAttendanceRecord::whereIn('attendance_session_id', $sessionIds)->get();
            foreach ($records as $rec) {
                $recordsMap["{$rec->student_id}_{$rec->attendance_session_id}"] = $rec->status;
            }
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'cohort_id' => $cohort->id,
                'cohort_name' => $cohort->name,
                'month_key' => $monthKey,
                'students' => $members,
                'sessions' => $sessions,
                'records' => (object) $recordsMap,
            ],
        ]);
    }

    /**
     * Create a new attendance session column for this cohort & month.
     */
    public function storeSession(int $id, Request $request): JsonResponse
    {
        $teacher = $request->user();
        $cohort = $teacher->cohorts()->findOrFail($id);

        $validated = $request->validate([
            'label' => ['required', 'string', 'max:120'],
            'session_date' => ['required', 'date'],
            'month_key' => ['nullable', 'regex:/^\d{4}-\d{2}$/'],
        ]);

        $monthKey = $validated['month_key'] ?? substr($validated['session_date'], 0, 7);

        $session = CohortAttendanceSession::create([
            'cohort_id' => $cohort->id,
            'month_key' => $monthKey,
            'label' => trim($validated['label']),
            'session_date' => $validated['session_date'],
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تمت إضافة الحصة إلى جدول الحضور بنجاح',
            'data' => [
                'id' => $session->id,
                'label' => $session->label,
                'session_date' => $session->session_date?->format('Y-m-d'),
                'month_key' => $session->month_key,
            ],
        ], 201);
    }

    /**
     * Delete an attendance session column.
     */
    public function destroySession(int $id, int $sessionId, Request $request): JsonResponse
    {
        $teacher = $request->user();
        $cohort = $teacher->cohorts()->findOrFail($id);

        $session = CohortAttendanceSession::where('cohort_id', $cohort->id)
            ->findOrFail($sessionId);

        $session->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'تم حذف الحصة بنجاح',
        ]);
    }

    /**
     * Save batch attendance status updates ('P', 'L', 'A', 'E').
     */
    public function saveRecords(int $id, Request $request): JsonResponse
    {
        $teacher = $request->user();
        $cohort = $teacher->cohorts()->findOrFail($id);

        $validated = $request->validate([
            'records' => ['required', 'array', 'min:1'],
            'records.*.session_id' => ['required', 'integer'],
            'records.*.student_id' => ['required', 'integer'],
            'records.*.status' => ['required', 'in:P,L,A,E'],
        ]);

        $validSessionIds = CohortAttendanceSession::where('cohort_id', $cohort->id)
            ->pluck('id')
            ->all();

        $validStudentIds = $cohort->members()
            ->where('status', 'active')
            ->pluck('student_id')
            ->all();

        foreach ($validated['records'] as $item) {
            if (
                ! in_array((int) $item['session_id'], $validSessionIds, true) ||
                ! in_array((int) $item['student_id'], $validStudentIds, true)
            ) {
                continue;
            }

            CohortAttendanceRecord::updateOrCreate(
                [
                    'attendance_session_id' => (int) $item['session_id'],
                    'student_id' => (int) $item['student_id'],
                ],
                [
                    'status' => $item['status'],
                ]
            );
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم حفظ سجل الحضور بنجاح',
        ]);
    }
}
