<?php

use App\Http\Controllers\Web\AdminPanelController;
use App\Http\Controllers\Web\SiteWebController;
use Illuminate\Support\Facades\Route;

// Official Pindo Future Marketing & Product Website ("مستقبل التعليم في الجزائر | Future Generation of Education DZ")
Route::get('/', [SiteWebController::class, 'home'])->name('site.home');
Route::get('/privacy', [SiteWebController::class, 'privacy'])->name('site.privacy');
Route::get('/teacher/{teacherId}', [SiteWebController::class, 'teacherShowcase'])->name('site.teacher');
Route::get('/download/android', [SiteWebController::class, 'downloadAndroid'])->name('site.download.android');

// Omnichannel Flutter Web PWA Application (/app/)
Route::get('/app', function () {
    return redirect('/app/');
});

Route::get('/app/', function () {
    $flutterEntry = public_path('app/index.html');
    if (file_exists($flutterEntry)) {
        return response()->file($flutterEntry, [
            'Content-Type' => 'text/html; charset=UTF-8',
            'Cache-Control' => 'no-cache, must-revalidate',
        ]);
    }

    return redirect()->route('site.home');
})->name('app.home');

// Admin Web Authentication
Route::prefix('admin')->group(function () {
    Route::get('/login', [AdminPanelController::class, 'loginView'])->name('admin.login');
    Route::post('/login', [AdminPanelController::class, 'loginSubmit'])->name('admin.login.submit');
    Route::post('/logout', [AdminPanelController::class, 'logout'])->name('admin.logout');

    // Secure Admin Operations Portal (Protected by admin.web session middleware)
    Route::middleware(['admin.web'])->group(function () {
        Route::get('/', function () {
            return redirect()->route('admin.dashboard');
        });

        Route::get('/dashboard', [AdminPanelController::class, 'dashboardView'])->name('admin.dashboard');

        // Live Operations Real-Time Telemetry & Dispatch API (Polled every 3-5 seconds)
        Route::prefix('api')->group(function () {
            Route::get('/telemetry', [AdminPanelController::class, 'telemetry'])->name('admin.api.telemetry');
            Route::post('/teachers/{id}/approve', [AdminPanelController::class, 'approveTeacher'])->name('admin.api.teachers.approve');
            Route::post('/teachers/{id}/reject', [AdminPanelController::class, 'rejectTeacher'])->name('admin.api.teachers.reject');
            Route::post('/subscriptions/{id}/approve', [AdminPanelController::class, 'approveSubscription'])->name('admin.api.subscriptions.approve');
            Route::post('/subscriptions/{id}/reject', [AdminPanelController::class, 'rejectSubscription'])->name('admin.api.subscriptions.reject');
            Route::post('/sessions/{id}/terminate', [AdminPanelController::class, 'terminateSession'])->name('admin.api.sessions.terminate');
        });
    });
});
