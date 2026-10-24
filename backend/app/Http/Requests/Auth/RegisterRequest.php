<?php

namespace App\Http\Requests\Auth;

use App\Models\Role;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class RegisterRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'role' => ['required', 'string', Rule::in(Role::PUBLIC_REGISTRATION_ROLES)],
            'teacher_id' => [
                'nullable',
                'string',
                'max:50',
                'unique:users,teacher_id',
                Rule::requiredIf(fn () => $this->input('role') === Role::TEACHER && $this->filled('teacher_id')),
            ],
            'teaching_levels' => [
                'nullable',
                Rule::requiredIf(fn () => $this->input('role') === Role::TEACHER),
            ],
            'teaching_years' => [
                'nullable',
                Rule::requiredIf(fn () => $this->input('role') === Role::TEACHER),
            ],
            'teaching_subjects' => [
                'nullable',
                Rule::requiredIf(fn () => $this->input('role') === Role::TEACHER),
            ],
            'student_id' => [
                'nullable',
                'string',
                'max:100',
                Rule::requiredIf(fn () => $this->input('role') === Role::PARENT),
            ],
            'relationship' => [
                'nullable',
                'string',
                'max:50',
            ],
            'wilaya' => ['nullable', 'integer', 'min:1', 'max:58'],
            'academic_level' => ['nullable', 'string', 'max:50'],
            'stream' => ['nullable', 'string', 'max:100'],
            'device_name' => ['nullable', 'string', 'max:100'],
        ];
    }

    /**
     * Custom messages for validation errors.
     */
    public function messages(): array
    {
        return [
            'role.in' => 'The selected role must be one of: teacher, student, or parent.',
            'password.min' => 'Password must contain at least 8 characters.',
            'student_id.required' => 'Student ID is strictly required to create a parent account.',
        ];
    }
}
