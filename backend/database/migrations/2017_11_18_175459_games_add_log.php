<?php

use Illuminate\Database\Migrations\Migration;

/**
 * Лог игры
 */
class GamesAddLog extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        DB::statement(
            "ALTER TABLE `games` 
            ADD COLUMN `log` TEXT NULL COMMENT 'Лог игры' AFTER `is_ended`"
        );
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        DB::statement("ALTER TABLE `games` DROP COLUMN `log`");
    }
}
