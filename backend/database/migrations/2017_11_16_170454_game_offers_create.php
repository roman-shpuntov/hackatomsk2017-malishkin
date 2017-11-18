<?php
use Illuminate\Database\Migrations\Migration;

class GameOffersCreate extends Migration
{
    /**
     * Run the migrations.
     * @return void
     */
    public function up()
    {
        DB::statement(
            'CREATE TABLE `game_offers` (
                `id` BIGINT NOT NULL AUTO_INCREMENT,
                `user_id` INT UNSIGNED NOT NULL,
                `type` ENUM("free", "fixed_bet", "float_bet") NOT NULL 
                    COMMENT "тип игры: бесплатная, с фиксированной ставкой, с произвольной ставкой",
                `bet` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT "ставка в игре",
                `game_key` CHAR(6) NOT NULL 
                    COMMENT "случайная последовательность, ключ созданного предложения об игре", 
                `created_at` TIMESTAMP NOT NULL COMMENT "когда было создано предложение",
                PRIMARY KEY (`id`),
                INDEX `type_bet` (`type` ASC, `bet` ASC)
            ) 
            ENGINE = InnoDB'
        );
    }

    /**
     * Reverse the migrations.
     * @return void
     */
    public function down()
    {
        DB::statement('DROP TABLE game_offers');
    }
}
