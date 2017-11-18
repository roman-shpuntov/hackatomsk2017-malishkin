<?php

use Illuminate\Database\Migrations\Migration;

class GamesCreate extends Migration
{
    /**
     * Run the migrations.
     * @return void
     */
    public function up()
    {
        DB::statement(
            "CREATE TABLE `games` (
                `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
                `type` ENUM('free', 'fixed_bet', 'float_bet') NOT NULL COMMENT 'тип игры',
                `prize` INT(11) UNSIGNED NOT NULL COMMENT 'сумма приза' ,
                `is_ended` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Игра окончена?',
                `created_at` TIMESTAMP NOT NULL COMMENT 'Когда была создана игра',
                PRIMARY KEY (`id`)
            )
            ENGINE = InnoDB"
        );
    }

    /**
     * Reverse the migrations.
     * @return void
     */
    public function down()
    {
        DB::statement('DROP TABLE games');
    }
}
