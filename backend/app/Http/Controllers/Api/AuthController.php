<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Resources\UserResource;
use App\Models\Role;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Handle user registration.
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $student = null;
        if ($validated['role'] === Role::PARENT) {
            $studentIdentifier = trim($validated['student_id'] ?? '');
            if (empty($studentIdentifier)) {
                throw ValidationException::withMessages([
                    'student_id' => ['Student ID is strictly required to create a parent account.'],
                ]);
            }

            $student = User::where('role', Role::STUDENT)
                ->where(function ($query) use ($studentIdentifier) {
                    if (is_numeric($studentIdentifier)) {
                        $query->orWhere('id', (int) $studentIdentifier);
                    }
                    $query->orWhere('student_id', $studentIdentifier)
                          ->orWhere('email', $studentIdentifier);
                })
                ->first();

            if (! $student) {
                $student = User::where('role', Role::STUDENT)
                    ->whereHas('guardians', function ($q) use ($studentIdentifier) {
                        $q->where('linking_code', $studentIdentifier);
                    })
                    ->first();
            }

            if (! $student) {
                throw ValidationException::withMessages([
                    'student_id' => ["The specified Student ID '{$studentIdentifier}' was not found. Please provide a valid Student ID, Email, or Linking Code."],
                ]);
            }
        }

        $levels = null;
        $years = null;
        $subjects = null;
        if ($validated['role'] === Role::TEACHER) {
            $levels = is_array($validated['teaching_levels'] ?? null)
                ? $validated['teaching_levels']
                : (isset($validated['teaching_levels']) ? array_values(array_filter(array_map('trim', explode(',', (string) $validated['teaching_levels'])))) : []);
            $years = is_array($validated['teaching_years'] ?? null)
                ? $validated['teaching_years']
                : (isset($validated['teaching_years']) ? array_values(array_filter(array_map('trim', explode(',', (string) $validated['teaching_years'])))) : []);
            $subjects = is_array($validated['teaching_subjects'] ?? null)
                ? $validated['teaching_subjects']
                : (isset($validated['teaching_subjects']) ? array_values(array_filter(array_map('trim', explode(',', (string) $validated['teaching_subjects'])))) : []);
        }

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role' => $validated['role'],
            'teacher_id' => $validated['teacher_id'] ?? null,
            'teaching_levels' => $levels,
            'teaching_years' => $years,
            'teaching_subjects' => $subjects,
            'wilaya' => $validated['wilaya'] ?? null,
            'academic_level' => $validated['academic_level'] ?? null,
            'stream' => $validated['stream'] ?? null,
        ]);

        // Automatically link parent to child if registering as parent
        if ($user->role === Role::PARENT && $student) {
            \App\Models\ParentStudent::firstOrCreate(
                [
                    'parent_id' => $user->id,
                    'student_id' => $student->id,
                ],
                [
                    'relationship' => $validated['relationship'] ?? 'Legal Guardian',
                    'status' => 'active',
                    'linking_code' => $student->student_id ?? 'LINK_' . strtoupper(Str::random(6)),
                    'linked_at' => now(),
                ]
            );
        }

        // Synchronize Role model
        $role = Role::where('name', $validated['role'])->first();
        if ($role) {
            $user->roles()->syncWithoutDetaching([$role->id]);
        }

        $deviceName = $validated['device_name'] ?? 'Flutter Mobile Client';
        $token = $user->createToken($deviceName)->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'User registered successfully.',
            'user' => new UserResource($user->load('roles.permissions')),
            'token' => $token,
        ], 201);
    }

    /**
     * Handle user login.
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $throttleKey = Str::transliterate(Str::lower($validated['email']) . '|' . $request->ip());

        if (RateLimiter::tooManyAttempts($throttleKey, 5)) {
            $seconds = RateLimiter::availableIn($throttleKey);
            return response()->json([
                'status' => 'error',
                'message' => "Too many failed login attempts. For account security, access is temporarily locked. Try again in {$seconds} seconds.",
                'retry_after' => $seconds,
            ], 429);
        }

        $user = User::where('email', $validated['email'])->first();

        if (! $user || ! Hash::check($validated['password'], $user->password)) {
            RateLimiter::hit($throttleKey, 60);
            $remaining = RateLimiter::remaining($throttleKey, 5);
            return response()->json([
                'status' => 'error',
                'message' => "The provided credentials do not match our records. {$remaining} attempts remaining before security lockout.",
                'errors' => [
                    'email' => ['The provided credentials do not match our records.'],
                ],
                'attempts_remaining' => $remaining,
            ], 422);
        }

        RateLimiter::clear($throttleKey);

        $deviceName = $validated['device_name'] ?? 'Flutter Mobile Client';
        $token = $user->createToken($deviceName)->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Login successful.',
            'user' => new UserResource($user->load('roles.permissions')),
            'token' => $token,
        ]);
    }

    /**
     * Fetch the currently authenticated user's profile and permissions.
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user()->load('roles.permissions');

        return response()->json([
            'status' => 'success',
            'user' => new UserResource($user),
        ]);
    }

    /**
     * Log out the user by revoking the current Sanctum access token.
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Logged out successfully.',
        ]);
    }

    /**
     * Delete the authenticated user account and all personal data.
     * Compliant with Apple Guideline 5.1.1(v) & Google Play Data Safety policies.
     */
    public function deleteAccount(Request $request): JsonResponse
    {
        $user = $request->user();

        // Revoke all Sanctum tokens
        $user->tokens()->delete();

        \Illuminate\Support\Facades\DB::transaction(function () use ($user) {
            // Remove parent-student links
            \App\Models\ParentStudent::where('parent_id', $user->id)
                ->orWhere('student_id', $user->id)
                ->delete();

            // Delete guardian notes
            \App\Models\GuardianNote::where('student_id', $user->id)
                ->orWhere('author_id', $user->id)
                ->delete();

            // Detach roles
            $user->roles()->detach();

            // Delete user
            $user->delete();
        });

        return response()->json([
            'status' => 'success',
            'message' => 'Your account and all associated personal data have been permanently deleted.',
        ]);
    }
}
