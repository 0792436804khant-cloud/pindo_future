<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\ExamPaper;
use App\Models\Role;
use App\Models\StudyCohort;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\View\View;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class SiteWebController extends Controller
{
    /**
     * Official Pindo Future Public Website (SiteWeb).
     * Core Theme: "مستقبل التعليم في الجزائر | Future Generation of Education DZ".
     */
    public function home(): View
    {
        $dbOnline = true;
        try {
            DB::connection()->getPdo();
        } catch (\Throwable $e) {
            $dbOnline = false;
        }

        $examPapers = collect();
        $activeCohortsCount = 0;
        $verifiedTeachersCount = 0;
        $totalExamsCount = 0;

        if ($dbOnline) {
            try {
                $examPapers = ExamPaper::where('is_published', true)
                    ->orderByDesc('year')
                    ->limit(6)
                    ->get(['id', 'exam_code', 'title', 'cycle', 'stream', 'subject_name_ar', 'year', 'duration_minutes', 'coefficient']);
                $totalExamsCount = ExamPaper::where('is_published', true)->count();
                $activeCohortsCount = StudyCohort::where('is_active', true)->count();
                $verifiedTeachersCount = User::where('role', Role::TEACHER)
                    ->where('is_verified', true)
                    ->count();
            } catch (\Throwable $e) {
                // Keep defaults cleanly if schema is initializing
            }
        }

        $apkPath = storage_path('app/public/downloads/pindo-future.apk');
        $apkAvailable = File::exists($apkPath);
        $apkSizeMb = $apkAvailable ? round(File::size($apkPath) / (1024 * 1024), 1) : 101.0;

        return view('site.home', [
            'dbOnline' => $dbOnline,
            'examPapers' => $examPapers,
            'totalExamsCount' => $totalExamsCount,
            'activeCohortsCount' => $activeCohortsCount,
            'verifiedTeachersCount' => $verifiedTeachersCount,
            'apkAvailable' => $apkAvailable,
            'apkSizeMb' => $apkSizeMb,
        ]);
    }

    /**
     * Public Teacher Showcase Deep-Link Landing Page (/teacher/{teacherId}).
     */
    public function teacherShowcase(string $teacherId): View
    {
        $teacher = User::where('role', Role::TEACHER)
            ->where('teacher_id', $teacherId)
            ->with(['teacherPlatform'])
            ->first();

        $cohorts = $teacher
            ? StudyCohort::where('teacher_id', $teacher->id)
                ->where('is_active', true)
                ->orderByDesc('created_at')
                ->get()
            : collect();

        return view('site.teacher', [
            'teacher' => $teacher,
            'teacherId' => $teacherId,
            'cohorts' => $cohorts,
        ]);
    }

    /**
     * Apple App Store & Google Play Compliant Privacy Policy Page.
     */
    public function privacy(): View
    {
        return view('site.privacy');
    }

    /**
     * Direct Signed Android APK Download Endpoint.
     */
    public function downloadAndroid(): BinaryFileResponse|RedirectResponse
    {
        $apkPath = storage_path('app/public/downloads/pindo-future.apk');

        if (!File::exists($apkPath)) {
            return redirect('/#download')->with('download_notice', 'حزمة الأندرويد قيد التجهيز على الخادم، يمكنك استخدام نسخة الويب المباشرة الآن.');
        }

        return response()->download($apkPath, 'PindoFuture-v1.0.apk', [
            'Content-Type' => 'application/vnd.android.package-archive',
        ]);
    }
}
