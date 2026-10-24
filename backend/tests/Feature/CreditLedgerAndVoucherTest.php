<?php

namespace Tests\Feature;

use App\Models\Course;
use App\Models\CreditLedger;
use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CreditLedgerAndVoucherTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    public function test_voucher_redemption_enrolls_student_and_credits_sessions(): void
    {
        $student = User::where('role', Role::STUDENT)->first();
        $course = Course::published()->first();

        $response = $this->actingAs($student, 'sanctum')
            ->postJson("/api/v1/checkout/voucher/{$course->id}", [
                'voucher_code' => 'PINDO2026',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('receipt.payment_method', 'activation_voucher');

        $this->assertDatabaseHas('credit_ledgers', [
            'student_id' => $student->id,
            'type' => 'credit_purchase',
            'credits_amount' => 4,
            'balance_after' => 4,
        ]);

        // Verify /api/v1/student/credits reflects the new balance
        $creditsResponse = $this->actingAs($student, 'sanctum')
            ->getJson('/api/v1/student/credits');

        $creditsResponse->assertStatus(200)
            ->assertJsonPath('data.available_credits', 4)
            ->assertJsonCount(1, 'data.transactions');
    }
}
