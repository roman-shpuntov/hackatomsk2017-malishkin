<?php

use Illuminate\Database\Migrations\Migration;

class GamesAddWinner extends Migration
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
            ADD COLUMN `winner_id` INT UNSIGNED NULL COMMENT 'id победителя' AFTER `prize`,
            DROP COLUMN `is_ended`"
        );
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        DB::statement(
            "ALTER TABLE `games` 
            DROP COLUMN `winner_id`,
            ADD COLUMN `is_ended` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Игра окончена?' AFTER `prize`"
        );
    }
}
