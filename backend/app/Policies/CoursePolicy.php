<?php

namespace App\Policies;

use App\Models\Course;
use App\Models\Role;
use App\Models\User;

class CoursePolicy
{
    /**
     * Determine whether anyone can view the course list.
     */
    public function viewAny(?User $user): bool
    {
        return true;
    }

    /**
     * Determine whether the user can view the course.
     */
    public function view(?User $user, Course $course): bool
    {
        if ($course->status === Course::STATUS_PUBLISHED) {
            return true;
        }

        if (!$user) {
            return false;
        }

        return $user->id === $course->teacher_id || $user->hasRole(Role::ADMIN);
    }

    /**
     * Determine whether the user can create courses.
     */
    public function create(User $user): bool
    {
        return $user->hasRole(Role::TEACHER) || $user->hasRole(Role::ADMIN);
    }

    /**
     * Determine whether the user can update the course.
     */
    public function update(User $user, Course $course): bool
    {
        return $user->id === $course->teacher_id || $user->hasRole(Role::ADMIN);
    }

    /**
     * Determine whether the user can delete the course.
     */
    public function delete(User $user, Course $course): bool
    {
        return $user->id === $course->teacher_id || $user->hasRole(Role::ADMIN);
    }

    /**
     * Determine whether the user can modify curriculum modules and lessons.
     */
    public function manageCurriculum(User $user, Course $course): bool
    {
        return $user->id === $course->teacher_id || $user->hasRole(Role::ADMIN);
    }
}
