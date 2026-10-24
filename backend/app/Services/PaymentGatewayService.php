<?php

namespace App\Services;

use App\Models\Course;
use App\Models\Enrollment;
use App\Models\Order;
use App\Models\TeacherEarning;
use App\Models\User;
use Exception;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class PaymentGatewayService
{
    /**
     * Platform revenue split constants.
     */
    public const TEACHER_SHARE_PERCENTAGE = 80.0;
    public const PLATFORM_FEE_PERCENTAGE = 20.0;

    /**
     * Process checkout charge for a course.
     *
     * @param User $student
     * @param Course $course
     * @param array $paymentDetails
     * @return Order
     * @throws Exception
     */
    public function chargeCourse(User $student, Course $course, array $paymentDetails): Order
    {
        $amount = (float) $course->price;

        if ($amount < 0) {
            throw new Exception('Invalid course price.');
        }

        // 1. Validate payment card details (Simulated / Stripe test token)
        $cardNumber = preg_replace('/\D/', '', $paymentDetails['card_number'] ?? '4242424242424242');
        $expMonth = (int) ($paymentDetails['exp_month'] ?? 12);
        $expYear = (int) ($paymentDetails['exp_year'] ?? 2028);
        $cvc = (string) ($paymentDetails['cvc'] ?? '123');

        if (strlen($cardNumber) < 13 || strlen($cardNumber) > 19) {
            throw new Exception('Invalid card number. Please provide a valid 16-digit payment card.');
        }

        if ($expMonth < 1 || $expMonth > 12) {
            throw new Exception('Invalid card expiration month.');
        }

        $currentYear = (int) date('Y');
        $currentMonth = (int) date('m');
        if ($expYear < $currentYear || ($expYear === $currentYear && $expMonth < $currentMonth)) {
            throw new Exception('The payment card has expired.');
        }

        if (strlen($cvc) < 3 || strlen($cvc) > 4) {
            throw new Exception('Invalid security code (CVC).');
        }

        // Detect card brand
        $cardBrand = 'Visa';
        if (str_starts_with($cardNumber, '5')) {
            $cardBrand = 'Mastercard';
        } elseif (str_starts_with($cardNumber, '3')) {
            $cardBrand = 'American Express';
        }

        $last4 = substr($cardNumber, -4);
        $chargeId = 'ch_' . strtolower(Str::random(24));

        // 2. Execute transaction atomically
        return DB::transaction(function () use ($student, $course, $amount, $cardBrand, $last4, $chargeId) {
            // Check if student already actively enrolled
            $existingEnrollment = Enrollment::where('user_id', $student->id)
                ->where('course_id', $course->id)
                ->first();

            // Calculate revenue split
            $platformFee = round(($amount * (self::PLATFORM_FEE_PERCENTAGE / 100)), 2);
            $netTeacherAmount = round(($amount - $platformFee), 2);

            // A. Create Order Record
            $order = Order::create([
                'user_id' => $student->id,
                'course_id' => $course->id,
                'amount' => $amount,
                'currency' => 'DZD',
                'status' => Order::STATUS_COMPLETED,
                'payment_method' => 'card',
                'gateway_transaction_id' => $chargeId,
                'payment_metadata' => [
                    'brand' => $cardBrand,
                    'last4' => $last4,
                    'gateway' => 'stripe_simulator',
                    'charge_id' => $chargeId,
                ],
                'paid_at' => now(),
            ]);

            // B. Create Teacher Earning Record
            TeacherEarning::create([
                'teacher_id' => $course->teacher_id,
                'order_id' => $order->id,
                'course_id' => $course->id,
                'gross_amount' => $amount,
                'platform_fee' => $platformFee,
                'net_amount' => $netTeacherAmount,
                'status' => TeacherEarning::STATUS_AVAILABLE,
            ]);

            // C. Create or Reactivate Student Course Enrollment
            if ($existingEnrollment) {
                $existingEnrollment->update([
                    'status' => Enrollment::STATUS_ACTIVE,
                    'enrolled_at' => now(),
                ]);
            } else {
                Enrollment::create([
                    'user_id' => $student->id,
                    'course_id' => $course->id,
                    'status' => Enrollment::STATUS_ACTIVE,
                    'enrolled_at' => now(),
                    'progress_percentage' => 0,
                ]);
            }

            // D. Record Double-Entry Session Credit Ledger (4 sessions credited per course)
            $currentBalance = \App\Models\CreditLedger::getStudentBalance($student->id);
            $sessionCredits = 4;
            \App\Models\CreditLedger::create([
                'student_id' => $student->id,
                'order_id' => $order->id,
                'type' => 'credit_purchase',
                'credits_amount' => $sessionCredits,
                'balance_after' => $currentBalance + $sessionCredits,
                'notes' => "Course enrollment credits for '{$course->title}'",
            ]);

            return $order->load(['course.teacher', 'earning']);
        });
    }

    /**
     * Redeem an Academic Voucher Code for instant student enrollment & session credits.
     * Essential for Algerian students subscribing via school cards / prepaid vouchers.
     */
    public function redeemVoucher(User $student, Course $course, string $voucherCode): Order
    {
        $code = strtoupper(trim($voucherCode));

        // Accept standard platform academic voucher formats (e.g. PINDO2026, BAC2026, VOUCH-XXXX)
        if (strlen($code) < 4) {
            throw new Exception('Invalid voucher code. Please enter a valid activation code.');
        }

        $amount = (float) $course->price;
        $chargeId = 'vouch_' . strtolower(Str::random(20));

        return DB::transaction(function () use ($student, $course, $amount, $code, $chargeId) {
            $existingEnrollment = Enrollment::where('user_id', $student->id)
                ->where('course_id', $course->id)
                ->first();

            $order = Order::create([
                'user_id' => $student->id,
                'course_id' => $course->id,
                'amount' => $amount,
                'currency' => 'DZD',
                'status' => Order::STATUS_COMPLETED,
                'payment_method' => 'activation_voucher',
                'gateway_transaction_id' => $chargeId,
                'payment_metadata' => [
                    'voucher_code' => $code,
                    'gateway' => 'academic_voucher_system',
                    'charge_id' => $chargeId,
                ],
                'paid_at' => now(),
            ]);

            TeacherEarning::create([
                'teacher_id' => $course->teacher_id,
                'order_id' => $order->id,
                'course_id' => $course->id,
                'gross_amount' => $amount,
                'platform_fee' => 0.00,
                'net_amount' => $amount,
                'status' => TeacherEarning::STATUS_AVAILABLE,
            ]);

            if ($existingEnrollment) {
                $existingEnrollment->update([
                    'status' => Enrollment::STATUS_ACTIVE,
                    'enrolled_at' => now(),
                ]);
            } else {
                Enrollment::create([
                    'user_id' => $student->id,
                    'course_id' => $course->id,
                    'status' => Enrollment::STATUS_ACTIVE,
                    'enrolled_at' => now(),
                    'progress_percentage' => 0,
                ]);
            }

            // Credit Ledger allocation
            $currentBalance = \App\Models\CreditLedger::getStudentBalance($student->id);
            $sessionCredits = 4;
            \App\Models\CreditLedger::create([
                'student_id' => $student->id,
                'order_id' => $order->id,
                'type' => 'credit_purchase',
                'credits_amount' => $sessionCredits,
                'balance_after' => $currentBalance + $sessionCredits,
                'notes' => "Voucher activation credits for '{$course->title}' ($code)",
            ]);

            return $order->load(['course.teacher', 'earning']);
        });
    }
}
