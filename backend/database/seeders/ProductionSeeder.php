<?php

namespace Database\Seeders;

use App\Models\Permission;
use App\Models\Role;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class ProductionSeeder extends Seeder
{
    /**
     * Clean, idempotent production bootstrap seeder:
     * 1. Seeds strict system Roles & Permissions.
     * 2. Seeds official National BEM/BAC Exam Bank.
     * 3. Ensures the platform Administrator account from environment variables without creating fake teachers/students.
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

        // 3. Synchronize Role Permissions
        $roleModels[Role::ADMIN]->permissions()->sync(collect($permModels)->pluck('id'));
        $roleModels[Role::TEACHER]->permissions()->sync([
            $permModels['create_session']->id,
            $permModels['start_stream']->id,
            $permModels['join_session']->id,
            $permModels['view_courses']->id,
            $permModels['view_student_progress']->id,
        ]);
        $roleModels[Role::STUDENT]->permissions()->sync([
            $permModels['join_session']->id,
            $permModels['view_courses']->id,
            $permModels['view_student_progress']->id,
        ]);
        $roleModels[Role::PARENT]->permissions()->sync([
            $permModels['view_courses']->id,
            $permModels['view_student_progress']->id,
            $permModels['manage_billing']->id,
        ]);

        // 4. Provision Real Platform Administrator Account ONLY if configured or no admin exists
        $adminEmail = env('ADMIN_EMAIL');
        $adminPassword = env('ADMIN_PASSWORD');

        if (!empty($adminEmail) && !empty($adminPassword)) {
            $admin = User::updateOrCreate(
                ['email' => strtolower(trim($adminEmail))],
                [
                    'name' => env('ADMIN_NAME', 'Platform Administrator'),
                    'password' => Hash::make($adminPassword),
                    'role' => Role::ADMIN,
                    'is_verified' => true,
                    'verification_status' => 'verified',
                ]
            );
            $admin->roles()->syncWithoutDetaching([$roleModels[Role::ADMIN]->id]);
        }

        // 5. Seed Real National BEM/BAC Exam Bank
        $this->call(ExamBankSeeder::class);
    }
}
