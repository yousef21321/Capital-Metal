<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->string('material', 100)->nullable()->after('country_availability');
            $table->string('manufacturing_method', 100)->nullable()->after('material');
            $table->json('tags')->nullable()->after('manufacturing_method');
        });
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn(['material', 'manufacturing_method', 'tags']);
        });
    }
};
