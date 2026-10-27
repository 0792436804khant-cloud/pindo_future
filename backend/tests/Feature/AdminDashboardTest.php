<?php

namespace Tests\Feature;

use App\Models\Role;
use App\Models\TeacherPayout;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminDashboardTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Role::firstOrCreate(['name' => Role::ADMIN], ['label' => 'Admin']);
        Role::firstOrCreate(['name' => Role::TEACHER], ['label' => 'Teacher']);
    }

    public function test_admin_can_fetch_dashboard_payload(): void
    {
        $admin = User::create([
            'name' => 'System Root Admin',
            'email' => 'admin@pindofuture.com',
            'password' => bcrypt('password123'),
            'role' => Role::ADMIN,
        ]);

        $teacher = User::create([
            'name' => 'Prof. Amine',
            'email' => 'amine@pindofuture.com',
            'password' => bcrypt('password123'),
            'role' => Role::TEACHER,
            'verification_status' => 'pending',
        ]);

        $payout = TeacherPayout::create([
            'teacher_id' => $teacher->id,
            'amount' => 12000.00,
            'currency' => 'DZD',
            'status' => TeacherPayout::STATUS_REQUESTED,
            'payout_method' => 'BaridiMob',
            'destination_account' => '00799999000123456789',
        ]);

        $response = $this->actingAs($admin, 'sanctum')
            ->getJson('/api/v1/admin/dashboard');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'status',
                'data' => [
                    'kpis' => [
                        'total_students_count',
                        'total_teachers_count',
                        'verified_teachers_count',
                        'pending_verifications_count',
                        'total_cohorts_count',
                        'active_live_sessions_count',
                        'gross_revenue',
                        'platform_commission',
                        'teacher_net_earnings',
                        'pending_payouts_count',
                        'pending_payouts_amount',
                        'sfu_cluster_capacity',
                        'sfu_cluster_status',
                    ],
                    'pending_verifications',
                    'pending_payouts',
                ],
            ]);

        $this->assertEquals(1, $response->json('data.kpis.pending_verifications_count'));
        $this->assertEquals(1, $response->json('data.kpis.pending_payouts_count'));
    }

    public function test_admin_can_approve_teacher_payout(): void
    {
        $admin = User::create([
            'name' => 'Finance Admin',
            'email' => 'finance@pindofuture.com',
            'password' => bcrypt('password123'),
            'role' => Role::ADMIN,
        ]);

        $teacher = User::create([
            'name' => 'Prof. Khaled',
            'email' => 'khaled@pindofuture.com',
            'password' => bcrypt('password123'),
            'role' => Role::TEACHER,
        ]);

        $payout = TeacherPayout::create([
            'teacher_id' => $teacher->id,
            'amount' => 15000.00,
            'currency' => 'DZD',
            'status' => TeacherPayout::STATUS_REQUESTED,
            'payout_method' => 'BaridiMob',
        ]);

        $response = $this->actingAs($admin, 'sanctum')
            ->postJson("/api/v1/admin/payouts/{$payout->id}/approve");

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
            ]);

        $this->assertDatabaseHas('teacher_payouts', [
            'id' => $payout->id,
            'status' => TeacherPayout::STATUS_COMPLETED,
        ]);
    }
}
