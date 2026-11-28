<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use App\Models\ClassroomSession;
use App\Models\CohortMember;
use App\Models\Order;
use App\Models\StudyCohort;
use App\Models\TeacherEarning;
use App\Services\BilingualTaxonomyService;
use App\Services\CacheManagerService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class CohortEnrollmentController extends Controller
{
    /**
     * Search and discover study cohorts.
     */
    public function index(Request $request): JsonResponse
    {
        $query = StudyCohort::where('is_active', true)
            ->with([
                'teacher:id,name,teacher_id,is_verified,verification_status,wilaya,teaching_levels,teaching_years,teaching_subjects',
                'teacher.teacherPlatform:id,user_id,headline,bio,settings',
            ]);

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
            $includedQuota = max(1, (int) ($cohort->included_sessions_count ?? 8));
            $member = CohortMember::create([
                'cohort_id' => $cohort->id,
                'student_id' => $student->id,
                'status' => 'active',
                'package_type' => $pricing['package_type'],
                'price_paid_dzd' => $pricing['gross_amount'],
                'live_access' => $pricing['live_access'],
                'library_access' => $pricing['library_access'],
                'sessions_quota' => $includedQuota,
                'sessions_attended' => 0,
                'first_session_number' => 1,
                'last_session_number' => $includedQuota,
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

    /**
     * Public safe preview of a study cohort & its teacher showcase.
     * Exposes teacher profile, curriculum pricing, session quota & schedule summary ONLY —
     * strictly omits cohort chat, live stream tokens/URLs, and enrolled students list.
     */
    public function preview(int $id): JsonResponse
    {
        $cohort = StudyCohort::where('is_active', true)
            ->with([
                'teacher:id,name,teacher_id,is_verified,verification_status,wilaya,teaching_levels,teaching_years,teaching_subjects',
                'teacher.teacherPlatform:id,user_id,headline,bio,settings',
            ])
            ->findOrFail($id);

        $teacher = $cohort->teacher;
        $platform = $teacher?->teacherPlatform;
        $settings = $platform?->settings ?? [];
        $wilayaInfo = BilingualTaxonomyService::resolveWilaya($teacher?->wilaya ?? 16);

        $upcomingPreviewSessions = ClassroomSession::where('cohort_id', $cohort->id)
            ->whereIn('status', [ClassroomSession::STATUS_SCHEDULED, ClassroomSession::STATUS_ACTIVE])
            ->orderBy('scheduled_at', 'asc')
            ->limit(12)
            ->get(['id', 'title', 'session_number', 'session_category', 'extra_price_dzd', 'scheduled_at', 'status'])
            ->map(fn ($s) => [
                'title' => $s->title,
                'session_number' => $s->session_number,
                'session_category' => $s->session_category ?? ClassroomSession::CATEGORY_REGULAR,
                'extra_price_dzd' => (float) ($s->extra_price_dzd ?? 0),
                'scheduled_at' => $s->scheduled_at?->toIso8601String(),
                'status' => $s->status,
            ])->values();

        return response()->json([
            'status' => 'success',
            'data' => [
                'cohort' => [
                    'id' => $cohort->id,
                    'cohort_code' => $cohort->cohort_code,
                    'name' => $cohort->name,
                    'subject' => $cohort->subject,
                    'academic_level' => $cohort->academic_level,
                    'stream' => $cohort->stream,
                    'description' => $cohort->description,
                    'schedule' => $cohort->schedule ?? [],
                    'max_students' => (int) $cohort->max_students,
                    'enrolled_count' => (int) $cohort->enrolled_count,
                    'available_seats' => max(0, (int) $cohort->max_students - (int) $cohort->enrolled_count),
                    'live_sessions_price' => (float) ($cohort->live_sessions_price > 0 ? $cohort->live_sessions_price : $cohort->monthly_price),
                    'library_price' => $cohort->include_library ? (float) $cohort->library_price : 0.0,
                    'bundle_price' => (float) ($cohort->bundle_price > 0 ? $cohort->bundle_price : $cohort->monthly_price),
                    'include_library' => (bool) $cohort->include_library,
                    'included_sessions_count' => (int) ($cohort->included_sessions_count ?? 8),
                    'extra_sessions_count' => (int) ($cohort->extra_sessions_count ?? 0),
                    'extra_sessions_is_paid' => (bool) ($cohort->extra_sessions_is_paid ?? false),
                    'extra_session_price_dzd' => (float) ($cohort->extra_session_price_dzd ?? 0.0),
                    'upcoming_sessions_preview' => $upcomingPreviewSessions,
                    'access_restricted' => [
                        'chat_hidden' => true,
                        'live_stream_hidden' => true,
                        'members_list_hidden' => true,
                    ],
                ],
                'teacher' => $teacher ? [
                    'id' => $teacher->id,
                    'teacher_id' => $teacher->teacher_id,
                    'name' => $teacher->name,
                    'is_verified' => (bool) $teacher->is_verified,
                    'wilaya' => $teacher->wilaya,
                    'wilaya_ar' => $wilayaInfo['arabic'] ?? 'الجزائر',
                    'headline' => $platform?->headline ?? 'أستاذ معتمد في منصة Pindo Future',
                    'bio' => $platform?->bio ?? '',
                    'years_of_experience' => $settings['years_of_experience'] ?? 0,
                    'avatar_url' => $settings['avatar_url'] ?? null,
                    'teaching_levels' => $teacher->teaching_levels ?? [],
                    'teaching_years' => $teacher->teaching_years ?? [],
                    'teaching_subjects' => $teacher->teaching_subjects ?? [],
                    'student_achievements' => $settings['student_achievements'] ?? [],
                    'workplaces' => $settings['workplaces'] ?? [],
                ] : null,
            ],
        ]);
    }

    /**
     * Submit real BaridiMob/CCP payment receipt for a cohort subscription (Pending verification).
     * Strictly requires a valid uploaded receipt image/PDF stored to disk + SHA256 hash.
     * Does NOT activate enrollment or live/chat access until reviewed & approved by admin.
     */
    public function subscribeWithReceipt(int $id, Request $request): JsonResponse
    {
        $student = $request->user();

        if ($student->role !== 'student') {
            return response()->json([
                'status' => 'error',
                'message' => 'فقط حسابات التلاميذ يمكنها إرسال طلبات الاشتراك في الأفواج',
            ], 403);
        }

        $cohort = StudyCohort::where('is_active', true)->findOrFail($id);

        $validated = $request->validate([
            'receipt' => ['required', 'file', 'mimes:jpg,jpeg,png,webp,pdf', 'max:8192'],
            'payment_method' => ['required', 'string', Rule::in(['BaridiMob', 'CCP', 'CIB', 'Edahabia'])],
            'package_type' => ['nullable', 'string', Rule::in([
                StudyCohort::PACKAGE_LIVE_ONLY,
                StudyCohort::PACKAGE_LIBRARY_ONLY,
                StudyCohort::PACKAGE_FULL_BUNDLE,
            ])],
            'tx_reference' => ['nullable', 'string', 'max:100'],
            'notes' => ['nullable', 'string', 'max:500'],
        ]);

        $packageType = $validated['package_type'] ?? StudyCohort::PACKAGE_FULL_BUNDLE;
        if ($packageType === StudyCohort::PACKAGE_LIBRARY_ONLY && ! $cohort->include_library) {
            return response()->json([
                'status' => 'error',
                'message' => 'المكتبة الرقمية غير متاحة في هذا الفوج',
            ], 422);
        }

        $existingMembership = CohortMember::where('cohort_id', $cohort->id)
            ->where('student_id', $student->id)
            ->first();

        if ($cohort->isFull() && (! $existingMembership || $existingMembership->status !== 'active')) {
            return response()->json([
                'status' => 'error',
                'message' => 'عذراً، هذا الفوج ممتلئ حالياً',
            ], 422);
        }

        $file = $request->file('receipt');
        if (! $file || ! $file->isValid() || $file->getSize() <= 0) {
            return response()->json([
                'status' => 'error',
                'message' => 'ملف الوصل المرفق فارغ أو غير صالح. يرجى إعادة اختيار صورة واضحة.',
            ], 422);
        }

        $storedPath = Storage::disk('public')->putFile('receipts', $file);
        if (! $storedPath || ! Storage::disk('public')->exists($storedPath)) {
            return response()->json([
                'status' => 'error',
                'message' => 'تعذر حفظ صورة الوصل على الخادم. يرجى المحاولة مجدداً.',
            ], 500);
        }

        $receiptHash = hash_file('sha256', $file->getRealPath());
        $pricing = $cohort->resolvePackagePricing($packageType);

        $order = DB::transaction(function () use ($cohort, $student, $pricing, $validated, $storedPath, $receiptHash, $existingMembership) {
            $order = Order::create([
                'user_id' => $student->id,
                'cohort_id' => $cohort->id,
                'package_type' => $pricing['package_type'],
                'amount' => $pricing['gross_amount'],
                'currency' => 'DZD',
                'status' => Order::STATUS_PENDING,
                'payment_method' => $validated['payment_method'],
                'receipt_image_path' => $storedPath,
                'receipt_hash' => $receiptHash,
                'tx_reference' => ! empty($validated['tx_reference']) ? trim($validated['tx_reference']) : null,
                'payment_metadata' => [
                    'original_filename' => request()->file('receipt')?->getClientOriginalName(),
                    'mime_type' => request()->file('receipt')?->getClientMimeType(),
                    'size_bytes' => request()->file('receipt')?->getSize(),
                    'notes' => $validated['notes'] ?? null,
                    'is_renewal' => (bool) ($existingMembership && $existingMembership->status === 'active'),
                ],
            ]);

            if (! $existingMembership) {
                $includedQuota = max(1, (int) ($cohort->included_sessions_count ?? 8));
                CohortMember::create([
                    'cohort_id' => $cohort->id,
                    'student_id' => $student->id,
                    'status' => 'pending',
                    'package_type' => $pricing['package_type'],
                    'price_paid_dzd' => $pricing['gross_amount'],
                    'live_access' => false,
                    'library_access' => false,
                    'sessions_quota' => $includedQuota,
                    'sessions_attended' => 0,
                    'first_session_number' => 1,
                    'last_session_number' => $includedQuota,
                ]);
            }

            AppNotification::create([
                'user_id' => $student->id,
                'type' => 'subscription_pending',
                'title' => 'تم استلام وصل الدفع وهو قيد المراجعة',
                'body' => "تم استلام وصل الاشتراك ({$order->order_number}) لفوج \"{$cohort->name}\" بمبلغ {$pricing['gross_amount']} دج. سيتم التفعيل فور تأكيد الوصل.",
                'data' => [
                    'order_id' => $order->id,
                    'order_number' => $order->order_number,
                    'cohort_id' => $cohort->id,
                ],
            ]);

            if ($cohort->teacher_id) {
                AppNotification::create([
                    'user_id' => $cohort->teacher_id,
                    'type' => 'cohort_receipt_submitted',
                    'title' => 'طلب اشتراك جديد بانتظار المصادقة',
                    'body' => "أرسل التلميذ {$student->name} وصل دفع ({$validated['payment_method']}) للانضمام إلى فوج \"{$cohort->name}\".",
                    'data' => [
                        'order_id' => $order->id,
                        'cohort_id' => $cohort->id,
                    ],
                ]);
            }

            return $order;
        });

        $cache = app(CacheManagerService::class);
        $cache->invalidateStudent($student->id);
        $cache->invalidateTeacher($cohort->teacher_id);

        return response()->json([
            'status' => 'success',
            'message' => 'تم رفع الوصل بنجاح وإرسال الطلب إلى لوحة التحقق. سيتم التفعيل فور المصادقة.',
            'data' => [
                'order_id' => $order->id,
                'order_number' => $order->order_number,
                'receipt_number' => $order->receipt_number,
                'status' => $order->status,
                'amount' => (float) $order->amount,
                'payment_method' => $order->payment_method,
                'package_type' => $order->package_type,
                'receipt_image_url' => asset('storage/' . $order->receipt_image_path),
            ],
        ], 201);
    }
}
