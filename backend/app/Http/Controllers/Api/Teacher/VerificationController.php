<?php

namespace App\Http\Controllers\Api\Teacher;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VerificationController extends Controller
{
    /**
     * Get verification badge status for the authenticated teacher.
     */
    public function status(Request $request): JsonResponse
    {
        $teacher = $request->user();

        return response()->json([
            'status' => 'success',
            'data' => [
                'is_verified' => (bool) $teacher->is_verified,
                'verification_status' => $teacher->verification_status ?? 'unverified',
                'verified_at' => $teacher->verified_at?->toIso8601String(),
                'national_id_or_diploma' => $teacher->national_id_or_diploma,
            ],
        ]);
    }

    /**
     * Submit request for verification badge.
     */
    public function requestVerification(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'national_id_or_diploma' => ['required', 'string', 'max:255'],
        ]);

        $teacher = $request->user();

        if ($teacher->is_verified) {
            return response()->json([
                'status' => 'error',
                'message' => 'أنت بالفعل أستاذ معتمد وموثق في المنصة',
            ], 422);
        }

        $teacher->update([
            'national_id_or_diploma' => $validated['national_id_or_diploma'],
            'verification_status' => 'pending',
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم استلام طلب التوثيق بنجاح، جاري مراجعة الوثائق من قِبل إدارة منصة بيندو فيوتشر',
            'data' => [
                'is_verified' => false,
                'verification_status' => 'pending',
            ],
        ]);
    }
}
