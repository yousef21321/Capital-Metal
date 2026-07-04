<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->string('guest_governorate', 100)->nullable()->after('guest_phone');
            $table->string('guest_city', 100)->nullable()->after('guest_governorate');
            $table->string('guest_address_line', 255)->nullable()->after('guest_city');
            $table->string('guest_postal_code', 20)->nullable()->after('guest_address_line');
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn(['guest_governorate', 'guest_city', 'guest_address_line', 'guest_postal_code']);
        });
    }
};
