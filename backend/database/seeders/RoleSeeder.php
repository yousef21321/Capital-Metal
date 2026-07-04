<?php

namespace Database\Seeders;

use App\Models\Role;
use Illuminate\Database\Seeder;

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        $roles = [
            ['name' => 'admin', 'display_name' => 'Administrator'],
            ['name' => 'user', 'display_name' => 'Regular User'],
            ['name' => 'tester', 'display_name' => 'Tester'],
            ['name' => 'designer', 'display_name' => 'Designer'],
            ['name' => 'industor', 'display_name' => 'Industor'],
        ];

        foreach ($roles as $role) {
            Role::firstOrCreate(['name' => $role['name']], $role);
        }
    }
}
