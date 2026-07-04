<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tickets', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->foreignId('industor_id')->constrained('users')->cascadeOnDelete();
            $table->unsignedBigInteger('subscription_id')->nullable();
            $table->foreign('subscription_id')->references('id')->on('user_subscriptions')->nullOnDelete();
            $table->string('title', 200);
            $table->text('description');
            $table->string('status', 30)->default('new');
            $table->unsignedBigInteger('tester_id')->nullable();
            $table->unsignedBigInteger('designer_id')->nullable();
            $table->foreign('tester_id')->references('id')->on('users')->nullOnDelete();
            $table->foreign('designer_id')->references('id')->on('users')->nullOnDelete();
            $table->timestamp('deadline')->nullable();
            $table->timestamp('reviewed_at')->nullable();
            $table->timestamp('approved_at')->nullable();
            $table->timestamp('assigned_at')->nullable();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('uploaded_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->boolean('is_published_to_store')->default(false);
            $table->unsignedBigInteger('store_listing_id')->nullable();
            $table->timestamps();

            $table->index('status');
            $table->index('industor_id');
            $table->index('designer_id');
            $table->index('tester_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tickets');
    }
};
