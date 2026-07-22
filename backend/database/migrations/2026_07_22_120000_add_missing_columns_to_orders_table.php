<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->string('guest_token')->nullable()->after('user_id');
            $table->string('guest_governorate')->nullable()->after('guest_phone');
            $table->string('guest_city')->nullable()->after('guest_governorate');
            $table->string('guest_address_line')->nullable()->after('guest_city');
            $table->string('guest_postal_code')->nullable()->after('guest_address_line');
            $table->unsignedBigInteger('address_id')->nullable()->after('guest_postal_code');
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn([
                'guest_token', 'guest_governorate', 'guest_city',
                'guest_address_line', 'guest_postal_code', 'address_id',
            ]);
        });
    }
};
