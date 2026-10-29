<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;

class CacheManagerService
{
    public const TTL_STUDENT_DASHBOARD = 30; // seconds
    public const TTL_TEACHER_DASHBOARD = 30; // seconds
    public const TTL_PUBLIC_SHOWCASE = 300;   // 5 minutes
    public const TTL_EXAM_CATALOG = 600;      // 10 minutes

    /**
     * Cache-Aside get or compute.
     */
    public function remember(string $key, int $ttlSeconds, callable $callback): mixed
    {
        return Cache::remember($key, $ttlSeconds, $callback);
    }

    /**
     * Invalidate specific cache key.
     */
    public function forget(string $key): bool
    {
        return Cache::forget($key);
    }

    /**
     * Invalidate student dashboard cache.
     */
    public function invalidateStudent(int $studentId): bool
    {
        return Cache::forget("student:dashboard:{$studentId}");
    }

    /**
     * Invalidate teacher dashboard cache.
     */
    public function invalidateTeacher(int $teacherId): bool
    {
        Cache::forget("teacher:dashboard:{$teacherId}");
        Cache::forget("teacher:public:{$teacherId}");
        return true;
    }

    /**
     * Invalidate public teacher catalog & showcase.
     */
    public function invalidatePublicShowcase(string|int $identifier): bool
    {
        Cache::forget("teacher:showcase:{$identifier}");
        Cache::forget("courses:public:index");
        return true;
    }
}
