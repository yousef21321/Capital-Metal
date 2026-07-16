<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('hero_images', function (Blueprint $table) {
            $table->string('media_type')->default('image')->after('id');
            $table->string('video_url')->nullable()->after('media_type');
            $table->string('alt_text')->nullable()->after('video_url');
        });
    }

    public function down(): void
    {
        Schema::table('hero_images', function (Blueprint $table) {
            $table->dropColumn(['media_type', 'video_url', 'alt_text']);
        });
    }
};
