<?php

namespace App\Http\Resources;

use App\Models\ClassroomSession;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TeacherPlatformResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $teacher = $this->resource;
        $platform = $teacher->teacherPlatform;
        $settings = $platform?->settings ?? [];
        $activeSession = $teacher->classroomSessions()->active()->first();

        return [
            'teacher' => [
                'id' => $teacher->id,
                'name' => $teacher->name,
                'email' => $teacher->email,
                'teacher_id' => $teacher->teacher_id,
                'deep_link_url' => $teacher->deep_link_url,
                'teaching_levels' => $teacher->teaching_levels ?? [],
                'teaching_years' => $teacher->teaching_years ?? [],
                'teaching_subjects' => $teacher->teaching_subjects ?? [],
                'avatar_url' => $settings['avatar_url'] ?? null,
                'years_of_experience' => $settings['years_of_experience'] ?? null,
                'student_achievements' => $settings['student_achievements'] ?? [],
            ],
            'platform' => [
                'headline' => $platform?->headline ?? 'Verified Instructor at Pindo Future',
                'bio' => $platform?->bio,
                'website_url' => $platform?->website_url,
                'settings' => $settings,
                'avatar_url' => $settings['avatar_url'] ?? null,
                'years_of_experience' => $settings['years_of_experience'] ?? null,
                'student_achievements' => $settings['student_achievements'] ?? [],
            ],
            'metrics' => [
                'total_sessions' => $teacher->classroomSessions()->count(),
                'active_sessions_count' => $teacher->classroomSessions()->active()->count(),
            ],
            'current_active_session' => $activeSession ? new ClassroomSessionResource($activeSession) : null,
        ];
    }
}
