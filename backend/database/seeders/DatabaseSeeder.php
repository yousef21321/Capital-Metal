<?php

namespace Database\Seeders;

use App\Models\Address;
use App\Models\Cart;
use App\Models\Inventory;
use App\Models\PaymentMethod;
use App\Models\Product;
use App\Models\Role;
use App\Models\ShippingCompany;
use App\Models\ShippingRate;
use App\Models\SubscriptionPlan;
use App\Models\TrafficSource;
use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call(RoleSeeder::class);

        $adminRole = Role::where('name', 'admin')->first();
        $userRole = Role::where('name', 'user')->first();
        $testerRole = Role::where('name', 'tester')->first();
        $designerRole = Role::where('name', 'designer')->first();
        $industorRole = Role::where('name', 'industor')->first();

        $admin = User::firstOrCreate(
            ['email' => 'admin@capitalmetal.com'],
            ['name' => 'Admin', 'password' => 'password', 'role_id' => $adminRole?->id, 'phone' => '01000000001', 'is_verified' => true]
        );

        $user = User::firstOrCreate(
            ['email' => 'user@capitalmetal.com'],
            ['name' => 'Regular User', 'password' => 'password', 'role_id' => $userRole?->id, 'phone' => '01000000002', 'is_verified' => true]
        );

        User::firstOrCreate(
            ['email' => 'tester@capitalmetal.com'],
            ['name' => 'Tester', 'password' => 'password', 'role_id' => $testerRole?->id, 'phone' => '01000000003']
        );

        User::firstOrCreate(
            ['email' => 'designer@capitalmetal.com'],
            ['name' => 'Designer', 'password' => 'password', 'role_id' => $designerRole?->id, 'phone' => '01000000004']
        );

        User::firstOrCreate(
            ['email' => 'industor@capitalmetal.com'],
            ['name' => 'Industor', 'password' => 'password', 'role_id' => $industorRole?->id, 'phone' => '01000000005']
        );

        // Payment Methods
        PaymentMethod::firstOrCreate(['name' => 'Credit Card'], ['currency' => 'EGP']);
        PaymentMethod::firstOrCreate(['name' => 'Cash on Delivery'], ['currency' => 'EGP']);
        PaymentMethod::firstOrCreate(['name' => 'Bank Transfer'], ['currency' => 'EGP']);
        PaymentMethod::firstOrCreate(['name' => 'PayPal'], ['currency' => 'USD']);

        // Shipping Companies
        $aramex = ShippingCompany::firstOrCreate(
            ['name' => 'Aramex'],
            ['api_endpoint' => 'https://api.aramex.com', 'is_active' => true]
        );
        ShippingCompany::firstOrCreate(
            ['name' => 'DHL'],
            ['api_endpoint' => 'https://api.dhl.com', 'is_active' => true]
        );

        ShippingRate::create(['company_id' => $aramex->id, 'governorate' => 'Cairo', 'cost' => 50.00]);
        ShippingRate::create(['company_id' => $aramex->id, 'governorate' => 'Alexandria', 'cost' => 65.00]);
        ShippingRate::create(['company_id' => $aramex->id, 'governorate' => 'Giza', 'cost' => 50.00]);

        // Subscription Plans
        SubscriptionPlan::firstOrCreate(['name' => 'Basic'], ['price' => 0, 'currency' => 'EGP', 'duration_days' => 30]);
        SubscriptionPlan::firstOrCreate(['name' => 'Premium'], ['price' => 299, 'currency' => 'EGP', 'duration_days' => 30]);
        SubscriptionPlan::firstOrCreate(['name' => 'Enterprise'], ['price' => 999, 'currency' => 'EGP', 'duration_days' => 30]);

        // Traffic Sources
        TrafficSource::firstOrCreate(['source_name' => 'Direct']);
        TrafficSource::firstOrCreate(['source_name' => 'Google']);
        TrafficSource::firstOrCreate(['source_name' => 'Facebook']);
        TrafficSource::firstOrCreate(['source_name' => 'Instagram']);
        TrafficSource::firstOrCreate(['source_name' => 'Twitter']);

        // Products
        $product1 = Product::firstOrCreate(
            ['slug' => 'cairo-metal-t-shirt'],
            ['name' => 'Cairo-Metal T-Shirt', 'description' => 'Premium cotton t-shirt with Capital-Metal design', 'product_type' => 'physical', 'price_egp' => 299.00, 'price_usd' => 9.99, 'cost' => 100.00, 'status' => 'published', 'publish_date' => now()]
        );

        Inventory::firstOrCreate(
            ['product_id' => $product1->id],
            ['sku' => 'CAPITAL-METAL-TS-001', 'stock_quantity' => 100, 'low_stock_alert' => 10, 'warehouse_location' => 'Warehouse A']
        );

        $product2 = Product::firstOrCreate(
            ['slug' => 'cairo-metal-mug'],
            ['name' => 'Cairo-Metal Mug', 'description' => 'Ceramic mug with Capital-Metal logo', 'product_type' => 'physical', 'price_egp' => 149.00, 'price_usd' => 4.99, 'cost' => 50.00, 'status' => 'published', 'publish_date' => now()]
        );

        Inventory::firstOrCreate(
            ['product_id' => $product2->id],
            ['sku' => 'CAPITAL-METAL-MG-001', 'stock_quantity' => 200, 'low_stock_alert' => 20, 'warehouse_location' => 'Warehouse A']
        );

        Product::firstOrCreate(
            ['slug' => 'cairo-metal-template'],
            ['name' => 'Cairo-Metal Template', 'description' => 'Digital design template pack', 'product_type' => 'digital', 'price_egp' => 499.00, 'price_usd' => 14.99, 'cost' => 0, 'status' => 'published', 'publish_date' => now()]
        );

        // Cart for test user
        $cart = Cart::firstOrCreate(['user_id' => $user->id]);
        $cart->items()->firstOrCreate(['product_id' => $product1->id], ['quantity' => 2]);
        $cart->items()->firstOrCreate(['product_id' => $product2->id], ['quantity' => 1]);

        // Address for test user
        Address::firstOrCreate(
            ['user_id' => $user->id, 'is_default' => true],
            ['full_name' => 'Regular User', 'phone' => '01000000002', 'country' => 'Egypt', 'governorate' => 'Cairo', 'city' => 'New Cairo', 'address_line' => '123 Main Street, Apartment 5', 'postal_code' => '11835']
        );

        $this->call(TicketWorkflowSeeder::class);
        $this->call(MaterialSeeder::class);
    }
}
