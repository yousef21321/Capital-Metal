<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->string('lemonsqueezy_product_id', 50)->nullable()->after('stox_product_id');
            $table->string('lemonsqueezy_variant_id', 50)->nullable()->after('lemonsqueezy_product_id');
        });
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn(['lemonsqueezy_product_id', 'lemonsqueezy_variant_id']);
        });
    }
};
