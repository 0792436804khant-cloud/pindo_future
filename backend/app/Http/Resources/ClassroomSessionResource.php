<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ClassroomSessionResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'session_id' => $this->session_id,
            'title' => $this->title,
            'description' => $this->description,
            'status' => $this->status,
            'is_live' => $this->isActive(),
            'max_participants' => $this->max_participants,
            'settings' => $this->settings ?? [
                'allow_chat' => true,
                'mute_on_entry' => true,
                'recording_enabled' => false,
            ],
            'scheduled_at' => $this->scheduled_at?->toIso8601String(),
            'started_at' => $this->started_at?->toIso8601String(),
            'ended_at' => $this->ended_at?->toIso8601String(),
            'teacher' => [
                'id' => $this->teacher?->id,
                'name' => $this->teacher?->name,
                'teacher_id' => $this->teacher?->teacher_id,
                'deep_link_url' => $this->teacher?->deep_link_url,
            ],
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
