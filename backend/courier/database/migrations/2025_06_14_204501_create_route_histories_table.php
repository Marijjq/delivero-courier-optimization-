<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('route_histories', function (Blueprint $table) {
            $table->id();
        $table->foreignId('user_id')->constrained()->onDelete('cascade');

        // Start location
        $table->string('start_location_name');
        $table->decimal('start_latitude', 10, 7);
        $table->decimal('start_longitude', 10, 7);

        // End location
        $table->string('end_location_name');
        $table->decimal('end_latitude', 10, 7);
        $table->decimal('end_longitude', 10, 7);

        $table->decimal('distance', 8, 2); // in kilometers
        $table->integer('duration'); // in minutes
        $table->timestamp('completed_at')->nullable();
        $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('route_histories');
    }
};
