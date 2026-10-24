<?php

namespace Database\Seeders;

use App\Models\Permission;
use App\Models\Role;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Seed Roles
        $roles = [
            Role::ADMIN => [
                'label' => 'Administrator',
                'description' => 'Superuser with full administrative capabilities across the platform.',
            ],
            Role::TEACHER => [
                'label' => 'Teacher / Instructor',
                'description' => 'Can host live classrooms, generate room sessions, and manage platforms.',
            ],
            Role::STUDENT => [
                'label' => 'Student / Learner',
                'description' => 'Can enroll in courses, join dynamic sessions, and view content.',
            ],
            Role::PARENT => [
                'label' => 'Parent / Guardian',
                'description' => 'Can monitor student learning progress, attendance, and handle tuition.',
            ],
        ];

        $roleModels = [];
        foreach ($roles as $roleName => $details) {
            $roleModels[$roleName] = Role::firstOrCreate(
                ['name' => $roleName],
                [
                    'label' => $details['label'],
                    'description' => $details['description'],
                ]
            );
        }

        // 2. Seed Permissions
        $permissions = [
            'manage_platform' => 'Full platform and infrastructure administration',
            'manage_users' => 'Manage user accounts and roles',
            'create_session' => 'Create and schedule dynamic classroom sessions',
            'start_stream' => 'Publish WebRTC/SFU live video and audio streams',
            'join_session' => 'Join interactive classroom sessions as attendee',
            'view_courses' => 'Browse and consume educational content',
            'view_student_progress' => 'Monitor learning analytics and attendance',
            'manage_billing' => 'Process course payments and subscriptions',
        ];

        $permModels = [];
        foreach ($permissions as $permName => $label) {
            $permModels[$permName] = Permission::firstOrCreate(
                ['name' => $permName],
                ['label' => $label]
            );
        }

        // 3. Assign Permissions to Roles
        // Admin gets all permissions
        $roleModels[Role::ADMIN]->permissions()->sync(
            collect($permModels)->pluck('id')
        );

        // Teacher permissions
        $roleModels[Role::TEACHER]->permissions()->sync([
            $permModels['create_session']->id,
            $permModels['start_stream']->id,
            $permModels['join_session']->id,
            $permModels['view_courses']->id,
            $permModels['view_student_progress']->id,
        ]);

        // Student permissions
        $roleModels[Role::STUDENT]->permissions()->sync([
            $permModels['join_session']->id,
            $permModels['view_courses']->id,
            $permModels['view_student_progress']->id,
        ]);

        // Parent permissions
        $roleModels[Role::PARENT]->permissions()->sync([
            $permModels['view_courses']->id,
            $permModels['view_student_progress']->id,
            $permModels['manage_billing']->id,
        ]);

        // 4. Seed Seed-Users for each of the 4 Strict Roles
        // Admin User
        $admin = User::firstOrCreate(
            ['email' => 'admin@pindofuture.com'],
            [
                'name' => 'Platform Administrator',
                'password' => Hash::make('AdminPassword123!'),
                'role' => Role::ADMIN,
            ]
        );
        $admin->roles()->syncWithoutDetaching([$roleModels[Role::ADMIN]->id]);

        // Teacher Users with Teaching Classification
        $teacher = User::updateOrCreate(
            ['email' => 'teacher.demo@pindofuture.com'],
            [
                'name' => 'Professor Alan Turing',
                'password' => Hash::make('TeacherPassword123!'),
                'role' => Role::TEACHER,
                'teacher_id' => 'TCH_123',
                'teaching_levels' => ['High School (Secondary)', 'University & Higher Ed'],
                'teaching_years' => ['3rd Year Secondary (BAC)', '2nd Year Secondary (2AS)', '1st Year License (L1)'],
                'teaching_subjects' => ['Advanced Mathematics', 'Physics & Chemistry', 'Computer Science & Algorithms'],
            ]
        );
        $teacher->roles()->syncWithoutDetaching([$roleModels[Role::TEACHER]->id]);

        $teacherCurie = User::updateOrCreate(
            ['email' => 'curie.demo@pindofuture.com'],
            [
                'name' => 'Dr. Marie Curie',
                'password' => Hash::make('TeacherPassword123!'),
                'role' => Role::TEACHER,
                'teacher_id' => 'TCH_CURIE',
                'teaching_levels' => ['Middle School (CEM)', 'High School (Secondary)'],
                'teaching_years' => ['4th Middle School (BEM)', '3rd Year Secondary (BAC)', '2nd Year Secondary (2AS)'],
                'teaching_subjects' => ['Physics & Chemistry', 'Physical Sciences & Chemistry', 'Natural & Life Sciences'],
            ]
        );
        $teacherCurie->roles()->syncWithoutDetaching([$roleModels[Role::TEACHER]->id]);

        $teacherFatima = User::updateOrCreate(
            ['email' => 'fatima.demo@pindofuture.com'],
            [
                'name' => 'Ustadha Fatima Al-Zahra',
                'password' => Hash::make('TeacherPassword123!'),
                'role' => Role::TEACHER,
                'teacher_id' => 'TCH_FATIMA',
                'teaching_levels' => ['Primary School (Primaire)', 'Middle School (CEM)'],
                'teaching_years' => ['5th Year Primary (5AP)', '4th Year Primary (4AP)', '1st Middle School (1AM)'],
                'teaching_subjects' => ['Mathematics', 'Arabic Language', 'Science & Technology'],
            ]
        );
        $teacherFatima->roles()->syncWithoutDetaching([$roleModels[Role::TEACHER]->id]);

        $teacherSina = User::updateOrCreate(
            ['email' => 'ibnsina.demo@pindofuture.com'],
            [
                'name' => 'Prof. Ibn Sina (Avicenna)',
                'password' => Hash::make('TeacherPassword123!'),
                'role' => Role::TEACHER,
                'teacher_id' => 'TCH_SINA',
                'teaching_levels' => ['High School (Secondary)', 'University & Higher Ed'],
                'teaching_years' => ['3rd Year Secondary (BAC)', 'Master & Engineering'],
                'teaching_subjects' => ['Natural Sciences', 'Philosophy', 'Medical & Pharmaceutical Sciences'],
            ]
        );
        $teacherSina->roles()->syncWithoutDetaching([$roleModels[Role::TEACHER]->id]);

        // Student User
        $student = User::firstOrCreate(
            ['email' => 'student.demo@pindofuture.com'],
            [
                'name' => 'Ada Lovelace',
                'password' => Hash::make('StudentPassword123!'),
                'role' => Role::STUDENT,
            ]
        );
        $student->roles()->syncWithoutDetaching([$roleModels[Role::STUDENT]->id]);

        // Parent User
        $parent = User::firstOrCreate(
            ['email' => 'parent.demo@pindofuture.com'],
            [
                'name' => 'Lady Byron',
                'password' => Hash::make('ParentPassword123!'),
                'role' => Role::PARENT,
            ]
        );
        $parent->roles()->syncWithoutDetaching([$roleModels[Role::PARENT]->id]);

        // 5. Seed Phase 2 & 5: Teacher Platform Profile
        \App\Models\TeacherPlatform::updateOrCreate(
            ['user_id' => $teacher->id],
            [
                'headline' => 'Pioneer of Computer Science & Algorithmic Theory',
                'bio' => 'Welcome to my official educational platform! Explore my live masterclasses on distributed systems, discrete mathematics, and WebRTC streaming. Helping students achieve peak academic excellence for over 14 years.',
                'website_url' => 'https://alanturing.org',
                'settings' => [
                    'avatar_url' => 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
                    'years_of_experience' => 14,
                    'office_hours' => 'Mon-Thu 14:00 - 16:00 UTC',
                    'student_achievements' => [
                        [
                            'id' => 'ach_1',
                            'title' => 'BAC 2024 Mathématiques — Mention Très Bien (Major)',
                            'student_name' => 'Amine Belkacem',
                            'grade_or_score' => '19.45 / 20',
                            'year' => '2024',
                            'photo_url' => 'https://images.unsplash.com/photo-1589330694653-ded6df03f754?auto=format&fit=crop&w=800&q=80',
                            'description' => 'Admitted to Higher National School of Computer Science (ESI Algiers) after completing intensive advanced algorithms track.',
                        ],
                        [
                            'id' => 'ach_2',
                            'title' => 'National Informatics Olympiad Gold Medalist',
                            'student_name' => 'Sara Mansouri',
                            'grade_or_score' => 'Gold Medal (1st Place)',
                            'year' => '2024',
                            'photo_url' => 'https://images.unsplash.com/photo-1606326608606-aa0b62935f2b?auto=format&fit=crop&w=800&q=80',
                            'description' => 'Represented Algeria at IOI International Olympiad after 2 years of weekly live mentoring on Pindo Future.',
                        ],
                        [
                            'id' => 'ach_3',
                            'title' => 'BAC 2023 Math-Technique — Score Parfait en Maths & Physique',
                            'student_name' => 'Yacine Djebbar',
                            'grade_or_score' => '20.00 / 20',
                            'year' => '2023',
                            'photo_url' => 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?auto=format&fit=crop&w=800&q=80',
                            'description' => 'Top score nationally in Advanced Calculus and Kinematics.',
                        ],
                    ],
                ],
            ]
        );

        \App\Models\TeacherPlatform::updateOrCreate(
            ['user_id' => $teacherCurie->id],
            [
                'headline' => 'Nobel Laureate & Senior Sciences Researcher',
                'bio' => 'Specialized in secondary and middle school physics, experimental chemistry, and thermodynamics. Coaching BAC & BEM candidates towards top national honors.',
                'website_url' => 'https://curie-sciences.pindofuture.com',
                'settings' => [
                    'avatar_url' => 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80',
                    'years_of_experience' => 18,
                    'student_achievements' => [
                        [
                            'id' => 'ach_curie_1',
                            'title' => 'BAC 2024 Sciences Expérimentales — Mention Très Bien',
                            'student_name' => 'Meriem Kaci',
                            'grade_or_score' => '19.10 / 20',
                            'year' => '2024',
                            'photo_url' => 'https://images.unsplash.com/photo-1562774053-701939374585?auto=format&fit=crop&w=800&q=80',
                            'description' => 'Top student in Faculty of Medicine entrance exam with 19.5/20 in Physical Sciences.',
                        ],
                        [
                            'id' => 'ach_curie_2',
                            'title' => 'BEM 2024 — Mention Félicitations du Jury',
                            'student_name' => 'Karim Benaissa',
                            'grade_or_score' => '19.65 / 20',
                            'year' => '2024',
                            'photo_url' => 'https://images.unsplash.com/photo-1589330694653-ded6df03f754?auto=format&fit=crop&w=800&q=80',
                            'description' => 'Ranked 2nd in Algiers province after completing complete preparatory physics syllabus.',
                        ],
                    ],
                ],
            ]
        );

        \App\Models\TeacherPlatform::updateOrCreate(
            ['user_id' => $teacherFatima->id],
            [
                'headline' => 'Dedicated Primary & Middle School Pedagogy Specialist',
                'bio' => 'Interactive foundational learning with visual memory techniques and comprehensive 5AP & BEM preparations.',
                'website_url' => 'https://fatima-pedagogy.pindofuture.com',
                'settings' => [
                    'avatar_url' => 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
                    'years_of_experience' => 9,
                    'student_achievements' => [
                        [
                            'id' => 'ach_fatima_1',
                            'title' => '5AP Examen de Fin de Cycle Primaire — 10/10 Parfait',
                            'student_name' => 'Rayane Bouzid',
                            'grade_or_score' => '10 / 10',
                            'year' => '2024',
                            'photo_url' => 'https://images.unsplash.com/photo-1606326608606-aa0b62935f2b?auto=format&fit=crop&w=800&q=80',
                            'description' => 'Outstanding mastery of Arabic grammar and mental arithmetic.',
                        ],
                    ],
                ],
            ]
        );

        // 6. Seed Scheduled & Live Dynamic Classroom Sessions
        $session = \App\Models\ClassroomSession::firstOrCreate(
            ['session_id' => 'SES_DEMO_LIVE'],
            [
                'user_id' => $teacher->id,
                'title' => 'Live Masterclass: High-Concurrency WebRTC SFU Clusters',
                'description' => 'Real-time interactive deep dive into horizontal scaling with 30,000 concurrent students.',
                'status' => \App\Models\ClassroomSession::STATUS_SCHEDULED,
                'max_participants' => 30000,
                'scheduled_at' => now()->addHours(2),
            ]
        );

        // 7. Seed Published Course with Curriculum
        $course = \App\Models\Course::firstOrCreate(
            ['slug' => 'foundations-of-modern-cryptography'],
            [
                'teacher_id' => $teacher->id,
                'title' => 'Foundations of Modern Cryptography & Zero-Knowledge Proofs',
                'description' => 'An intensive, live-interactive masterclass exploring mathematical cryptography, public key infrastructure, and high-throughput privacy proofs.',
                'category' => 'Computer Science',
                'price' => 4500.00,
                'thumbnail_url' => 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800',
                'status' => \App\Models\Course::STATUS_PUBLISHED,
            ]
        );

        // Course Modules
        $module = \App\Models\CourseModule::firstOrCreate(
            ['course_id' => $course->id, 'title' => 'Module 1: Real-Time Media Protocols & SFUs'],
            ['order' => 1]
        );

        // Course Lessons
        \App\Models\CourseLesson::firstOrCreate(
            ['course_module_id' => $module->id, 'title' => 'Lesson 1.1: WebRTC Signaling, SDP, and ICE Candidate Traversal'],
            [
                'type' => \App\Models\CourseLesson::TYPE_VIDEO,
                'duration_minutes' => 40,
                'order' => 1,
            ]
        );

        \App\Models\CourseLesson::firstOrCreate(
            ['course_module_id' => $module->id, 'title' => 'Lesson 1.2: Live Interactive SFU Lab Session'],
            [
                'type' => \App\Models\CourseLesson::TYPE_LIVE_SESSION,
                'classroom_session_id' => $session?->id,
                'duration_minutes' => 60,
                'order' => 2,
            ]
        );

        // Student Enrollment
        \App\Models\Enrollment::firstOrCreate(
            ['user_id' => $student->id, 'course_id' => $course->id],
            [
                'status' => \App\Models\Enrollment::STATUS_ACTIVE,
                'enrolled_at' => now(),
                'progress_percentage' => 35,
            ]
        );

        // 8. Phase 6: Parent-Child Linkage & Guardian Oversight Data
        \App\Models\ParentStudent::firstOrCreate(
            ['parent_id' => $parent->id, 'student_id' => $student->id],
            [
                'relationship' => 'Mother',
                'status' => 'active',
                'linking_code' => 'ADA_2026',
                'linked_at' => now()->subDays(14),
            ]
        );

        // Seed Sample Classroom Attendance
        \App\Models\ClassroomAttendance::firstOrCreate(
            ['session_id' => 'SES_DEMO_LIVE', 'user_id' => $student->id],
            [
                'role' => 'student',
                'joined_at' => now()->subDays(2)->setHour(14)->setMinute(0),
                'left_at' => now()->subDays(2)->setHour(14)->setMinute(52),
                'duration_seconds' => 3120, // 52 minutes
            ]
        );

        // Seed Guardian Notes
        \App\Models\GuardianNote::firstOrCreate(
            ['student_id' => $student->id, 'title' => 'Midterm Academic Progress Commendation'],
            [
                'parent_id' => $parent->id,
                'author_id' => $teacher->id,
                'content' => 'Ada demonstrates exceptional mastery of cryptographic primitives and active engagement during our SFU live lab sessions. Keep up the brilliant momentum!',
                'type' => 'progress_report',
                'is_acknowledged' => true,
            ]
        );

        \App\Models\GuardianNote::firstOrCreate(
            ['student_id' => $student->id, 'title' => 'Upcoming Distributed Consensus Masterclass'],
            [
                'parent_id' => $parent->id,
                'author_id' => $teacher->id,
                'content' => 'Reminder that tomorrow\'s live lecture includes a live hands-on exercise with consensus mechanisms. Attendance is highly encouraged.',
                'type' => 'general',
                'is_acknowledged' => false,
            ]
        );

        // 9. Phase 7: Orders, Transactions & Teacher Earnings
        $order1 = \App\Models\Order::firstOrCreate(
            ['order_number' => 'ORD_20261012_A8F9K2'],
            [
                'user_id' => $student->id,
                'course_id' => $course->id,
                'amount' => 4500.00,
                'currency' => 'DZD',
                'status' => \App\Models\Order::STATUS_COMPLETED,
                'payment_method' => 'card',
                'gateway_transaction_id' => 'ch_3N8kL2Hjklm987qwe1234567',
                'receipt_number' => 'RCP_7894561230',
                'payment_metadata' => [
                    'brand' => 'Visa',
                    'last4' => '4242',
                    'gateway' => 'stripe_simulator',
                ],
                'paid_at' => now()->subDays(2),
            ]
        );

        \App\Models\TeacherEarning::firstOrCreate(
            ['order_id' => $order1->id],
            [
                'teacher_id' => $teacher->id,
                'course_id' => $course->id,
                'gross_amount' => 4500.00,
                'platform_fee' => 900.00,
                'net_amount' => 3600.00,
                'status' => \App\Models\TeacherEarning::STATUS_AVAILABLE,
            ]
        );

        // 10. Phase 6: Algerian National Exam Banks & Timed Simulations
        $this->call(ExamBankSeeder::class);
    }
}
