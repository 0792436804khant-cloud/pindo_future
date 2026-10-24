<?php

namespace App\Http\Requests\Teacher;

use Illuminate\Foundation\Http\FormRequest;

class CreateSessionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string', 'max:2000'],
            'scheduled_at' => ['nullable', 'date', 'after_or_equal:now'],
            'max_participants' => ['nullable', 'integer', 'min:1', 'max:30000'],
            'settings' => ['nullable', 'array'],
            'settings.allow_chat' => ['nullable', 'boolean'],
            'settings.mute_on_entry' => ['nullable', 'boolean'],
            'settings.recording_enabled' => ['nullable', 'boolean'],
        ];
    }
}
