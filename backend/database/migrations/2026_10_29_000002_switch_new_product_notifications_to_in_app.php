<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasColumn('users', 'whatsapp_product_updates')
            || Schema::hasColumn('users', 'whatsapp_product_updates_at')) {
            Schema::table('users', function (Blueprint $table) {
                $columns = [];
                if (Schema::hasColumn('users', 'whatsapp_product_updates')) {
                    $columns[] = 'whatsapp_product_updates';
                }
                if (Schema::hasColumn('users', 'whatsapp_product_updates_at')) {
                    $columns[] = 'whatsapp_product_updates_at';
                }
                if ($columns !== []) {
                    $table->dropColumn($columns);
                }
            });
        }

        if (Schema::hasColumn('products', 'whatsapp_announced_at')
            && ! Schema::hasColumn('products', 'new_product_notification_queued_at')) {
            Schema::table('products', function (Blueprint $table) {
                $table->renameColumn('whatsapp_announced_at', 'new_product_notification_queued_at');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('products', 'new_product_notification_queued_at')
            && ! Schema::hasColumn('products', 'whatsapp_announced_at')) {
            Schema::table('products', function (Blueprint $table) {
                $table->renameColumn('new_product_notification_queued_at', 'whatsapp_announced_at');
            });
        }
    }
};
