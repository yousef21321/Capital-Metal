<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (! Schema::hasColumn('users', 'whatsapp_product_updates')) {
                $table->boolean('whatsapp_product_updates')->default(false)->index();
            }
            if (! Schema::hasColumn('users', 'whatsapp_product_updates_at')) {
                $table->timestamp('whatsapp_product_updates_at')->nullable();
            }
        });

        Schema::table('products', function (Blueprint $table) {
            if (! Schema::hasColumn('products', 'whatsapp_announced_at')) {
                $table->timestamp('whatsapp_announced_at')->nullable();
            }
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (Schema::hasColumn('users', 'whatsapp_product_updates')) {
                $table->dropIndex(['whatsapp_product_updates']);
                $table->dropColumn('whatsapp_product_updates');
            }
            if (Schema::hasColumn('users', 'whatsapp_product_updates_at')) {
                $table->dropColumn('whatsapp_product_updates_at');
            }
        });

        Schema::table('products', function (Blueprint $table) {
            if (Schema::hasColumn('products', 'whatsapp_announced_at')) {
                $table->dropColumn('whatsapp_announced_at');
            }
        });
    }
};
