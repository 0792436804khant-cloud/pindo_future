<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TeacherVerificationAdminController extends Controller
{
    /**
     * List all pending teacher verification applications.
     */
    public function index(Request $request): JsonResponse
    {
        $status = $request->query('status', 'pending');

        $teachers = User::where('role', 'teacher')
            ->when($status, fn ($q) => $q->where('verification_status', $status))
            ->orderByDesc('updated_at')
            ->get(['id', 'name', 'email', 'teacher_id', 'wilaya', 'is_verified', 'verification_status', 'national_id_or_diploma', 'verified_at', 'created_at']);

        return response()->json([
            'status' => 'success',
            'data' => $teachers,
        ]);
    }

    /**
     * Approve teacher accreditation and issue blue verification badge.
     */
    public function approve(int $id, Request $request): JsonResponse
    {
        $teacher = User::where('role', 'teacher')->findOrFail($id);

        $teacher->update([
            'is_verified' => true,
            'verification_status' => 'verified',
            'verified_at' => now(),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم توثيق الأستاذ بنجاح ومنحه شارة الاعتماد الرسمية',
            'data' => [
                'teacher_id' => $teacher->id,
                'name' => $teacher->name,
                'is_verified' => true,
                'verification_status' => 'verified',
                'verified_at' => $teacher->verified_at->toIso8601String(),
            ],
        ]);
    }

    /**
     * Reject teacher accreditation.
     */
    public function reject(int $id, Request $request): JsonResponse
    {
        $teacher = User::where('role', 'teacher')->findOrFail($id);

        $teacher->update([
            'is_verified' => false,
            'verification_status' => 'rejected',
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم رفض طلب توثيق الأستاذ',
            'data' => [
                'teacher_id' => $teacher->id,
                'name' => $teacher->name,
                'is_verified' => false,
                'verification_status' => 'rejected',
            ],
        ]);
    }
}
