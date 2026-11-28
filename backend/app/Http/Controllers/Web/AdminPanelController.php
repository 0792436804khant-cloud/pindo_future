<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use App\Models\ClassroomAttendance;
use App\Models\ClassroomSession;
use App\Models\CohortMember;
use App\Models\Course;
use App\Models\Enrollment;
use App\Models\Order;
use App\Models\Role;
use App\Models\StudyCohort;
use App\Models\TeacherEarning;
use App\Models\TeacherPayout;
use App\Models\User;
use App\Services\BilingualTaxonomyService;
use App\Services\CacheManagerService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class AdminPanelController extends Controller
{
    /**
     * Display the Admin Login Portal.
     */
    public function loginView(): View|RedirectResponse
    {
        if (Auth::check() && Auth::user()->role === Role::ADMIN) {
            return redirect()->route('admin.dashboard');
        }

        return view('admin.login');
    }

    /**
     * Process Admin Authentication.
     */
    public function loginSubmit(Request $request): RedirectResponse
    {
        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $credentials['email'])->first();

        if (!$user || !Hash::check($credentials['password'], $user->password)) {
            return back()->withErrors(['email' => 'بيانات الدخول غير صحيحة'])->withInput();
        }

        if ($user->role !== Role::ADMIN) {
            return back()->withErrors(['email' => 'هذا الحساب غير مصرح له بالدخول إلى لوحة التحكم الإدارية'])->withInput();
        }

        Auth::login($user, $request->boolean('remember'));
        $request->session()->regenerate();

        return redirect()->intended(route('admin.dashboard'));
    }

    /**
     * Admin Session Logout.
     */
    public function logout(Request $request): RedirectResponse
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('admin.login');
    }

    /**
     * Display the Real-Time Panoramic Admin Command Center.
     */
    public function dashboardView(): View|RedirectResponse
    {
        if (!Auth::check() || Auth::user()->role !== Role::ADMIN) {
            return redirect()->route('admin.login');
        }

        return view('admin.dashboard', [
            'adminUser' => Auth::user(),
        ]);
    }

    /**
     * Live Polling Telemetry Payload for Operations Room (3-5s Polling).
     */
    public function telemetry(Request $request): JsonResponse
    {
        // 1. System Health Telemetry
        $dbConnected = true;
        try {
            DB::connection()->getPdo();
        } catch (\Throwable $e) {
            $dbConnected = false;
        }

        $storageLinkActive = File::exists(public_path('storage'));
        $isHttps = $request->isSecure() || $request->header('x-forwarded-proto') === 'https';

        // 2. High-Level Metrics
        $totalStudents = User::where('role', 'student')->count();
        $totalTeachers = User::where('role', 'teacher')->count();
        $verifiedTeachers = User::where('role', 'teacher')->where('is_verified', true)->count();
        $pendingTeachersCount = User::where('role', 'teacher')->where('verification_status', 'pending')->count();
        $activeSessionsCount = ClassroomSession::where('status', ClassroomSession::STATUS_ACTIVE)->count();
        $totalCohorts = StudyCohort::count();

        // 3. Financial Metrics (With Live Sessions vs Digital Library Split)
        $grossRevenue = (float) TeacherEarning::sum('gross_amount');
        $liveGrossRevenue = (float) TeacherEarning::sum('live_gross_amount');
        $libraryGrossRevenue = (float) TeacherEarning::sum('library_gross_amount');
        $livePlatformFee = (float) TeacherEarning::sum('live_platform_fee');
        $libraryPlatformFee = (float) TeacherEarning::sum('library_platform_fee');
        $platformFee = (float) TeacherEarning::sum('platform_fee');
        $teacherNet = (float) TeacherEarning::sum('net_amount');

        $pendingSubscriptionsQuery = Order::where('status', Order::STATUS_PENDING);
        $pendingSubscriptionsCount = $pendingSubscriptionsQuery->count();
        $pendingSubscriptionsSum = (float) $pendingSubscriptionsQuery->sum('amount');

        // 4. Pending Teacher KYC Applications
        $pendingTeachers = User::where('role', 'teacher')
            ->where('verification_status', 'pending')
            ->orderByDesc('created_at')
            ->limit(15)
            ->get()
            ->map(function ($teacher) {
                $wilayaInfo = BilingualTaxonomyService::resolveWilaya($teacher->wilaya ?? 16);
                return [
                    'id' => $teacher->id,
                    'name' => $teacher->name,
                    'email' => $teacher->email,
                    'phone' => $teacher->phone,
                    'teacher_id' => $teacher->teacher_id ?? 'TCH_' . $teacher->id,
                    'wilaya_ar' => $wilayaInfo['arabic'] ?? 'الجزائر العاصمة',
                    'wilaya_fr' => $wilayaInfo['french'] ?? 'Alger',
                    'academic_phase' => $teacher->academic_level ?? 'التعليم الثانوي (Lycée)',
                    'subjects' => is_array($teacher->teaching_subjects) ? implode(', ', $teacher->teaching_subjects) : ($teacher->teaching_subjects ?? 'غير محددة'),
                    'document_url' => $teacher->diploma_preview_url ?: ($teacher->national_id_or_diploma ? asset('storage/' . $teacher->national_id_or_diploma) : null),
                    'created_at_human' => $teacher->created_at?->diffForHumans() ?? 'الآن',
                ];
            });

        // 5. Pending BaridiMob Subscriptions (With Idempotency & Fraud Alerts)
        $pendingSubscriptions = Order::where('status', Order::STATUS_PENDING)
            ->with(['user', 'course', 'cohort'])
            ->orderByDesc('created_at')
            ->limit(15)
            ->get()
            ->map(function ($order) {
                // Fraud Check: Check if receipt hash was submitted elsewhere
                $isDuplicate = false;
                if (!empty($order->receipt_hash)) {
                    $isDuplicate = Order::where('receipt_hash', $order->receipt_hash)
                        ->where('id', '!=', $order->id)
                        ->exists();
                }

                return [
                    'id' => $order->id,
                    'order_number' => $order->order_number,
                    'student_name' => $order->user?->name ?? 'طالب',
                    'student_email' => $order->user?->email ?? '-',
                    'student_phone' => $order->user?->phone,
                    'course_title' => $order->cohort?->name ?? $order->course?->title ?? 'باقة الاشتراك',
                    'package_type' => $order->package_type,
                    'amount' => (float) $order->amount,
                    'currency' => $order->currency,
                    'payment_method' => $order->payment_method ?? 'BaridiMob',
                    'tx_reference' => $order->tx_reference ?? ('BM_' . substr($order->order_number, -6)),
                    'receipt_image' => $order->receipt_image_path ? asset('storage/' . $order->receipt_image_path) : null,
                    'is_fraud_suspect' => $isDuplicate,
                    'submitted_at_human' => $order->created_at?->diffForHumans() ?? 'الآن',
                ];
            });

        // 6. Active Live Classroom Rooms (SFU Telemetry)
        $activeSessions = ClassroomSession::where('status', ClassroomSession::STATUS_ACTIVE)
            ->with(['teacher', 'cohort'])
            ->orderByDesc('created_at')
            ->limit(10)
            ->get()
            ->map(function ($session) {
                $liveCount = ClassroomAttendance::where('session_id', $session->session_id)
                    ->whereNull('left_at')
                    ->count();

                return [
                    'id' => $session->id,
                    'session_uuid' => $session->session_id ?? ('SES_' . $session->id),
                    'teacher_name' => $session->teacher?->name ?? 'الأستاذ',
                    'title' => $session->title ?? 'حصة تقوية مباشرة',
                    'subject' => $session->cohort?->subject ?? 'عام',
                    'student_count' => $liveCount,
                    'duration_minutes' => $session->started_at ? $session->started_at->diffInMinutes(now()) : ($session->created_at ? $session->created_at->diffInMinutes(now()) : 0),
                    'drm_protected' => true,
                ];
            });

        $queueOperational = true;
        if (config('queue.default') === 'redis') {
            try {
                \Illuminate\Support\Facades\Redis::connection()->ping();
            } catch (\Throwable $e) {
                $queueOperational = false;
            }
        }

        return response()->json([
            'status' => 'success',
            'timestamp' => now()->toIso8601String(),
            'server_time' => now()->format('Y-m-d H:i:s'),
            'health' => [
                'database' => $dbConnected ? 'OPERATIONAL' : 'DEGRADED',
                'https_secured' => $isHttps,
                'storage_symlink' => $storageLinkActive ? 'ACTIVE' : 'BROKEN',
                'queue_worker' => $queueOperational ? 'ACTIVE' : 'DEGRADED',
            ],
            'kpis' => [
                'total_students' => $totalStudents,
                'total_teachers' => $totalTeachers,
                'verified_teachers' => $verifiedTeachers,
                'pending_teachers_count' => $pendingTeachersCount,
                'active_sessions_count' => $activeSessionsCount,
                'total_cohorts' => $totalCohorts,
                'gross_revenue' => $grossRevenue,
                'live_gross_revenue' => $liveGrossRevenue,
                'library_gross_revenue' => $libraryGrossRevenue,
                'live_platform_fee' => $livePlatformFee,
                'library_platform_fee' => $libraryPlatformFee,
                'platform_fee' => $platformFee,
                'teacher_net' => $teacherNet,
                'pending_subscriptions_count' => $pendingSubscriptionsCount,
                'pending_subscriptions_sum' => $pendingSubscriptionsSum,
            ],
            'pending_teachers' => $pendingTeachers,
            'pending_subscriptions' => $pendingSubscriptions,
            'active_sessions' => $activeSessions,
        ]);
    }

    /**
     * 1-Click Approve Teacher KYC Application.
     */
    public function approveTeacher(int $id): JsonResponse
    {
        $teacher = User::where('role', Role::TEACHER)->findOrFail($id);

        $teacher->update([
            'is_verified' => true,
            'verification_status' => 'verified',
            'verified_at' => now(),
            'rejection_reason' => null,
        ]);

        // Send instant in-app notification to teacher
        AppNotification::create([
            'user_id' => $teacher->id,
            'title' => '🎉 تهانينا! تم توثيق حسابك كأستاذ رسمي معتمد',
            'body' => 'قامت إدارة منصة بيندو فيوتشر بمراجعة شهاداتك واعتماد حسابك. شارة التوثيق الزرقاء مفعلة الآن ويمكنك إطلاق الأفواج والحصص المباشرة.',
            'type' => 'teacher_verified',
            'is_read' => false,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم توثيق الأستاذ بنجاح ومنحه شارة الاعتماد الرسمية.',
        ]);
    }

    /**
     * Reject Teacher KYC Application with Structured Reason.
     */
    public function rejectTeacher(int $id, Request $request): JsonResponse
    {
        $request->validate([
            'reason' => 'required|string|min:5',
        ]);

        $teacher = User::where('role', Role::TEACHER)->findOrFail($id);

        $reason = $request->input('reason');

        $teacher->update([
            'is_verified' => false,
            'verification_status' => 'rejected',
            'rejection_reason' => $reason,
        ]);

        // Dispatch instant alert to teacher with instructions for resolution
        AppNotification::create([
            'user_id' => $teacher->id,
            'title' => '⚠️ تنبيه من إدارة المنصة حول ملف التوثيق',
            'body' => "طلب التوثيق يحتاج إلى تصحيح للأسباب التالية: {$reason}. يرجى تحديث الوثائق المطلوبة لإعادة التفعيل الفوري.",
            'type' => 'teacher_verification_rejected',
            'is_read' => false,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم رفض الملف وإشعار الأستاذ بالسبب لتصحيحه فوراً.',
        ]);
    }

    /**
     * 1-Click Approve BaridiMob Subscription Receipt with Atomic Concurrency.
     */
    public function approveSubscription(int $id): JsonResponse
    {
        return DB::transaction(function () use ($id) {
            $order = Order::where('status', Order::STATUS_PENDING)->lockForUpdate()->findOrFail($id);

            // 1. Mark Order as Completed
            $endsAt = now()->addDays(30);
            $order->update([
                'status' => Order::STATUS_COMPLETED,
                'paid_at' => now(),
                'subscription_ends_at' => $endsAt,
            ]);

            // 2. Activate or Create Course Enrollment
            if ($order->course_id) {
                Enrollment::updateOrCreate(
                    [
                        'user_id' => $order->user_id,
                        'course_id' => $order->course_id,
                    ],
                    [
                        'status' => Enrollment::STATUS_ACTIVE,
                        'enrolled_at' => now(),
                        'ends_at' => $endsAt,
                    ]
                );
            }

            // 2b. Activate or Renew Study Cohort Membership & Session Quota
            $teacherId = $order->course?->teacher_id;
            if ($order->cohort_id) {
                $cohort = StudyCohort::find($order->cohort_id);
                if ($cohort) {
                    $pricing = $cohort->resolvePackagePricing($order->package_type ?? StudyCohort::PACKAGE_FULL_BUNDLE);
                    $cycleSessions = max(1, (int) ($cohort->included_sessions_count ?? 8));
                    $existingMember = CohortMember::where('cohort_id', $cohort->id)
                        ->where('student_id', $order->user_id)
                        ->first();

                    if ($existingMember && $existingMember->status === 'active') {
                        $prevQuota = max(0, (int) ($existingMember->sessions_quota ?? 0));
                        $newTotalQuota = $prevQuota + $cycleSessions;
                        $existingMember->update([
                            'status' => 'active',
                            'package_type' => $pricing['package_type'],
                            'price_paid_dzd' => $pricing['gross_amount'],
                            'live_access' => $pricing['live_access'] || $existingMember->live_access,
                            'library_access' => $pricing['library_access'] || $existingMember->library_access,
                            'sessions_quota' => $newTotalQuota,
                            'first_session_number' => $prevQuota + 1,
                            'last_session_number' => $newTotalQuota,
                            'ends_at' => $endsAt,
                        ]);
                    } else {
                        CohortMember::updateOrCreate(
                            [
                                'cohort_id' => $cohort->id,
                                'student_id' => $order->user_id,
                            ],
                            [
                                'status' => 'active',
                                'package_type' => $pricing['package_type'],
                                'price_paid_dzd' => $pricing['gross_amount'],
                                'live_access' => $pricing['live_access'],
                                'library_access' => $pricing['library_access'],
                                'sessions_quota' => $cycleSessions,
                                'sessions_attended' => 0,
                                'first_session_number' => 1,
                                'last_session_number' => $cycleSessions,
                                'joined_at' => now(),
                                'ends_at' => $endsAt,
                            ]
                        );
                    }

                    $cohort->recalculateEnrolledCount();
                    $teacherId = $cohort->teacher_id;

                    TeacherEarning::create([
                        'teacher_id' => $teacherId,
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
            } elseif ($teacherId) {
                // 3. Fallback: Credit Teacher Earnings for direct courses (80% net, 20% platform)
                $gross = (float) $order->amount;
                $fee = round($gross * 0.20, 2);
                $net = $gross - $fee;

                TeacherEarning::create([
                    'teacher_id' => $teacherId,
                    'order_id' => $order->id,
                    'course_id' => $order->course_id,
                    'gross_amount' => $gross,
                    'platform_fee' => $fee,
                    'net_amount' => $net,
                    'status' => TeacherEarning::STATUS_AVAILABLE,
                ]);
            }

            // 4. Dispatch In-App Notification to Student
            AppNotification::create([
                'user_id' => $order->user_id,
                'title' => '✅ تم تأكيد اشتراكك وتفعيل حسابك بنجاح',
                'body' => "تم التحقق من وصل الدفع للطلب {$order->order_number}. اشتراكك سارٍ ومفعل حتى " . $endsAt->format('Y-m-d') . '.',
                'type' => 'subscription_activated',
                'is_read' => false,
            ]);

            $cache = app(CacheManagerService::class);
            $cache->invalidateStudent($order->user_id);
            if ($teacherId) {
                $cache->invalidateTeacher($teacherId);
            }

            return response()->json([
                'status' => 'success',
                'message' => 'تم تأكيد وصل الدفع وتفعيل اشتراك التلميذ بنجاح.',
            ]);
        });
    }

    /**
     * Reject BaridiMob Subscription Receipt with Reason.
     */
    public function rejectSubscription(int $id, Request $request): JsonResponse
    {
        $request->validate([
            'reason' => 'required|string|min:5',
        ]);

        $order = Order::findOrFail($id);
        $reason = $request->input('reason');

        $order->update([
            'status' => Order::STATUS_FAILED,
            'rejection_reason' => $reason,
        ]);

        // Send alert to student
        AppNotification::create([
            'user_id' => $order->user_id,
            'title' => '❌ تعذر تأكيد وصل الدفع المرفوع',
            'body' => "سبب الرفض: {$reason}. يرجى إعادة رفع وصل واضح أو التأكد من إدخال رقم العملية الصحيح.",
            'type' => 'payment_rejected',
            'is_read' => false,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم رفض الوصل وإرسال التنبيه إلى الطالب.',
        ]);
    }

    /**
     * Emergency Kill-Switch for Live SFU Classroom Session.
     */
    public function terminateSession(int $id): JsonResponse
    {
        $session = ClassroomSession::findOrFail($id);

        $session->update([
            'status' => ClassroomSession::STATUS_ENDED,
            'ended_at' => now(),
        ]);

        Log::warning("Live classroom session {$id} was terminated immediately by Administrator via Kill-Switch.");

        return response()->json([
            'status' => 'success',
            'message' => 'تم إيقاف الحصة المباشرة فوراً وقطع البث عبر زر الطوارئ.',
        ]);
    }
}
