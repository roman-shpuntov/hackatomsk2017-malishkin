<?php

use Illuminate\Database\Migrations\Migration;

class GamesAddKey extends Migration
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
            ADD COLUMN `game_key` CHAR(6) NOT NULL COMMENT 'Снимок поля' AFTER `log`"
        );
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        DB::statement("ALTER TABLE `games` DROP COLUMN `game_key`");
    }
}
