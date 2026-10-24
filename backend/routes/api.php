<?php

use App\Http\Controllers\Api\Admin\TeacherVerificationAdminController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CheckoutController;
use App\Http\Controllers\Api\ClassroomSessionController;
use App\Http\Controllers\Api\HealthController;
use App\Http\Controllers\Api\ParentOversightController;
use App\Http\Controllers\Api\PublicCourseController;
use App\Http\Controllers\Api\Student\CohortEnrollmentController;
use App\Http\Controllers\Api\Teacher\CohortController;
use App\Http\Controllers\Api\Teacher\PlatformController;
use App\Http\Controllers\Api\Teacher\SessionController;
use App\Http\Controllers\Api\Teacher\TeacherCourseController;
use App\Http\Controllers\Api\Teacher\TeacherEarningsController;
use App\Http\Controllers\Api\Teacher\VerificationController;
use App\Http\Controllers\Api\ExamBankController;
use App\Http\Controllers\Api\TeacherPublicController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Pindo Future API Routes (v1)
|--------------------------------------------------------------------------
|
| All routes here are automatically prefixed with /api/v1 as defined
| in bootstrap/app.php.
|
*/

// Diagnostics & Liveness
Route::get('/health', [HealthController::class, 'check'])->name('api.v1.health');
Route::get('/ping', fn () => response()->json(['message' => 'pong', 'timestamp' => now()->toIso8601String()]));

// Authentication & Role-Based Access Control
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register'])->name('api.v1.auth.register');
    Route::post('/login', [AuthController::class, 'login'])->name('api.v1.auth.login');

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/me', [AuthController::class, 'me'])->name('api.v1.auth.me');
        Route::post('/logout', [AuthController::class, 'logout'])->name('api.v1.auth.logout');
        Route::delete('/account', [AuthController::class, 'deleteAccount'])->name('api.v1.auth.account.delete');
    });
});

// Apple App Store Guideline 1.2 UGC Safety & Moderation
Route::middleware('auth:sanctum')->prefix('compliance')->group(function () {
    Route::post('/report', [\App\Http\Controllers\Api\ComplianceController::class, 'report'])->name('api.v1.compliance.report');
});

// Phase 2: Classroom Sessions & LiveKit WebRTC SFU Tokens
Route::get('/sessions/{sessionId}', [ClassroomSessionController::class, 'lookup'])->name('api.v1.sessions.lookup');
Route::post('/sessions/{sessionId}/token', [\App\Http\Controllers\Api\SessionTokenController::class, 'generate'])
    ->middleware('throttle:60,1')
    ->name('api.v1.sessions.token.generate');
Route::post('/sessions/{sessionId}/token/verify', [\App\Http\Controllers\Api\SessionTokenController::class, 'verify'])->name('api.v1.sessions.token.verify');

// Phase 2: Teacher Platform & Dynamic Session Management (Protected: auth + teacher)
Route::middleware(['auth:sanctum', 'teacher'])->prefix('teacher')->group(function () {
    // Platform Profile & Deep Link Management
    Route::get('/platform', [PlatformController::class, 'show'])->name('api.v1.teacher.platform.show');
    Route::put('/platform', [PlatformController::class, 'update'])->name('api.v1.teacher.platform.update');

    // Dynamic Classroom Sessions Management
    Route::get('/sessions', [SessionController::class, 'index'])->name('api.v1.teacher.sessions.index');
    Route::post('/sessions', [SessionController::class, 'store'])->name('api.v1.teacher.sessions.store');
    Route::get('/sessions/{sessionId}', [SessionController::class, 'show'])->name('api.v1.teacher.sessions.show');
    Route::post('/sessions/{sessionId}/start', [SessionController::class, 'start'])->name('api.v1.teacher.sessions.start');
    Route::post('/sessions/{sessionId}/end', [SessionController::class, 'end'])->name('api.v1.teacher.sessions.end');

    // Phase 1: Study Cohorts & Groups Engine (Independent Teacher Space)
    Route::get('/cohorts', [CohortController::class, 'index'])->name('api.v1.teacher.cohorts.index');
    Route::post('/cohorts', [CohortController::class, 'store'])->name('api.v1.teacher.cohorts.store');
    Route::get('/cohorts/{id}', [CohortController::class, 'show'])->name('api.v1.teacher.cohorts.show');
    Route::put('/cohorts/{id}', [CohortController::class, 'update'])->name('api.v1.teacher.cohorts.update');
    Route::delete('/cohorts/{id}', [CohortController::class, 'destroy'])->name('api.v1.teacher.cohorts.destroy');
    Route::get('/cohorts/{id}/members', [CohortController::class, 'members'])->name('api.v1.teacher.cohorts.members');
    Route::post('/cohorts/{id}/members', [CohortController::class, 'addMember'])->name('api.v1.teacher.cohorts.members.add');
    Route::delete('/cohorts/{id}/members/{studentId}', [CohortController::class, 'removeMember'])->name('api.v1.teacher.cohorts.members.remove');
    Route::post('/cohorts/{id}/sessions', [CohortController::class, 'createSession'])->name('api.v1.teacher.cohorts.sessions.store');

    // Phase 3: Protected Educational Media & Recording Library
    Route::get('/cohorts/{id}/recordings', [\App\Http\Controllers\Api\Teacher\LibraryController::class, 'getRecordings'])->name('api.v1.teacher.cohorts.recordings.index');
    Route::post('/cohorts/{id}/recordings', [\App\Http\Controllers\Api\Teacher\LibraryController::class, 'publishRecording'])->name('api.v1.teacher.cohorts.recordings.store');
    Route::delete('/recordings/{id}', [\App\Http\Controllers\Api\Teacher\LibraryController::class, 'deleteRecording'])->name('api.v1.teacher.recordings.destroy');
    Route::get('/cohorts/{id}/materials', [\App\Http\Controllers\Api\Teacher\LibraryController::class, 'getMaterials'])->name('api.v1.teacher.cohorts.materials.index');
    Route::post('/cohorts/{id}/materials', [\App\Http\Controllers\Api\Teacher\LibraryController::class, 'storeMaterial'])->name('api.v1.teacher.cohorts.materials.store');
    Route::delete('/materials/{id}', [\App\Http\Controllers\Api\Teacher\LibraryController::class, 'deleteMaterial'])->name('api.v1.teacher.materials.destroy');

    // Teacher Accreditation & Verification Badge
    Route::get('/verification/status', [VerificationController::class, 'status'])->name('api.v1.teacher.verification.status');
    Route::post('/verification/request', [VerificationController::class, 'requestVerification'])->name('api.v1.teacher.verification.request');

    // Phase 5: Course & Curriculum Management
    Route::get('/courses', [TeacherCourseController::class, 'index'])->name('api.v1.teacher.courses.index');
    Route::post('/courses', [TeacherCourseController::class, 'store'])->name('api.v1.teacher.courses.store');
    Route::get('/courses/{id}', [TeacherCourseController::class, 'show'])->name('api.v1.teacher.courses.show');
    Route::put('/courses/{id}', [TeacherCourseController::class, 'update'])->name('api.v1.teacher.courses.update');
    Route::delete('/courses/{id}', [TeacherCourseController::class, 'destroy'])->name('api.v1.teacher.courses.destroy');
    Route::post('/courses/{id}/modules', [TeacherCourseController::class, 'storeModule'])->name('api.v1.teacher.courses.modules.store');
    Route::put('/modules/{moduleId}', [TeacherCourseController::class, 'updateModule'])->name('api.v1.teacher.modules.update');
    Route::delete('/modules/{moduleId}', [TeacherCourseController::class, 'destroyModule'])->name('api.v1.teacher.modules.destroy');
    Route::post('/modules/{moduleId}/lessons', [TeacherCourseController::class, 'storeLesson'])->name('api.v1.teacher.modules.lessons.store');
    Route::put('/lessons/{lessonId}', [TeacherCourseController::class, 'updateLesson'])->name('api.v1.teacher.lessons.update');
    Route::delete('/lessons/{lessonId}', [TeacherCourseController::class, 'destroyLesson'])->name('api.v1.teacher.lessons.destroy');
});

// Phase 4: Real-time In-Classroom Interactions (Chat & Attendance)
Route::middleware('auth:sanctum')->prefix('sessions/{sessionId}')->group(function () {
    Route::get('/messages', [\App\Http\Controllers\Api\ClassroomInteractionController::class, 'getMessages'])->name('api.v1.sessions.messages.index');
    Route::post('/messages', [\App\Http\Controllers\Api\ClassroomInteractionController::class, 'sendMessage'])->name('api.v1.sessions.messages.store');
    Route::post('/attendance/join', [\App\Http\Controllers\Api\ClassroomInteractionController::class, 'recordJoin'])->name('api.v1.sessions.attendance.join');
    Route::post('/attendance/leave', [\App\Http\Controllers\Api\ClassroomInteractionController::class, 'recordLeave'])->name('api.v1.sessions.attendance.leave');
});

// Phase 5: Public Teacher Showcase, Deep Links & Course Discovery
Route::get('/teachers', [TeacherPublicController::class, 'index'])->name('api.v1.teachers.index');
Route::get('/teachers/{teacherId}/public', [TeacherPublicController::class, 'show'])->name('api.v1.teachers.public');
Route::get('/courses', [PublicCourseController::class, 'index'])->name('api.v1.courses.index');
Route::get('/courses/{identifier}', [PublicCourseController::class, 'show'])->name('api.v1.courses.show');
Route::get('/cohorts', [CohortEnrollmentController::class, 'index'])->name('api.v1.cohorts.index');

// Phase 5: Student Course & Cohort Enrollment & Learning Progress (Protected: auth:sanctum)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/courses/{courseId}/enroll', [\App\Http\Controllers\Api\StudentEnrollmentController::class, 'enroll'])->name('api.v1.courses.enroll');
    Route::get('/student/courses', [\App\Http\Controllers\Api\StudentEnrollmentController::class, 'index'])->name('api.v1.student.courses.index');
    Route::post('/courses/{courseId}/progress', [\App\Http\Controllers\Api\StudentEnrollmentController::class, 'updateProgress'])->name('api.v1.courses.progress');

    // Phase 1: Student Study Cohorts
    Route::get('/student/cohorts', [CohortEnrollmentController::class, 'myCohorts'])->name('api.v1.student.cohorts.index');
    Route::post('/student/cohorts/{id}/join', [CohortEnrollmentController::class, 'join'])->name('api.v1.student.cohorts.join');
    Route::delete('/student/cohorts/{id}/leave', [CohortEnrollmentController::class, 'leave'])->name('api.v1.student.cohorts.leave');

    // Phase 3: Student Protected Library Access (Recordings & Materials)
    Route::get('/student/cohorts/{id}/library', [\App\Http\Controllers\Api\Student\CohortLibraryController::class, 'index'])->name('api.v1.student.cohorts.library.index');
    Route::get('/student/recordings/{id}/stream', [\App\Http\Controllers\Api\Student\CohortLibraryController::class, 'streamRecording'])->name('api.v1.student.recordings.stream');
    Route::get('/student/materials/{id}/access', [\App\Http\Controllers\Api\Student\CohortLibraryController::class, 'downloadMaterial'])->name('api.v1.student.materials.access');

    // Phase 6: Student Exam Simulation History
    Route::get('/student/exam-simulations', [ExamBankController::class, 'mySimulations'])->name('api.v1.student.simulations.index');
});

// Phase 6: Algerian National Exam Bank & Timed Simulations Engine (BEM & BAC)
Route::prefix('exams')->group(function () {
    Route::get('/', [ExamBankController::class, 'index'])->name('api.v1.exams.index');
    Route::get('/subjects', [ExamBankController::class, 'subjects'])->name('api.v1.exams.subjects');
    Route::get('/{id}', [ExamBankController::class, 'show'])->name('api.v1.exams.show');

    // Protected student mock simulation lifecycle
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/{id}/simulations/start', [ExamBankController::class, 'startSimulation'])->name('api.v1.exams.simulations.start');
        Route::put('/simulations/{simulationId}/progress', [ExamBankController::class, 'updateSimulationProgress'])->name('api.v1.exams.simulations.progress');
        Route::post('/simulations/{simulationId}/finish', [ExamBankController::class, 'finishSimulation'])->name('api.v1.exams.simulations.finish');
    });
});

// Phase 6: Parent Portal & Guardian Oversight Engine (Protected: auth:sanctum + parent)
Route::middleware(['auth:sanctum', 'parent'])->prefix('parent')->group(function () {
    Route::post('/link-child', [ParentOversightController::class, 'linkChild'])->name('api.v1.parent.link_child');
    Route::get('/children', [ParentOversightController::class, 'getChildren'])->name('api.v1.parent.children.index');
    Route::get('/children/{studentId}/academics', [ParentOversightController::class, 'getAcademics'])->name('api.v1.parent.children.academics');
    Route::get('/children/{studentId}/attendance', [ParentOversightController::class, 'getAttendance'])->name('api.v1.parent.children.attendance');
    Route::get('/children/{studentId}/schedule', [ParentOversightController::class, 'getSchedule'])->name('api.v1.parent.children.schedule');
    Route::get('/children/{studentId}/notes', [ParentOversightController::class, 'getNotes'])->name('api.v1.parent.children.notes.index');
    Route::post('/children/{studentId}/notes', [ParentOversightController::class, 'storeNote'])->name('api.v1.parent.children.notes.store');
    Route::put('/notes/{noteId}/acknowledge', [ParentOversightController::class, 'acknowledgeNote'])->name('api.v1.parent.notes.acknowledge');
});

// Phase 7: Course Checkout, Payment Gateway & Student Invoices (Protected: auth:sanctum)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/checkout/intent/{courseId}', [CheckoutController::class, 'getIntent'])->name('api.v1.checkout.intent');
    Route::post('/checkout/charge/{courseId}', [CheckoutController::class, 'processCharge'])->name('api.v1.checkout.charge');
    Route::post('/checkout/voucher/{courseId}', [CheckoutController::class, 'redeemVoucher'])->name('api.v1.checkout.voucher');
    Route::get('/student/orders', [CheckoutController::class, 'getStudentOrders'])->name('api.v1.student.orders.index');
    Route::get('/student/credits', [\App\Http\Controllers\Api\CreditLedgerController::class, 'index'])->name('api.v1.student.credits.index');
});

// Phase 7: Teacher Earnings & Revenue Disbursements (Protected: auth:sanctum + teacher)
Route::middleware(['auth:sanctum', 'teacher'])->prefix('teacher')->group(function () {
    Route::get('/earnings', [TeacherEarningsController::class, 'index'])->name('api.v1.teacher.earnings.index');
    Route::post('/payouts/request', [TeacherEarningsController::class, 'requestPayout'])->name('api.v1.teacher.payouts.request');
});

// Phase 8: Interactive Whiteboard & Screen Sharing Engine
Route::prefix('sessions/{sessionId}/whiteboard')->group(function () {
    Route::get('/latest', [\App\Http\Controllers\Api\WhiteboardSnapshotController::class, 'getLatest'])->name('api.v1.sessions.whiteboard.latest');
    Route::get('/history', [\App\Http\Controllers\Api\WhiteboardSnapshotController::class, 'history'])->name('api.v1.sessions.whiteboard.history');

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/snapshots', [\App\Http\Controllers\Api\WhiteboardSnapshotController::class, 'store'])->name('api.v1.sessions.whiteboard.store');
    });
});

// Admin Control Panel (Protected: auth:sanctum + admin)
Route::middleware(['auth:sanctum', 'admin'])->prefix('admin')->group(function () {
    Route::get('/teachers/verifications', [TeacherVerificationAdminController::class, 'index'])->name('api.v1.admin.teachers.verifications');
    Route::post('/teachers/{id}/verify', [TeacherVerificationAdminController::class, 'approve'])->name('api.v1.admin.teachers.verify');
    Route::post('/teachers/{id}/reject', [TeacherVerificationAdminController::class, 'reject'])->name('api.v1.admin.teachers.reject');
});

