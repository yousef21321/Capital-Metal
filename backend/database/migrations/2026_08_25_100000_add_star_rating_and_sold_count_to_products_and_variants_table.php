<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->decimal('star_rating', 3, 2)->default(0)->after('fake_price_usd');
            $table->integer('sold_count')->default(0)->after('star_rating');
        });

        Schema::table('product_variants', function (Blueprint $table) {
            $table->decimal('star_rating', 3, 2)->default(0)->after('fake_price_usd');
            $table->integer('sold_count')->default(0)->after('star_rating');
        });
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn(['star_rating', 'sold_count']);
        });

        Schema::table('product_variants', function (Blueprint $table) {
            $table->dropColumn(['star_rating', 'sold_count']);
        });
    }
};
