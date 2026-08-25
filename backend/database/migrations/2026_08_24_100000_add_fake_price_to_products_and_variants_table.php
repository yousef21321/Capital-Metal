<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->decimal('fake_price_egp', 12, 2)->nullable()->after('price_usd');
            $table->decimal('fake_price_usd', 12, 2)->nullable()->after('fake_price_egp');
        });

        Schema::table('product_variants', function (Blueprint $table) {
            $table->decimal('fake_price_egp', 12, 2)->nullable()->after('price_usd');
            $table->decimal('fake_price_usd', 12, 2)->nullable()->after('fake_price_egp');
        });
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn(['fake_price_egp', 'fake_price_usd']);
        });

        Schema::table('product_variants', function (Blueprint $table) {
            $table->dropColumn(['fake_price_egp', 'fake_price_usd']);
        });
    }
};
