<?php

namespace App\Http\Requests\Session;

use Illuminate\Foundation\Http\FormRequest;

class GenerateTokenRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'participant_name' => ['nullable', 'string', 'max:100'],
        ];
    }
}
