<?php

namespace Database\Seeders;

use App\Models\Role;
use Illuminate\Database\Seeder;

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        $roles = [
            ['name' => 'admin', 'display_name' => 'Administrator', 'permissions' => ["Dashboard","Notifications","Products","Categories","Manage Products","Manage Categories","Manage Materials","Shipping Rates","My Orders","Tickets","Negotiations","Product Review","Available Jobs","QA Queue","Hero Images","Orders","Coupons","Domain Verification","Approvals","Users","Permissions","Plans","My Products","Add Digital Product"]],
            ['name' => 'user', 'display_name' => 'Regular User', 'permissions' => ["Dashboard","Notifications","Products","Categories","Cart","My Orders","Wishlist","Payment Methods"]],
            ['name' => 'tester', 'display_name' => 'Tester', 'permissions' => ["Dashboard","Notifications","Products","Categories","Tickets","Negotiations","Product Review","QA Queue"]],
            ['name' => 'designer', 'display_name' => 'Designer', 'permissions' => ["Dashboard","Notifications","Products","Categories","Tickets","Available Jobs","My Products","Add Digital Product"]],
            ['name' => 'industor', 'display_name' => 'Industor', 'permissions' => ["Dashboard","Notifications","Products","Categories","Cart","My Orders","Wishlist","Payment Methods","Tickets","New Ticket","Plans"]],
        ];

        foreach ($roles as $role) {
            Role::updateOrCreate(['name' => $role['name']], $role);
        }
    }
}
