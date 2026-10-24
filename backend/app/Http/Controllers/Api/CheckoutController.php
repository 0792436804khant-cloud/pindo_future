<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Course;
use App\Models\Enrollment;
use App\Models\Order;
use App\Services\PaymentGatewayService;
use Exception;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CheckoutController extends Controller
{
    protected PaymentGatewayService $paymentGateway;

    public function __construct(PaymentGatewayService $paymentGateway)
    {
        $this->paymentGateway = $paymentGateway;
    }

    /**
     * Get checkout preview / price intent for a course.
     */
    public function getIntent(Request $request, int $courseId): JsonResponse
    {
        $user = $request->user();

        $course = Course::published()
            ->with(['teacher.teacherPlatform'])
            ->withCount(['modules', 'lessons'])
            ->findOrFail($courseId);

        $isEnrolled = Enrollment::where('user_id', $user->id)
            ->where('course_id', $course->id)
            ->whereIn('status', [Enrollment::STATUS_ACTIVE, Enrollment::STATUS_COMPLETED])
            ->exists();

        $subtotal = (float) $course->price;
        $tax = 0.00;
        $total = $subtotal + $tax;

        return response()->json([
            'status' => 'success',
            'checkout' => [
                'course' => [
                    'id' => $course->id,
                    'title' => $course->title,
                    'slug' => $course->slug,
                    'category' => $course->category,
                    'price' => $subtotal,
                    'is_free' => $subtotal <= 0,
                    'modules_count' => $course->modules_count,
                    'lessons_count' => $course->lessons_count,
                    'teacher' => [
                        'name' => $course->teacher->name,
                        'headline' => $course->teacher->teacherPlatform?->headline,
                    ],
                ],
                'pricing' => [
                    'currency' => 'DZD',
                    'subtotal' => $subtotal,
                    'tax' => $tax,
                    'total' => $total,
                ],
                'already_enrolled' => $isEnrolled,
            ],
        ]);
    }

    /**
     * Process course checkout charge via payment gateway.
     */
    public function processCharge(Request $request, int $courseId): JsonResponse
    {
        $validated = $request->validate([
            'card_number' => 'required|string',
            'exp_month' => 'required|integer|min:1|max:12',
            'exp_year' => 'required|integer|min:2024|max:2040',
            'cvc' => 'required|string|min:3|max:4',
            'cardholder_name' => 'required|string|max:100',
        ]);

        $student = $request->user();

        $course = Course::published()
            ->with(['teacher'])
            ->findOrFail($courseId);

        try {
            $order = $this->paymentGateway->chargeCourse($student, $course, $validated);

            return response()->json([
                'status' => 'success',
                'message' => "Payment successful! You are now enrolled in '{$course->title}'.",
                'receipt' => [
                    'order_id' => $order->id,
                    'order_number' => $order->order_number,
                    'receipt_number' => $order->receipt_number,
                    'amount' => $order->amount,
                    'currency' => $order->currency,
                    'status' => $order->status,
                    'payment_method' => $order->payment_method,
                    'card_brand' => $order->payment_metadata['brand'] ?? 'Visa',
                    'card_last4' => $order->payment_metadata['last4'] ?? '4242',
                    'paid_at' => $order->paid_at->toIso8601String(),
                    'course' => [
                        'id' => $course->id,
                        'title' => $course->title,
                        'teacher_name' => $course->teacher->name,
                    ],
                ],
            ], 201);
        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
            ], 422);
        }
    }

    /**
     * Redeem an Academic Voucher Code to enroll in a course (for Algerian students).
     */
    public function redeemVoucher(Request $request, int $courseId): JsonResponse
    {
        $validated = $request->validate([
            'voucher_code' => 'required|string|min:4|max:50',
        ]);

        $student = $request->user();

        $course = Course::published()
            ->with(['teacher'])
            ->findOrFail($courseId);

        try {
            $order = $this->paymentGateway->redeemVoucher($student, $course, $validated['voucher_code']);

            return response()->json([
                'status' => 'success',
                'message' => "Activation successful! You are now enrolled in '{$course->title}' with 4 session credits.",
                'receipt' => [
                    'order_id' => $order->id,
                    'order_number' => $order->order_number,
                    'receipt_number' => $order->receipt_number,
                    'amount' => $order->amount,
                    'currency' => $order->currency,
                    'status' => $order->status,
                    'payment_method' => $order->payment_method,
                    'voucher_code' => $order->payment_metadata['voucher_code'] ?? $validated['voucher_code'],
                    'paid_at' => $order->paid_at->toIso8601String(),
                    'course' => [
                        'id' => $course->id,
                        'title' => $course->title,
                        'teacher_name' => $course->teacher->name,
                    ],
                ],
            ], 201);
        } catch (Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
            ], 422);
        }
    }

    /**
     * Get purchase orders and invoices for the authenticated student.
     */
    public function getStudentOrders(Request $request): JsonResponse
    {
        $user = $request->user();

        $orders = Order::where('user_id', $user->id)
            ->with(['course.teacher'])
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function (Order $order) {
                return [
                    'id' => $order->id,
                    'order_number' => $order->order_number,
                    'receipt_number' => $order->receipt_number,
                    'amount' => $order->amount,
                    'currency' => $order->currency,
                    'status' => $order->status,
                    'card_brand' => $order->payment_metadata['brand'] ?? 'Card',
                    'card_last4' => $order->payment_metadata['last4'] ?? '****',
                    'paid_at' => $order->paid_at?->toIso8601String() ?? $order->created_at->toIso8601String(),
                    'course' => [
                        'id' => $order->course->id,
                        'title' => $order->course->title,
                        'category' => $order->course->category,
                        'teacher_name' => $order->course->teacher?->name ?? 'Instructor',
                    ],
                ];
            });

        return response()->json([
            'status' => 'success',
            'data' => $orders,
        ]);
    }
}
