<?php

namespace Database\Seeders;

use App\Models\Coupon;
use App\Models\User;
use App\Models\Wishlist;
use App\Models\Product;
use Illuminate\Database\Seeder;

class CouponWishlistSeeder extends Seeder
{
    public function run(): void
    {
        // ── Coupons ──
        $coupons = [
            [
                'code' => 'WELCOME10',
                'discount_type' => 'percentage',
                'discount_value' => 10,
                'min_order_amount' => null,
                'expiry_date' => now()->addMonths(3),
                'usage_limit' => 100,
                'used_count' => 0,
            ],
            [
                'code' => 'SAVE50',
                'discount_type' => 'fixed',
                'discount_value' => 50,
                'min_order_amount' => 200,
                'expiry_date' => now()->addMonths(2),
                'usage_limit' => 50,
                'used_count' => 3,
            ],
            [
                'code' => 'FLASH25',
                'discount_type' => 'percentage',
                'discount_value' => 25,
                'min_order_amount' => 500,
                'expiry_date' => now()->addWeek(),
                'usage_limit' => 20,
                'used_count' => 5,
            ],
            [
                'code' => 'FREESHIP',
                'discount_type' => 'fixed',
                'discount_value' => 50,
                'min_order_amount' => null,
                'expiry_date' => now()->addMonth(),
                'usage_limit' => null,
                'used_count' => 0,
            ],
            [
                'code' => 'MEGA100',
                'discount_type' => 'fixed',
                'discount_value' => 100,
                'min_order_amount' => 1000,
                'expiry_date' => now()->addDays(15),
                'usage_limit' => 10,
                'used_count' => 0,
            ],
            [
                'code' => 'EXPIRED20',
                'discount_type' => 'percentage',
                'discount_value' => 20,
                'min_order_amount' => null,
                'expiry_date' => now()->subDays(5),
                'usage_limit' => 50,
                'used_count' => 10,
            ],
            [
                'code' => 'LIMITMAX',
                'discount_type' => 'percentage',
                'discount_value' => 15,
                'min_order_amount' => null,
                'expiry_date' => now()->addMonths(6),
                'usage_limit' => 10,
                'used_count' => 10,
            ],
        ];

        foreach ($coupons as $data) {
            Coupon::firstOrCreate(['code' => $data['code']], $data);
        }

        // ── Wishlist ──
        $user = User::where('email', 'user@flfl.com')->first();
        $productIds = Product::pluck('id')->toArray();

        if ($user && $productIds) {
            $wishlistItems = array_slice($productIds, 0, 4);
            foreach ($wishlistItems as $pid) {
                Wishlist::firstOrCreate([
                    'user_id' => $user->id,
                    'product_id' => $pid,
                ]);
            }

            $industor = User::where('email', 'industor1@flfl.com')->first();
            if ($industor) {
                foreach (array_slice($productIds, 2, 3) as $pid) {
                    Wishlist::firstOrCreate([
                        'user_id' => $industor->id,
                        'product_id' => $pid,
                    ]);
                }
            }
        }
    }
}
