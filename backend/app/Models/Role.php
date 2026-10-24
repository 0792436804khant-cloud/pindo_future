<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Role extends Model
{
    use HasFactory;

    // Strict 4 Role Constants
    public const ADMIN = 'admin';
    public const TEACHER = 'teacher';
    public const STUDENT = 'student';
    public const PARENT = 'parent';

    public const ALL_ROLES = [
        self::ADMIN,
        self::TEACHER,
        self::STUDENT,
        self::PARENT,
    ];

    public const PUBLIC_REGISTRATION_ROLES = [
        self::TEACHER,
        self::STUDENT,
        self::PARENT,
    ];

    protected $fillable = [
        'name',
        'label',
        'description',
    ];

    /**
     * Users associated with this role.
     */
    public function users(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'role_user');
    }

    /**
     * Permissions assigned to this role.
     */
    public function permissions(): BelongsToMany
    {
        return $this->belongsToMany(Permission::class, 'permission_role');
    }

    /**
     * Grant permission to role.
     */
    public function givePermissionTo(Permission|string $permission): void
    {
        if (is_string($permission)) {
            $permission = Permission::firstOrCreate(
                ['name' => $permission],
                ['label' => ucfirst(str_replace('_', ' ', $permission))]
            );
        }

        $this->permissions()->syncWithoutDetaching([$permission->id]);
    }
}
