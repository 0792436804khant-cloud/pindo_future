<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ClassroomAttendance;
use App\Models\ClassroomSession;
use App\Models\Enrollment;
use App\Models\GuardianNote;
use App\Models\ParentStudent;
use App\Models\Role;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ParentOversightController extends Controller
{
    /**
     * Link a student account to the authenticated parent.
     */
    public function linkChild(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'student_email' => 'required_without:linking_code|nullable|email',
            'linking_code' => 'required_without:student_email|nullable|string|max:50',
            'relationship' => 'nullable|string|max:50',
        ]);

        $parent = $request->user();

        // 1. Find target student securely
        $studentQuery = User::where('role', Role::STUDENT);

        if (!empty($validated['student_email'])) {
            $studentQuery->where('email', strtolower(trim($validated['student_email'])));
        } elseif (!empty($validated['linking_code'])) {
            $code = trim($validated['linking_code']);
            $studentQuery->where(function ($q) use ($code) {
                $q->where('student_id', $code)
                  ->orWhere('guardian_link_code', $code)
                  ->orWhereHas('guardians', function ($gq) use ($code) {
                      $gq->where('linking_code', $code);
                  });
            });
        } else {
            return response()->json([
                'status' => 'error',
                'message' => 'Please provide a valid student email address or student linking code.',
            ], 422);
        }

        $student = $studentQuery->first();

        if (!$student) {
            return response()->json([
                'status' => 'error',
                'message' => 'No active student account found matching the provided student email or linking code.',
            ], 404);
        }

        // Prevent self-linking
        if ($student->id === $parent->id) {
            return response()->json([
                'status' => 'error',
                'message' => 'You cannot link your own account as a child.',
            ], 422);
        }

        $relationship = $validated['relationship'] ?? 'Legal Guardian';

        // 2. Check existing link
        $existing = ParentStudent::where('parent_id', $parent->id)
            ->where('student_id', $student->id)
            ->first();

        if ($existing) {
            if ($existing->status === 'active') {
                return response()->json([
                    'status' => 'success',
                    'message' => "Student '{$student->name}' is already linked to your guardian portal.",
                    'child' => [
                        'id' => $student->id,
                        'name' => $student->name,
                        'email' => $student->email,
                        'relationship' => $existing->relationship,
                        'linked_at' => $existing->linked_at?->toIso8601String() ?? $existing->created_at->toIso8601String(),
                    ],
                ], 200);
            }

            $existing->update([
                'status' => 'active',
                'relationship' => $relationship,
                'linked_at' => now(),
            ]);

            return response()->json([
                'status' => 'success',
                'message' => "Successfully re-activated linkage with '{$student->name}'.",
                'child' => [
                    'id' => $student->id,
                    'name' => $student->name,
                    'email' => $student->email,
                    'relationship' => $existing->relationship,
                    'linked_at' => $existing->linked_at->toIso8601String(),
                ],
            ]);
        }

        // 3. Create new linkage
        $link = ParentStudent::create([
            'parent_id' => $parent->id,
            'student_id' => $student->id,
            'relationship' => $relationship,
            'status' => 'active',
            'linking_code' => $validated['linking_code'] ?? null,
            'linked_at' => now(),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => "Successfully linked '{$student->name}' to your guardian oversight portal.",
            'child' => [
                'id' => $student->id,
                'name' => $student->name,
                'email' => $student->email,
                'relationship' => $link->relationship,
                'linked_at' => $link->linked_at->toIso8601String(),
            ],
        ], 201);
    }

    /**
     * Get all active linked children with high-level oversight summaries.
     */
    public function getChildren(Request $request): JsonResponse
    {
        $parent = $request->user();

        $links = ParentStudent::where('parent_id', $parent->id)
            ->where('status', 'active')
            ->with(['student'])
            ->get();

        $children = $links->map(function (ParentStudent $link) {
            $student = $link->student;
            if (!$student) {
                return null;
            }

            // Academic metrics
            $enrollments = Enrollment::where('user_id', $student->id)
                ->whereIn('status', [Enrollment::STATUS_ACTIVE, Enrollment::STATUS_COMPLETED])
                ->get();

            $enrolledCoursesCount = $enrollments->count();
            $completedCoursesCount = $enrollments->where('status', Enrollment::STATUS_COMPLETED)->count();
            $avgProgress = $enrolledCoursesCount > 0
                ? round($enrollments->avg('progress_percentage'), 1)
                : 0.0;

            // Attendance watch-time metrics
            $totalAttendanceSeconds = (int) ClassroomAttendance::where('user_id', $student->id)
                ->sum('duration_seconds');
            $sessionsAttendedCount = ClassroomAttendance::where('user_id', $student->id)->count();

            // Guardian notes
            $unacknowledgedNotes = GuardianNote::where('student_id', $student->id)
                ->where('is_acknowledged', false)
                ->count();

            return [
                'id' => $student->id,
                'name' => $student->name,
                'email' => $student->email,
                'relationship' => $link->relationship,
                'linked_at' => $link->linked_at?->toIso8601String() ?? $link->created_at->toIso8601String(),
                'academics' => [
                    'enrolled_courses_count' => $enrolledCoursesCount,
                    'completed_courses_count' => $completedCoursesCount,
                    'average_progress' => $avgProgress,
                ],
                'attendance' => [
                    'total_watch_seconds' => $totalAttendanceSeconds,
                    'total_watch_minutes' => round($totalAttendanceSeconds / 60, 1),
                    'sessions_attended_count' => $sessionsAttendedCount,
                ],
                'notes_count' => $unacknowledgedNotes,
            ];
        })->filter()->values();

        return response()->json([
            'status' => 'success',
            'data' => $children,
        ]);
    }

    /**
     * Get detailed academic courses and progress for a specific child.
     */
    public function getAcademics(Request $request, int $studentId): JsonResponse
    {
        $parent = $request->user();
        $this->authorizeParentAccess($parent->id, $studentId);

        $student = User::findOrFail($studentId);

        $enrollments = Enrollment::where('user_id', $student->id)
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
                $completedLessonsCount = (int) round(($enrollment->progress_percentage / 100) * max(1, $allLessons->count()));

                return [
                    'enrollment_id' => $enrollment->id,
                    'status' => $enrollment->status,
                    'enrolled_at' => $enrollment->enrolled_at->toIso8601String(),
                    'progress_percentage' => $enrollment->progress_percentage,
                    'course' => [
                        'id' => $course->id,
                        'title' => $course->title,
                        'slug' => $course->slug,
                        'category' => $course->category,
                        'description' => $course->description,
                        'duration_weeks' => $course->duration_weeks,
                        'difficulty_level' => $course->difficulty_level,
                        'total_modules' => $course->modules->count(),
                        'total_lessons' => $allLessons->count(),
                        'completed_lessons' => min($completedLessonsCount, $allLessons->count()),
                        'teacher' => [
                            'name' => $course->teacher->name,
                            'headline' => $course->teacher->teacherPlatform?->headline,
                        ],
                    ],
                ];
            });

        return response()->json([
            'status' => 'success',
            'child' => [
                'id' => $student->id,
                'name' => $student->name,
                'email' => $student->email,
            ],
            'data' => $enrollments,
        ]);
    }

    /**
     * Get live session attendance history and watch duration for a specific child.
     */
    public function getAttendance(Request $request, int $studentId): JsonResponse
    {
        $parent = $request->user();
        $this->authorizeParentAccess($parent->id, $studentId);

        $student = User::findOrFail($studentId);

        $attendances = ClassroomAttendance::where('user_id', $student->id)
            ->with(['session'])
            ->orderBy('joined_at', 'desc')
            ->get()
            ->map(function (ClassroomAttendance $att) {
                return [
                    'id' => $att->id,
                    'session_id' => $att->session_id,
                    'session_title' => $att->session?->title ?? 'Live Classroom Session',
                    'joined_at' => $att->joined_at?->toIso8601String(),
                    'left_at' => $att->left_at?->toIso8601String(),
                    'duration_seconds' => $att->duration_seconds ?? 0,
                    'duration_minutes' => round(($att->duration_seconds ?? 0) / 60, 1),
                    'session_status' => $att->session?->status ?? 'ended',
                ];
            });

        $totalSeconds = (int) $attendances->sum('duration_seconds');

        return response()->json([
            'status' => 'success',
            'child' => [
                'id' => $student->id,
                'name' => $student->name,
            ],
            'summary' => [
                'total_sessions_attended' => $attendances->count(),
                'total_watch_seconds' => $totalSeconds,
                'total_watch_minutes' => round($totalSeconds / 60, 1),
                'total_watch_hours' => round($totalSeconds / 3600, 2),
            ],
            'data' => $attendances,
        ]);
    }

    /**
     * Get upcoming schedule for the child's enrolled courses.
     */
    public function getSchedule(Request $request, int $studentId): JsonResponse
    {
        $parent = $request->user();
        $this->authorizeParentAccess($parent->id, $studentId);

        $student = User::findOrFail($studentId);

        // Retrieve active and scheduled sessions
        $sessions = ClassroomSession::whereIn('status', ['active', 'scheduled'])
            ->with(['teacher', 'lesson.module.course'])
            ->orderBy('scheduled_at', 'asc')
            ->limit(15)
            ->get()
            ->map(function (ClassroomSession $s) {
                return [
                    'session_id' => $s->session_id,
                    'title' => $s->title,
                    'status' => $s->status,
                    'is_live' => $s->status === 'active',
                    'scheduled_at' => $s->scheduled_at?->toIso8601String(),
                    'course_title' => $s->lesson?->module?->course?->title ?? 'Live Masterclass',
                    'teacher_name' => $s->teacher?->name ?? 'Instructor',
                ];
            });

        return response()->json([
            'status' => 'success',
            'child' => [
                'id' => $student->id,
                'name' => $student->name,
            ],
            'data' => $sessions,
        ]);
    }

    /**
     * Get guardian notes and communication history for a specific child.
     */
    public function getNotes(Request $request, int $studentId): JsonResponse
    {
        $parent = $request->user();
        $this->authorizeParentAccess($parent->id, $studentId);

        $notes = GuardianNote::where('student_id', $studentId)
            ->with(['author'])
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function (GuardianNote $n) {
                return [
                    'id' => $n->id,
                    'title' => $n->title,
                    'content' => $n->content,
                    'type' => $n->type,
                    'is_acknowledged' => $n->is_acknowledged,
                    'created_at' => $n->created_at->toIso8601String(),
                    'author' => [
                        'id' => $n->author?->id,
                        'name' => $n->author?->name ?? 'System',
                        'role' => $n->author?->role ?? 'teacher',
                    ],
                ];
            });

        return response()->json([
            'status' => 'success',
            'data' => $notes,
        ]);
    }

    /**
     * Create a guardian note or inquiry for a child.
     */
    public function storeNote(Request $request, int $studentId): JsonResponse
    {
        $parent = $request->user();
        $this->authorizeParentAccess($parent->id, $studentId);

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'type' => 'nullable|string|in:progress_report,attendance_alert,general',
        ]);

        $note = GuardianNote::create([
            'student_id' => $studentId,
            'parent_id' => $parent->id,
            'author_id' => $parent->id,
            'title' => $validated['title'],
            'content' => $validated['content'],
            'type' => $validated['type'] ?? 'general',
            'is_acknowledged' => true,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Guardian note submitted successfully.',
            'data' => [
                'id' => $note->id,
                'title' => $note->title,
                'content' => $note->content,
                'type' => $note->type,
                'is_acknowledged' => $note->is_acknowledged,
                'created_at' => $note->created_at->toIso8601String(),
                'author' => [
                    'name' => $parent->name,
                    'role' => 'parent',
                ],
            ],
        ], 201);
    }

    /**
     * Acknowledge a guardian alert or instructor note.
     */
    public function acknowledgeNote(Request $request, int $noteId): JsonResponse
    {
        $parent = $request->user();

        $note = GuardianNote::where('id', $noteId)
            ->whereHas('student.guardians', function ($q) use ($parent) {
                $q->where('users.id', $parent->id);
            })
            ->firstOrFail();

        $note->update(['is_acknowledged' => true]);

        return response()->json([
            'status' => 'success',
            'message' => 'Guardian note acknowledged.',
            'note_id' => $note->id,
        ]);
    }

    /**
     * Verify the student is actively linked to the parent.
     */
    private function authorizeParentAccess(int $parentId, int $studentId): void
    {
        $isLinked = ParentStudent::where('parent_id', $parentId)
            ->where('student_id', $studentId)
            ->where('status', 'active')
            ->exists();

        if (!$isLinked) {
            abort(403, 'You do not have active guardian oversight authorization for this student.');
        }
    }
}
