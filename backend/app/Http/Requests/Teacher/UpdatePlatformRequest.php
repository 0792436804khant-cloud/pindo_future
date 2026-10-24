<?php

namespace App\Http\Requests\Teacher;

use Illuminate\Foundation\Http\FormRequest;

class UpdatePlatformRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'headline' => ['nullable', 'string', 'max:255'],
            'bio' => ['nullable', 'string', 'max:2000'],
            'website_url' => ['nullable', 'url', 'max:255'],
            'settings' => ['nullable', 'array'],
            'avatar_url' => ['nullable', 'string', 'max:1000'],
            'years_of_experience' => ['nullable', 'numeric', 'min:0', 'max:60'],
            'student_achievements' => ['nullable', 'array'],
            'student_achievements.*.title' => ['required_with:student_achievements', 'string', 'max:255'],
            'student_achievements.*.student_name' => ['nullable', 'string', 'max:255'],
            'student_achievements.*.grade_or_score' => ['nullable', 'string', 'max:100'],
            'student_achievements.*.year' => ['nullable', 'string', 'max:50'],
            'student_achievements.*.photo_url' => ['nullable', 'string', 'max:1000'],
            'student_achievements.*.description' => ['nullable', 'string', 'max:1000'],
            'teaching_levels' => ['nullable', 'array'],
            'teaching_years' => ['nullable', 'array'],
            'teaching_subjects' => ['nullable', 'array'],
        ];
    }
}
