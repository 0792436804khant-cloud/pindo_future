<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Session\GenerateTokenRequest;
use App\Models\ClassroomSession;
use App\Models\Role;
use App\Services\Streaming\LiveKitTokenService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use InvalidArgumentException;

class SessionTokenController extends Controller
{
    public function __construct(
        protected LiveKitTokenService $tokenService
    ) {}

    /**
     * Generate secure LiveKit SFU access token for a classroom session.
     */
    public function generate(GenerateTokenRequest $request, string $sessionId): JsonResponse
    {
        $session = ClassroomSession::with('teacher')
            ->bySessionId($sessionId)
            ->first();

        if (! $session) {
            return response()->json([
                'status' => 'error',
                'message' => "Classroom session '{$sessionId}' was not found.",
            ], 404);
        }

        if ($session->isEnded()) {
            return response()->json([
                'status' => 'error',
                'message' => "Classroom session '{$sessionId}' has already ended.",
            ], 422);
        }

        // Authenticated user via Sanctum (or active auth guard)
        $user = $request->user('sanctum') ?? $request->user();

        $isHost = $user && ($user->id === $session->user_id || $user->hasRole(Role::ADMIN));

        // Phase 5 Access Gate: Check if session is tied to a Course Curriculum Lesson
        $session->loadMissing('lesson.module.course');
        $course = $session->lesson?->module?->course;

        if ($course && ! $isHost) {
            if (! $user) {
                return response()->json([
                    'status' => 'error',
                    'message' => "Enrollment required. You must sign in and enroll in '{$course->title}' to join this live classroom session.",
                    'requires_enrollment' => true,
                    'course_id' => $course->id,
                    'course_slug' => $course->slug,
                    'course_title' => $course->title,
                ], 403);
            }

            $isEnrolled = \App\Models\Enrollment::where('user_id', $user->id)
                ->where('course_id', $course->id)
                ->where('status', \App\Models\Enrollment::STATUS_ACTIVE)
                ->exists();

            if (! $isEnrolled) {
                return response()->json([
                    'status' => 'error',
                    'message' => "Enrollment required. You are not enrolled in '{$course->title}'. Please enroll in the course to join this live session.",
                    'requires_enrollment' => true,
                    'course_id' => $course->id,
                    'course_slug' => $course->slug,
                    'course_title' => $course->title,
                ], 403);
            }
        }

        // Phase 1 & 2 Access Gate: Check if session is tied to a Study Cohort
        if ($session->cohort_id && ! $isHost) {
            if (! $user) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Cohort enrollment or active session credit required to join this live classroom session.',
                    'requires_enrollment' => true,
                    'cohort_id' => $session->cohort_id,
                ], 403);
            }

            $isCohortMember = \App\Models\CohortMember::where('cohort_id', $session->cohort_id)
                ->where('student_id', $user->id)
                ->where('status', 'active')
                ->exists();

            $creditBalance = \App\Models\CreditLedger::getStudentBalance($user->id);

            if (! $isCohortMember && $creditBalance <= 0) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Active cohort enrollment or session credit required to join this live cohort session.',
                    'requires_enrollment' => true,
                    'cohort_id' => $session->cohort_id,
                ], 403);
            }

            // If joining using available session credit and hasn't consumed credit for this session yet
            if ($creditBalance > 0) {
                $alreadyCharged = \App\Models\CreditLedger::where('student_id', $user->id)
                    ->where('classroom_session_id', $session->id)
                    ->where('type', 'usage')
                    ->exists();

                if (! $alreadyCharged) {
                    \App\Models\CreditLedger::create([
                        'student_id' => $user->id,
                        'classroom_session_id' => $session->id,
                        'type' => 'usage',
                        'credits_amount' => -1,
                        'balance_after' => $creditBalance - 1,
                        'notes' => "Attended cohort session: {$session->title}",
                    ]);
                }
            }
        }

        // If session is scheduled, only host can enter to prepare equipment
        if ($session->isScheduled() && ! $isHost) {
            return response()->json([
                'status' => 'error',
                'message' => 'The classroom session has not started yet. Please wait for the instructor.',
            ], 422);
        }

        if ($isHost) {
            // Publisher + Room Admin Token for Host Teacher
            $tokenData = $this->tokenService->createTeacherToken($session, $user);
        } elseif ($user && $user->hasRole(Role::STUDENT)) {
            // Subscriber + Chat Token for Enrolled Student
            $tokenData = $this->tokenService->createStudentToken($session, $user);
        } elseif ($user) {
            // Authenticated Parent or General Attendee
            $tokenData = $this->tokenService->createAttendeeToken(
                session: $session,
                identity: "user_{$user->id}",
                name: $user->name,
                role: $user->role ?? 'attendee'
            );
        } else {
            // Guest Attendee (Public via Deep Link)
            $participantName = $request->input('participant_name', 'Guest Student');
            $guestIdentity = 'guest_' . strtolower(Str::random(8));

            $tokenData = $this->tokenService->createAttendeeToken(
                session: $session,
                identity: $guestIdentity,
                name: $participantName,
                role: 'guest'
            );
        }

        return response()->json([
            'status' => 'success',
            'server_url' => $tokenData['server_url'],
            'token' => $tokenData['token'],
            'session' => [
                'session_id' => $session->session_id,
                'title' => $session->title,
                'status' => $session->status,
                'max_participants' => $session->max_participants,
            ],
            'participant' => [
                'identity' => $tokenData['identity'],
                'role' => $tokenData['role'],
                'watermark_text' => $tokenData['watermark_text'] ?? null,
                'can_publish' => $tokenData['can_publish'],
                'can_subscribe' => $tokenData['can_subscribe'],
                'expires_in' => $tokenData['expires_in'],
            ],
        ]);
    }

    /**
     * Verify and inspect a LiveKit SFU access token.
     */
    public function verify(Request $request, string $sessionId): JsonResponse
    {
        $token = $request->input('token');

        if (! $token) {
            return response()->json([
                'status' => 'error',
                'message' => 'Token parameter is required.',
            ], 400);
        }

        try {
            $claims = $this->tokenService->validateToken($token);

            $roomClaim = $claims['video']['room'] ?? null;
            if ($roomClaim !== $sessionId) {
                return response()->json([
                    'status' => 'error',
                    'message' => "Token was issued for room '{$roomClaim}', not '{$sessionId}'.",
                ], 422);
            }

            return response()->json([
                'status' => 'success',
                'valid' => true,
                'claims' => $claims,
            ]);
        } catch (InvalidArgumentException $e) {
            return response()->json([
                'status' => 'error',
                'valid' => false,
                'message' => $e->getMessage(),
            ], 422);
        }
    }
}
