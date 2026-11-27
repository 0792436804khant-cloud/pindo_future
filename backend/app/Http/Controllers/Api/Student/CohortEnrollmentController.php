<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Models\CohortMember;
use App\Models\Order;
use App\Models\StudyCohort;
use App\Models\TeacherEarning;
use App\Services\CacheManagerService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class CohortEnrollmentController extends Controller
{
    /**
     * Search and discover study cohorts.
     */
    public function index(Request $request): JsonResponse
    {
        $query = StudyCohort::where('is_active', true)
            ->with(['teacher:id,name,teacher_id,is_verified,verification_status,wilaya']);

        if ($request->filled('academic_level')) {
            $query->where('academic_level', $request->query('academic_level'));
        }

        if ($request->filled('stream')) {
            $query->where('stream', $request->query('stream'));
        }

        if ($request->filled('subject')) {
            $query->where('subject', 'like', '%' . $request->query('subject') . '%');
        }

        if ($request->filled('teacher_id')) {
            $query->where('teacher_id', $request->query('teacher_id'));
        }

        if ($request->filled('wilaya')) {
            $wilaya = (int) $request->query('wilaya');
            $query->whereHas('teacher', fn ($q) => $q->where('wilaya', $wilaya));
        }

        if ($request->filled('search')) {
            $searchTerm = '%' . $request->query('search') . '%';
            $query->where(function ($q) use ($searchTerm) {
                $q->where('name', 'like', $searchTerm)
                  ->orWhere('subject', 'like', $searchTerm)
                  ->orWhere('description', 'like', $searchTerm)
                  ->orWhereHas('teacher', fn ($t) => $t->where('name', 'like', $searchTerm));
            });
        }

        $cohorts = $query->orderByDesc('created_at')->paginate($request->query('per_page', 20));

        return response()->json([
            'status' => 'success',
            'data' => $cohorts->items(),
            'meta' => [
                'current_page' => $cohorts->currentPage(),
                'last_page' => $cohorts->lastPage(),
                'total' => $cohorts->total(),
            ],
        ]);
    }

    /**
     * List all cohorts the student is currently enrolled in.
     */
    public function myCohorts(Request $request): JsonResponse
    {
        $student = $request->user();

        $cohorts = $student->enrolledCohorts()
            ->with(['teacher:id,name,teacher_id,is_verified,verification_status,wilaya', 'sessions' => fn ($q) => $q->where('status', 'scheduled')->orderBy('scheduled_at')])
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $cohorts,
        ]);
    }

    /**
     * Student joins a study cohort.
     */
    public function join(int $id, Request $request): JsonResponse
    {
        $student = $request->user();

        if ($student->role !== 'student') {
            return response()->json([
                'status' => 'error',
                'message' => 'فقط حسابات التلاميذ يمكنها الانضمام إلى الأفواج التعليمية',
            ], 403);
        }

        $cohort = StudyCohort::where('is_active', true)->findOrFail($id);

        if ($cohort->isFull()) {
            return response()->json([
                'status' => 'error',
                'message' => 'عذراً، هذا الفوج ممتلئ حالياً',
            ], 422);
        }

        if ($cohort->hasStudent($student->id)) {
            return response()->json([
                'status' => 'error',
                'message' => 'أنت مسجل بالفعل في هذا الفوج التعليمي',
            ], 422);
        }

        $validated = $request->validate([
            'package_type' => ['nullable', 'string', Rule::in([
                StudyCohort::PACKAGE_LIVE_ONLY,
                StudyCohort::PACKAGE_LIBRARY_ONLY,
                StudyCohort::PACKAGE_FULL_BUNDLE,
            ])],
            'payment_method' => ['nullable', 'string', 'max:50'],
            'tx_reference' => ['nullable', 'string', 'max:100'],
        ]);

        $packageType = $validated['package_type'] ?? StudyCohort::PACKAGE_FULL_BUNDLE;
        if ($packageType === StudyCohort::PACKAGE_LIBRARY_ONLY && ! $cohort->include_library) {
            return response()->json([
                'status' => 'error',
                'message' => 'المكتبة الرقمية غير متاحة في هذا الفوج',
            ], 422);
        }

        $pricing = $cohort->resolvePackagePricing($packageType);

        $member = DB::transaction(function () use ($cohort, $student, $pricing, $validated) {
            $member = CohortMember::create([
                'cohort_id' => $cohort->id,
                'student_id' => $student->id,
                'status' => 'active',
                'package_type' => $pricing['package_type'],
                'price_paid_dzd' => $pricing['gross_amount'],
                'live_access' => $pricing['live_access'],
                'library_access' => $pricing['library_access'],
                'joined_at' => now(),
                'ends_at' => now()->addMonth(),
            ]);

            if ($pricing['gross_amount'] > 0) {
                $order = Order::create([
                    'user_id' => $student->id,
                    'cohort_id' => $cohort->id,
                    'package_type' => $pricing['package_type'],
                    'amount' => $pricing['gross_amount'],
                    'currency' => 'DZD',
                    'status' => Order::STATUS_COMPLETED,
                    'payment_method' => $validated['payment_method'] ?? 'BaridiMob',
                    'tx_reference' => $validated['tx_reference'] ?? null,
                    'paid_at' => now(),
                    'subscription_ends_at' => now()->addMonth(),
                ]);

                TeacherEarning::create([
                    'teacher_id' => $cohort->teacher_id,
                    'order_id' => $order->id,
                    'cohort_id' => $cohort->id,
                    'package_type' => $pricing['package_type'],
                    'live_gross_amount' => $pricing['live_gross_amount'],
                    'library_gross_amount' => $pricing['library_gross_amount'],
                    'live_platform_fee' => $pricing['live_platform_fee'],
                    'library_platform_fee' => $pricing['library_platform_fee'],
                    'gross_amount' => $pricing['gross_amount'],
                    'platform_fee' => $pricing['platform_fee'],
                    'net_amount' => $pricing['teacher_net_amount'],
                    'status' => TeacherEarning::STATUS_AVAILABLE,
                ]);
            }

            $cohort->recalculateEnrolledCount();

            return $member;
        });

        $cache = app(CacheManagerService::class);
        $cache->invalidateTeacher($cohort->teacher_id);
        $cache->invalidateStudent($student->id);

        return response()->json([
            'status' => 'success',
            'message' => 'تم الانضمام إلى الفوج بنجاح! مرحباً بك',
            'pricing_breakdown' => $pricing,
            'membership' => $member,
            'data' => $cohort->fresh(['teacher:id,name,teacher_id,is_verified', 'sessions']),
        ], 201);
    }

    /**
     * Student leaves a cohort.
     */
    public function leave(int $id, Request $request): JsonResponse
    {
        $student = $request->user();
        $cohort = StudyCohort::findOrFail($id);

        $deleted = CohortMember::where('cohort_id', $cohort->id)
            ->where('student_id', $student->id)
            ->delete();

        if (! $deleted) {
            return response()->json([
                'status' => 'error',
                'message' => 'أنت لست مسجلاً في هذا الفوج',
            ], 404);
        }

        $cohort->recalculateEnrolledCount();

        return response()->json([
            'status' => 'success',
            'message' => 'تمت مغادرة الفوج بنجاح',
        ]);
    }
}
