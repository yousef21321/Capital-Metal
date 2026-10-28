<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('shipping_rates') && Schema::hasColumn('shipping_rates', 'region')) {
            return;
        }

        $existing = [];
        if (Schema::hasTable('shipping_rates')) {
            $existing = DB::table('shipping_rates')
                ->select(['governorate', 'cost'])
                ->get()
                ->map(fn ($rate) => [
                    'region' => 'Unassigned',
                    'governorate' => $rate->governorate,
                    'cost' => $rate->cost,
                    'created_at' => now(),
                    'updated_at' => now(),
                ])
                ->all();

            Schema::drop('shipping_rates');
        }

        Schema::create('shipping_rates', function (Blueprint $table) {
            $table->id();
            $table->string('region');
            $table->string('governorate');
            $table->decimal('cost', 8, 2);
            $table->timestamps();
        });

        if ($existing !== []) {
            DB::table('shipping_rates')->insert($existing);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('shipping_rates');
    }
};
