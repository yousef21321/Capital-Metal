<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('material_manufacturing_method', function (Blueprint $table) {
            $table->id();
            $table->foreignId('material_id')->constrained()->cascadeOnDelete();
            $table->foreignId('manufacturing_method_id')->constrained()->cascadeOnDelete();
            $table->unique(['material_id', 'manufacturing_method_id'], 'mat_method_unique');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('material_manufacturing_method');
    }
};
