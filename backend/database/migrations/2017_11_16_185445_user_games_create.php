<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class UserGamesCreate extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        DB::statement(
            "CREATE TABLE `user_games` (
                `user_id` INT UNSIGNED NOT NULL,
                `game_id` INT NOT NULL,
                PRIMARY KEY (`user_id`, `game_id`),
                INDEX `user` (`user_id` ASC),
                INDEX `game` (`game_id` ASC)
            ) 
            ENGINE = InnoDB"
        );
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        DB::statement('DROP TABLE user_games');
    }
}
