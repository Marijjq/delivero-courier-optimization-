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
        Schema::create('assigned_routes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('admin_id')->constrained('users');
            $table->foreignId('user_id')->constrained('users');
            $table->string('title');
            $table->json('coordinates'); // [{lat: ..., lon: ...}, ...]
            $table->double('distance')->nullable();
            $table->integer('duration')->nullable();
            $table->timestamp('assigned_at');
            $table->timestamp('due_at')->nullable();
            $table->string('status')->default('assigned'); // assigned, in_progress, completed
            $table->text('note')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('assigned_routes');
    }
};
