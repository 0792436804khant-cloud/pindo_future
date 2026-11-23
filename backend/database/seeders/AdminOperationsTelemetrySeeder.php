<?php

namespace Database\Seeders;

use App\Models\ClassroomSession;
use App\Models\Course;
use App\Models\Order;
use App\Models\Role;
use App\Models\StudyCohort;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AdminOperationsTelemetrySeeder extends Seeder
{
    /**
     * Seed realistic operations data for the Admin Command Center.
     */
    public function run(): void
    {
        // 1. Pending Teacher Application 1 (Constantine / قسنطينة)
        $teacher1 = User::firstOrCreate(
            ['email' => 'mohamed.math@pindo.dz'],
            [
                'name' => 'الأستاذ محمد بن علي',
                'password' => Hash::make('password123'),
                'role' => Role::TEACHER,
                'teacher_id' => 'TCH_CST_2501',
                'wilaya' => 25, // Constantine
                'academic_level' => 'التعليم الثانوي (3AS BAC)',
                'teaching_subjects' => ['الرياضيات'],
                'teaching_levels' => ['High School (Secondary)'],
                'is_verified' => false,
                'verification_status' => 'pending',
                'national_id_or_diploma' => 'diplomas/teacher_math_constantine.jpg',
                'diploma_preview_url' => 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800&auto=format&fit=crop',
            ]
        );

        // 2. Pending Teacher Application 2 (Alger / الجزائر)
        $teacher2 = User::firstOrCreate(
            ['email' => 'fatima.sciences@pindo.dz'],
            [
                'name' => 'الأستاذة فاطمة الزهراء بلقاسم',
                'password' => Hash::make('password123'),
                'role' => Role::TEACHER,
                'teacher_id' => 'TCH_ALG_1602',
                'wilaya' => 16, // Alger
                'academic_level' => 'التعليم المتوسط (4AM BEM)',
                'teaching_subjects' => ['علوم الطبيعة والحياة'],
                'teaching_levels' => ['Middle School (CEM)'],
                'is_verified' => false,
                'verification_status' => 'pending',
                'national_id_or_diploma' => 'diplomas/teacher_sciences_alger.jpg',
                'diploma_preview_url' => 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=800&auto=format&fit=crop',
            ]
        );

        // 3. Ensure a Course exists
        $course = Course::first();
        if (!$course) {
            $course = Course::create([
                'teacher_id' => $teacher1->id,
                'title' => 'المراجعة الشاملة في الرياضيات للبكالوريا (الدوال والمتتاليات)',
                'subject' => 'الرياضيات',
                'price' => 3500.00,
                'currency' => 'DZD',
                'status' => 'published',
            ]);
        }

        // 4. Ensure Student exists
        $student = User::where('role', Role::STUDENT)->first();
        if (!$student) {
            $student = User::create([
                'name' => 'أحمد بن سالم',
                'email' => 'ahmed.student@pindo.dz',
                'password' => Hash::make('password123'),
                'role' => Role::STUDENT,
                'student_id' => 'STU_2026_001',
                'wilaya' => 16,
            ]);
        }

        // 5. Pending BaridiMob Subscription Order 1
        Order::firstOrCreate(
            ['order_number' => 'ORD_BM_20261123_88921'],
            [
                'user_id' => $student->id,
                'course_id' => $course->id,
                'amount' => 3500.00,
                'currency' => 'DZD',
                'status' => Order::STATUS_PENDING,
                'payment_method' => 'BaridiMob',
                'tx_reference' => 'BM_948271',
                'receipt_hash' => hash('sha256', 'receipt_image_ahmed_1'),
                'receipt_image_path' => 'receipts/baridimob_ahmed_948271.jpg',
            ]
        );

        // 6. Pending BaridiMob Subscription Order 2
        $student2 = User::firstOrCreate(
            ['email' => 'meriem.kadri@pindo.dz'],
            [
                'name' => 'مريم قادري',
                'password' => Hash::make('password123'),
                'role' => Role::STUDENT,
                'student_id' => 'STU_2026_002',
                'wilaya' => 19, // Sétif
            ]
        );

        Order::firstOrCreate(
            ['order_number' => 'ORD_BM_20261123_44102'],
            [
                'user_id' => $student2->id,
                'course_id' => $course->id,
                'amount' => 2500.00,
                'currency' => 'DZD',
                'status' => Order::STATUS_PENDING,
                'payment_method' => 'BaridiMob',
                'tx_reference' => 'BM_382910',
                'receipt_hash' => hash('sha256', 'receipt_image_meriem_2'),
                'receipt_image_path' => 'receipts/baridimob_meriem_382910.jpg',
            ]
        );

        // 7. Active Live Session Room
        ClassroomSession::firstOrCreate(
            ['session_id' => 'SES_SFU_MATH_BAC_2026'],
            [
                'user_id' => $teacher1->id,
                'title' => 'مراجعة الدوال الأسية واللوغاريتمية - بث حي عالي الدقة',
                'description' => 'حصة تقوية مباشرة لطلاب 3AS بكالوريا علوم وتفاضل',
                'status' => ClassroomSession::STATUS_ACTIVE,
                'started_at' => now()->subMinutes(18),
                'max_participants' => 100,
            ]
        );
    }
}
