<?php

namespace Tests\Feature;

use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(); // Seed roles, permissions, and demo users
    }

    /**
     * Test student registration.
     */
    public function test_student_registration_succeeds_with_token(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Marie Curie',
            'email' => 'marie.curie@pindofuture.com',
            'password' => 'SecurePassword123!',
            'password_confirmation' => 'SecurePassword123!',
            'role' => 'student',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('user.role', 'student')
            ->assertJsonPath('user.email', 'marie.curie@pindofuture.com')
            ->assertJsonStructure(['token', 'user' => ['id', 'name', 'email', 'role']]);

        $this->assertDatabaseHas('users', [
            'email' => 'marie.curie@pindofuture.com',
            'role' => 'student',
        ]);
    }

    /**
     * Test teacher registration auto-generates teacher_id.
     */
    public function test_teacher_registration_generates_teacher_id(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Richard Feynman',
            'email' => 'richard.feynman@pindofuture.com',
            'password' => 'PhysicsIsFun123!',
            'password_confirmation' => 'PhysicsIsFun123!',
            'role' => 'teacher',
            'teaching_levels' => ['High School (Secondary)'],
            'teaching_years' => ['3AS (BAC)'],
            'teaching_subjects' => ['Physics & Quantum Mechanics'],
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('user.role', 'teacher');

        $user = User::where('email', 'richard.feynman@pindofuture.com')->first();
        $this->assertNotNull($user->teacher_id);
        $this->assertStringStartsWith('TCH_', $user->teacher_id);
    }

    /**
     * Test parent registration.
     */
    public function test_parent_registration_succeeds(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'John Doe Sr',
            'email' => 'john.senior@pindofuture.com',
            'password' => 'ParentSecret123!',
            'password_confirmation' => 'ParentSecret123!',
            'role' => 'parent',
            'student_id' => 'student.demo@pindofuture.com',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('user.role', 'parent');
    }

    /**
     * Test registration rejects invalid roles.
     */
    public function test_registration_rejects_invalid_roles(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Bad Actor',
            'email' => 'bad.actor@pindofuture.com',
            'password' => 'Password123!',
            'password_confirmation' => 'Password123!',
            'role' => 'hacker',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['role']);
    }

    /**
     * Test successful login returns sanctum token and user profile.
     */
    public function test_login_returns_sanctum_token(): void
    {
        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'admin@pindofuture.com',
            'password' => 'AdminPassword123!',
            'device_name' => 'PHPUnit Test Device',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('user.email', 'admin@pindofuture.com')
            ->assertJsonPath('user.role', 'admin')
            ->assertJsonStructure(['token', 'user']);
    }

    /**
     * Test login failure on invalid credentials.
     */
    public function test_login_fails_with_invalid_credentials(): void
    {
        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'admin@pindofuture.com',
            'password' => 'WrongPassword!',
        ]);

        $response->assertStatus(422)
            ->assertJsonPath('status', 'error');
    }

    /**
     * Test fetch current user profile (GET /api/v1/auth/me).
     */
    public function test_me_endpoint_returns_authenticated_user_profile(): void
    {
        $teacher = User::where('email', 'teacher.demo@pindofuture.com')->first();
        $token = $teacher->createToken('TestDevice')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/v1/auth/me');

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('user.email', 'teacher.demo@pindofuture.com')
            ->assertJsonPath('user.role', 'teacher')
            ->assertJsonPath('user.teacher_id', 'TCH_123');
    }

    /**
     * Test unauthenticated access to /api/v1/auth/me fails.
     */
    public function test_me_endpoint_rejects_unauthenticated_request(): void
    {
        $response = $this->getJson('/api/v1/auth/me');

        $response->assertStatus(401);
    }

    /**
     * Test logout revokes current token.
     */
    public function test_logout_revokes_token(): void
    {
        $student = User::where('email', 'student.demo@pindofuture.com')->first();
        $token = $student->createToken('TestDevice')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/v1/auth/logout');

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success');

        $this->assertCount(0, $student->fresh()->tokens);

        // Reset cached auth state for fresh authentication attempt
        $this->app['auth']->forgetGuards();

        // Subsequent access with revoked token must fail with 401
        $subsequentResponse = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/v1/auth/me');

        $subsequentResponse->assertStatus(401);
    }

    /**
     * Test public registration rejects admin role (privilege escalation prevention).
     */
    public function test_registration_rejects_admin_role(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Malicious Actor',
            'email' => 'hacker@pindofuture.com',
            'password' => 'Password123!',
            'password_confirmation' => 'Password123!',
            'role' => 'admin',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['role']);
    }

    /**
     * Test user can permanently delete their account (Apple Guideline 5.1.1(v) compliance).
     */
    public function test_user_can_permanently_delete_account(): void
    {
        $user = User::create([
            'name' => 'Delete Me User',
            'email' => 'delete.me@pindofuture.com',
            'password' => bcrypt('Secret123!'),
            'role' => 'student',
        ]);
        $token = $user->createToken('DeleteDevice')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->deleteJson('/api/v1/auth/account');

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success');

        $this->assertDatabaseMissing('users', [
            'id' => $user->id,
            'email' => 'delete.me@pindofuture.com',
        ]);
    }
}
