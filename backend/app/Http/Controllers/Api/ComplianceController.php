<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ContentReport;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ComplianceController extends Controller
{
    /**
     * Submit a Content / User Report (Apple App Store Guideline 1.2 Compliance)
     */
    public function report(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'reported_user_id' => 'nullable|integer|exists:users,id',
            'classroom_session_id' => 'nullable|integer|exists:classroom_sessions,id',
            'classroom_message_id' => 'nullable|integer|exists:classroom_messages,id',
            'reason' => 'required|string|in:harassment,inappropriate_content,hate_speech,spam,other',
            'details' => 'nullable|string|max:2000',
        ]);

        $report = ContentReport::create([
            'reporter_id' => $request->user()->id,
            'reported_user_id' => $validated['reported_user_id'] ?? null,
            'classroom_session_id' => $validated['classroom_session_id'] ?? null,
            'classroom_message_id' => $validated['classroom_message_id'] ?? null,
            'reason' => $validated['reason'],
            'details' => $validated['details'] ?? null,
            'status' => 'pending',
        ]);

        return response()->json([
            'message' => 'Thank you for your report. Our safety & moderation team will review it within 24 hours in accordance with Pindo Future safety policies.',
            'report_id' => $report->id,
            'status' => $report->status,
        ], 201);
    }
}
