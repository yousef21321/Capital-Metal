<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->decimal('platform_commission_egp', 12, 2)->nullable()->after('price_usd');
            $table->decimal('platform_commission_usd', 12, 2)->nullable()->after('platform_commission_egp');
            $table->decimal('designer_price_egp', 12, 2)->nullable()->after('platform_commission_usd');
            $table->decimal('designer_price_usd', 12, 2)->nullable()->after('designer_price_egp');
        });
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn(['platform_commission_egp', 'platform_commission_usd', 'designer_price_egp', 'designer_price_usd']);
        });
    }
};
