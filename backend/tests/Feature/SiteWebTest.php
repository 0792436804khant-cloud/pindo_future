<?php

namespace Tests\Feature;

use App\Models\ExamPaper;
use App\Models\Role;
use App\Models\StudyCohort;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SiteWebTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Role::firstOrCreate(['name' => Role::TEACHER], ['label' => 'Teacher']);
    }

    public function test_official_siteweb_home_renders_dz_education_content(): void
    {
        ExamPaper::create([
            'exam_code' => 'BAC-2024-SITE-TEST',
            'title' => 'بكالوريا 2024 - الرياضيات',
            'cycle' => 'bac',
            'stream' => 'experimental_sciences',
            'subject' => 'mathematics',
            'subject_name_ar' => 'الرياضيات',
            'year' => 2024,
            'duration_minutes' => 210,
            'coefficient' => 5,
            'is_published' => true,
        ]);

        $response = $this->get('/');
        $response->assertStatus(200);
        $response->assertSee('مستقبل التعليم في الجزائر');
        $response->assertSee('Future Generation of Education DZ');
        $response->assertSee('/app/');
        $response->assertSee('BAC-2024-SITE-TEST');
    }

    public function test_privacy_policy_page_renders(): void
    {
        $this->get('/privacy')
            ->assertStatus(200)
            ->assertSee('سياسة الخصوصية');
    }

    public function test_teacher_showcase_renders_verified_teacher_and_handles_missing(): void
    {
        $this->get('/teacher/TCH_MISSING')
            ->assertStatus(200)
            ->assertSee('TCH_MISSING');

        $teacher = User::create([
            'name' => 'أستاذ الفيزياء الرسمي',
            'email' => 'phys.site@pindofuture.com',
            'password' => bcrypt('StrongPass123!'),
            'role' => Role::TEACHER,
            'teacher_id' => 'TCH_PHYS_01',
            'is_verified' => true,
            'verification_status' => 'verified',
        ]);

        StudyCohort::create([
            'teacher_id' => $teacher->id,
            'cohort_code' => 'COH_PHYS_BAC',
            'name' => 'فوج الفيزياء للبكالوريا',
            'subject' => 'العلوم الفيزيائية',
            'academic_level' => 'secondary',
            'monthly_price' => 3000,
            'is_active' => true,
        ]);

        $this->get('/teacher/TCH_PHYS_01')
            ->assertStatus(200)
            ->assertSee('أستاذ الفيزياء الرسمي')
            ->assertSee('فوج الفيزياء للبكالوريا');
    }
}
