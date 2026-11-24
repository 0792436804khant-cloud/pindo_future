<?php

namespace Tests\Feature;

use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminWebPanelSecurityTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Role::firstOrCreate(['name' => Role::ADMIN], ['label' => 'Admin']);
        Role::firstOrCreate(['name' => Role::STUDENT], ['label' => 'Student']);
    }

    public function test_unauthenticated_users_cannot_access_admin_dashboard_or_api(): void
    {
        $this->get('/admin/dashboard')->assertRedirect('/admin/login');
        $this->getJson('/admin/api/telemetry')->assertStatus(401);
        $this->postJson('/admin/api/teachers/1/approve')->assertStatus(401);
        $this->postJson('/admin/api/subscriptions/1/approve')->assertStatus(401);
        $this->postJson('/admin/api/sessions/1/terminate')->assertStatus(401);
    }

    public function test_student_cannot_access_admin_web_api(): void
    {
        $student = User::create([
            'name' => 'Student User',
            'email' => 'student.sec@pindofuture.com',
            'password' => bcrypt('StrongPass123!'),
            'role' => Role::STUDENT,
        ]);

        $this->actingAs($student, 'web')
            ->getJson('/admin/api/telemetry')
            ->assertStatus(401);
    }

    public function test_admin_login_view_does_not_expose_hardcoded_credentials(): void
    {
        $response = $this->get('/admin/login');
        $response->assertStatus(200);
        $response->assertDontSee('AdminPassword123!');
        $response->assertDontSee('ملء بيانات الإدارة التجريبية');
    }

    public function test_authenticated_admin_can_access_dashboard_and_telemetry(): void
    {
        $admin = User::create([
            'name' => 'Root Admin',
            'email' => 'root.sec@pindofuture.com',
            'password' => bcrypt('StrongPass123!'),
            'role' => Role::ADMIN,
        ]);

        $this->actingAs($admin, 'web')
            ->get('/admin/dashboard')
            ->assertStatus(200);

        $this->actingAs($admin, 'web')
            ->getJson('/admin/api/telemetry')
            ->assertStatus(200)
            ->assertJsonPath('status', 'success');
    }
}
