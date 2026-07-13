<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->decimal('tester_suggested_price_egp', 12, 2)->nullable()->after('designer_price_usd');
            $table->decimal('tester_suggested_price_usd', 12, 2)->nullable()->after('tester_suggested_price_egp');
            $table->text('tester_comment')->nullable()->after('tester_suggested_price_usd');
            $table->unsignedBigInteger('tested_by')->nullable()->after('tester_comment');
            $table->timestamp('tested_at')->nullable()->after('tested_by');

            $table->foreign('tested_by')->references('id')->on('users')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropForeign(['tested_by']);
            $table->dropColumn(['tester_suggested_price_egp', 'tester_suggested_price_usd', 'tester_comment', 'tested_by', 'tested_at']);
        });
    }
};
