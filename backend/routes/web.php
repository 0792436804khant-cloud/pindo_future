<?php

use App\Http\Controllers\Web\AdminPanelController;
use Illuminate\Support\Facades\Route;

// Root redirect
Route::get('/', function () {
    return redirect()->route('admin.login');
});

// Admin Web Authentication
Route::prefix('admin')->group(function () {
    Route::get('/login', [AdminPanelController::class, 'loginView'])->name('admin.login');
    Route::post('/login', [AdminPanelController::class, 'loginSubmit'])->name('admin.login.submit');
    Route::post('/logout', [AdminPanelController::class, 'logout'])->name('admin.logout');

    // Secure Admin Operations Portal
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
