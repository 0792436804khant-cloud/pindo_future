<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $platform = $this->teacherPlatform;
        $settings = $platform?->settings ?? [];

        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'role' => $this->role,
            'teacher_id' => $this->teacher_id,
            'student_id' => $this->student_id,
            'teaching_levels' => $this->teaching_levels ?? [],
            'teaching_years' => $this->teaching_years ?? [],
            'teaching_subjects' => $this->teaching_subjects ?? [],
            'wilaya' => $this->wilaya,
            'academic_level' => $this->academic_level,
            'stream' => $this->stream,
            'guardian_link_code' => $this->guardian_link_code,
            'is_verified' => (bool) $this->is_verified,
            'verification_status' => $this->verification_status ?? 'unverified',
            'verified_at' => $this->verified_at?->toIso8601String(),
            'avatar_url' => $settings['avatar_url'] ?? null,
            'years_of_experience' => $settings['years_of_experience'] ?? null,
            'headline' => $platform?->headline,
            'bio' => $platform?->bio,
            'student_achievements' => $settings['student_achievements'] ?? [],
            'roles' => $this->roles->pluck('name'),
            'permissions' => $this->allPermissions()->pluck('name'),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
