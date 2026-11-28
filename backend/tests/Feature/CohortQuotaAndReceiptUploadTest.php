<?php

namespace Tests\Feature;

use App\Models\ClassroomSession;
use App\Models\CohortChatMessage;
use App\Models\CohortMember;
use App\Models\Order;
use App\Models\Role;
use App\Models\StudyCohort;
use App\Models\TeacherEarning;
use App\Models\TeacherPlatform;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Tests\TestCase;

class CohortQuotaAndReceiptUploadTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        Role::firstOrCreate(['name' => Role::ADMIN], ['label' => 'Administrator']);
        Role::firstOrCreate(['name' => Role::TEACHER], ['label' => 'Teacher']);
        Role::firstOrCreate(['name' => Role::STUDENT], ['label' => 'Student']);
    }

    private function createUser(string $role, array $extra = []): User
    {
        $unique = Str::random(8);

        return User::create(array_merge([
            'name' => 'User ' . $unique,
            'email' => "user.{$unique}@example.com",
            'password' => bcrypt('SecurePassword123!'),
            'role' => $role,
        ], $extra));
    }

    public function test_teacher_can_set_session_quota_and_extra_sessions_on_cohort_and_sessions(): void
    {
        $teacher = $this->createUser(Role::TEACHER);

        $res = $this->actingAs($teacher)->postJson('/api/v1/teacher/cohorts', [
            'name' => 'فوج البكالوريا المنتظم',
            'subject' => 'الرياضيات',
            'academic_level' => '3AS',
            'stream' => 'علوم تجريبية',
            'live_sessions_price' => 3000,
            'library_price' => 1000,
            'bundle_price' => 3500,
            'include_library' => true,
            'included_sessions_count' => 8,
            'extra_sessions_count' => 2,
            'extra_sessions_is_paid' => true,
            'extra_session_price_dzd' => 600,
        ]);

        $res->assertStatus(201)
            ->assertJsonPath('data.included_sessions_count', 8)
            ->assertJsonPath('data.extra_sessions_count', 2)
            ->assertJsonPath('data.extra_sessions_is_paid', true)
            ->assertJsonPath('data.extra_session_price_dzd', 600);

        $cohortId = $res->json('data.id');

        $regular = $this->actingAs($teacher)->postJson("/api/v1/teacher/cohorts/{$cohortId}/sessions", [
            'title' => 'الحصة التأسيسية الأولى',
            'session_category' => 'regular',
        ]);
        $regular->assertStatus(201)
            ->assertJsonPath('data.session_number', 1)
            ->assertJsonPath('data.session_category', 'regular');

        $extraPaid = $this->actingAs($teacher)->postJson("/api/v1/teacher/cohorts/{$cohortId}/sessions", [
            'title' => 'حصة مراجعة إضافية مدفوعة',
            'session_category' => 'extra_paid',
        ]);
        $extraPaid->assertStatus(201)
            ->assertJsonPath('data.session_category', 'extra_paid')
            ->assertJsonPath('data.extra_price_dzd', 600);
    }

    public function test_student_preview_exposes_teacher_profile_without_chat_members_or_live_stream(): void
    {
        $teacher = $this->createUser(Role::TEACHER, [
            'teacher_id' => 'TCH_PREVIEW_01',
            'wilaya' => 16,
            'teaching_years' => ['3AS (BAC)'],
            'teaching_subjects' => ['الرياضيات'],
            'is_verified' => true,
        ]);

        TeacherPlatform::create([
            'user_id' => $teacher->id,
            'slug' => 'preview-teacher-01',
            'headline' => 'أستاذ مادة الرياضيات المعتمد',
            'bio' => 'خبرة 12 سنة في التحضير للبكالوريا.',
            'settings' => ['years_of_experience' => 12],
        ]);

        $cohort = StudyCohort::create([
            'teacher_id' => $teacher->id,
            'name' => 'فوج التميز للبكالوريا',
            'subject' => 'الرياضيات',
            'academic_level' => '3AS',
            'live_sessions_price' => 2500,
            'bundle_price' => 3500,
            'included_sessions_count' => 6,
            'extra_sessions_count' => 1,
            'extra_sessions_is_paid' => false,
            'is_active' => true,
        ]);

        $enrolledStudent = $this->createUser(Role::STUDENT);
        CohortMember::create([
            'cohort_id' => $cohort->id,
            'student_id' => $enrolledStudent->id,
            'status' => 'active',
            'joined_at' => now(),
        ]);

        CohortChatMessage::create([
            'cohort_id' => $cohort->id,
            'sender_id' => $enrolledStudent->id,
            'body' => 'رسالة خاصة داخل دردشة التلاميذ المنخرطين',
        ]);

        $guestStudent = $this->createUser(Role::STUDENT);

        $preview = $this->actingAs($guestStudent)->getJson("/api/v1/cohorts/{$cohort->id}/preview");
        $preview->assertStatus(200)
            ->assertJsonPath('data.teacher.name', $teacher->name)
            ->assertJsonPath('data.teacher.bio', 'خبرة 12 سنة في التحضير للبكالوريا.')
            ->assertJsonPath('data.cohort.included_sessions_count', 6)
            ->assertJsonPath('data.cohort.access_restricted.chat_hidden', true)
            ->assertJsonMissing(['body' => 'رسالة خاصة داخل دردشة التلاميذ المنخرطين'])
            ->assertJsonMissing(['student_id' => $enrolledStudent->id]);

        // Unenrolled student must be strictly blocked from chat and live stream token
        $this->actingAs($guestStudent)
            ->getJson("/api/v1/cohorts/{$cohort->id}/chat/messages")
            ->assertStatus(403);
    }

    public function test_receipt_upload_requires_real_file_keeps_pending_until_admin_approves_and_enforces_quota(): void
    {
        Storage::fake('public');

        $admin = $this->createUser(Role::ADMIN);
        $teacher = $this->createUser(Role::TEACHER);
        $student = $this->createUser(Role::STUDENT);

        $cohort = StudyCohort::create([
            'teacher_id' => $teacher->id,
            'name' => 'فوج الفيزياء النموذجي',
            'subject' => 'الفيزياء',
            'academic_level' => '3AS',
            'live_sessions_price' => 2000,
            'library_price' => 1000,
            'bundle_price' => 2800,
            'include_library' => true,
            'included_sessions_count' => 2,
            'extra_sessions_count' => 1,
            'extra_sessions_is_paid' => false,
            'is_active' => true,
        ]);

        // 1. Submitting without receipt must be rejected with 422
        $missingFile = $this->actingAs($student)->post("/api/v1/student/cohorts/{$cohort->id}/subscribe-receipt", [
            'payment_method' => 'BaridiMob',
            'package_type' => StudyCohort::PACKAGE_FULL_BUNDLE,
        ], ['Accept' => 'application/json']);
        $missingFile->assertStatus(422);

        // 2. Submitting valid PNG receipt succeeds as pending (not yet active in chat/live!)
        $fakeReceipt = UploadedFile::fake()->image('baridimob_receipt.png', 600, 900);
        $uploadRes = $this->actingAs($student)->post("/api/v1/student/cohorts/{$cohort->id}/subscribe-receipt", [
            'payment_method' => 'BaridiMob',
            'package_type' => StudyCohort::PACKAGE_FULL_BUNDLE,
            'tx_reference' => 'BM_TX_998877',
            'receipt' => $fakeReceipt,
        ], ['Accept' => 'application/json']);

        $uploadRes->assertStatus(201)
            ->assertJsonPath('data.status', 'pending')
            ->assertJsonPath('data.amount', 2800);

        $order = Order::firstOrFail();
        $this->assertNotEmpty($order->receipt_image_path);
        $this->assertNotEmpty($order->receipt_hash);
        Storage::disk('public')->assertExists($order->receipt_image_path);

        // Pending student CANNOT read cohort chat before admin verifies payment
        $this->actingAs($student)
            ->getJson("/api/v1/cohorts/{$cohort->id}/chat/messages")
            ->assertStatus(403);

        // 3. Admin approves receipt -> activates membership with quota=2 & records teacher earnings
        $approveRes = $this->actingAs($admin)->postJson("/admin/api/subscriptions/{$order->id}/approve");
        $approveRes->assertStatus(200);

        $member = CohortMember::where('cohort_id', $cohort->id)
            ->where('student_id', $student->id)
            ->firstOrFail();
        $this->assertSame('active', $member->status);
        $this->assertSame(2, $member->sessions_quota);
        $this->assertSame(0, $member->sessions_attended);
        $this->assertSame(1, $member->first_session_number);
        $this->assertSame(2, $member->last_session_number);

        $earning = TeacherEarning::where('order_id', $order->id)->firstOrFail();
        $this->assertEquals(2800.0, (float) $earning->gross_amount);
        // 15% of 2000 (300) + 10% of 1000 (100) = 400 fee -> 2400 net
        $this->assertEquals(400.0, (float) $earning->platform_fee);
        $this->assertEquals(2400.0, (float) $earning->net_amount);

        // Active student CAN now access cohort chat
        $this->actingAs($student)
            ->getJson("/api/v1/cohorts/{$cohort->id}/chat/messages")
            ->assertStatus(200);

        // 4. Quota enforcement across Session 1, Session 2, then blocked on Session 3, while Extra Free allowed!
        $s1 = ClassroomSession::create([
            'user_id' => $teacher->id,
            'cohort_id' => $cohort->id,
            'session_number' => 1,
            'session_category' => 'regular',
            'title' => 'الحصة 1',
            'status' => ClassroomSession::STATUS_ACTIVE,
            'scheduled_at' => now(),
        ]);
        $s2 = ClassroomSession::create([
            'user_id' => $teacher->id,
            'cohort_id' => $cohort->id,
            'session_number' => 2,
            'session_category' => 'regular',
            'title' => 'الحصة 2',
            'status' => ClassroomSession::STATUS_ACTIVE,
            'scheduled_at' => now(),
        ]);
        $s3 = ClassroomSession::create([
            'user_id' => $teacher->id,
            'cohort_id' => $cohort->id,
            'session_number' => 3,
            'session_category' => 'regular',
            'title' => 'الحصة 3',
            'status' => ClassroomSession::STATUS_ACTIVE,
            'scheduled_at' => now(),
        ]);
        $extraFree = ClassroomSession::create([
            'user_id' => $teacher->id,
            'cohort_id' => $cohort->id,
            'session_number' => 1,
            'session_category' => 'extra_free',
            'title' => 'حصة إضافية مجانية',
            'status' => ClassroomSession::STATUS_ACTIVE,
            'scheduled_at' => now(),
        ]);

        // Join S1 & S2
        $this->actingAs($student)->postJson("/api/v1/sessions/{$s1->session_id}/token", ['device_type' => 'web'])->assertStatus(200);
        $this->actingAs($student)->postJson("/api/v1/sessions/{$s1->session_id}/attendance/join")->assertStatus(200);

        $this->actingAs($student)->postJson("/api/v1/sessions/{$s2->session_id}/token", ['device_type' => 'web'])->assertStatus(200);
        $this->actingAs($student)->postJson("/api/v1/sessions/{$s2->session_id}/attendance/join")->assertStatus(200);

        $member->refresh();
        $this->assertSame(2, $member->sessions_attended);

        // Session 3 (beyond quota of 2) is strictly blocked requiring renewal
        $this->actingAs($student)
            ->postJson("/api/v1/sessions/{$s3->session_id}/token", ['device_type' => 'web'])
            ->assertStatus(403)
            ->assertJsonPath('requires_renewal', true);

        // Free extra session offered by teacher remains accessible even after regular quota check!
        $this->actingAs($student)
            ->postJson("/api/v1/sessions/{$extraFree->session_id}/token", ['device_type' => 'web'])
            ->assertStatus(200);
    }
}
