<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('tickets', function (Blueprint $table) {
            $table->decimal('original_price', 12, 2)->nullable()->after('price');
            $table->decimal('industor_price', 12, 2)->nullable()->after('original_price');
            $table->decimal('designer_price', 12, 2)->nullable()->after('industor_price');
            $table->timestamp('price_updated_at')->nullable()->after('designer_price');
            $table->boolean('urgent_price_applied')->default(false)->after('price_updated_at');
        });

        Schema::create('ticket_price_history', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->foreignId('ticket_id')->constrained('tickets')->cascadeOnDelete();
            $table->decimal('original_price', 12, 2)->nullable();
            $table->decimal('industor_price', 12, 2)->nullable();
            $table->decimal('designer_price', 12, 2)->nullable();
            $table->string('change_reason', 30)->default('normal');
            $table->timestamp('created_at')->useCurrent();

            $table->index('ticket_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ticket_price_history');

        Schema::table('tickets', function (Blueprint $table) {
            $table->dropColumn([
                'original_price', 'industor_price', 'designer_price',
                'price_updated_at', 'urgent_price_applied',
            ]);
        });
    }
};
