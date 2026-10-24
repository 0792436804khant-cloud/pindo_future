<?php

namespace App\Http\Controllers\Api\Teacher;

use App\Http\Controllers\Controller;
use App\Http\Requests\Teacher\UpdatePlatformRequest;
use App\Http\Resources\TeacherPlatformResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PlatformController extends Controller
{
    /**
     * Get platform details, deep link URL, and live room summary.
     */
    public function show(Request $request): JsonResponse
    {
        $teacher = $request->user()->load(['teacherPlatform', 'classroomSessions']);

        return response()->json([
            'status' => 'success',
            'platform' => new TeacherPlatformResource($teacher),
        ]);
    }

    /**
     * Update teacher platform profile, branding settings, and credentials.
     */
    public function update(UpdatePlatformRequest $request): JsonResponse
    {
        $teacher = $request->user();
        $validated = $request->validated();

        // 1. Update teacher academic classifications if provided
        $userUpdates = [];
        if (array_key_exists('teaching_levels', $validated)) {
            $userUpdates['teaching_levels'] = $validated['teaching_levels'];
        }
        if (array_key_exists('teaching_years', $validated)) {
            $userUpdates['teaching_years'] = $validated['teaching_years'];
        }
        if (array_key_exists('teaching_subjects', $validated)) {
            $userUpdates['teaching_subjects'] = $validated['teaching_subjects'];
        }
        if (!empty($userUpdates)) {
            $teacher->update($userUpdates);
        }

        // 2. Fetch existing platform settings and merge new credentials
        $existingPlatform = $teacher->teacherPlatform;
        $currentSettings = $existingPlatform?->settings ?? [];
        if (isset($validated['settings']) && is_array($validated['settings'])) {
            $currentSettings = array_merge($currentSettings, $validated['settings']);
        }
        if (array_key_exists('avatar_url', $validated)) {
            $currentSettings['avatar_url'] = $validated['avatar_url'];
        }
        if (array_key_exists('years_of_experience', $validated)) {
            $currentSettings['years_of_experience'] = $validated['years_of_experience'];
        }
        if (array_key_exists('student_achievements', $validated)) {
            $currentSettings['student_achievements'] = $validated['student_achievements'];
        }

        $platform = $teacher->teacherPlatform()->updateOrCreate(
            ['user_id' => $teacher->id],
            [
                'headline' => $validated['headline'] ?? $existingPlatform?->headline,
                'bio' => $validated['bio'] ?? $existingPlatform?->bio,
                'website_url' => $validated['website_url'] ?? $existingPlatform?->website_url,
                'settings' => $currentSettings,
            ]
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Teacher profile & credentials updated successfully.',
            'platform' => new TeacherPlatformResource($teacher->fresh(['teacherPlatform', 'classroomSessions'])),
        ]);
    }
}
