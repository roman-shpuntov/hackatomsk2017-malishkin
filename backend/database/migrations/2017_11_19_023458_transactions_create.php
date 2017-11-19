<?php

use Illuminate\Database\Migrations\Migration;

/**
 * Переводы между игровыми счетами пользователей
 */
class TransactionsCreate extends Migration
{
    /**
     * Run the migrations.
     * @return void
     */
    public function up()
    {
        DB::statement(
            "CREATE TABLE `transactions` (
                `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
                `game_id` INT UNSIGNED NOT NULL COMMENT 'игра, на основании которой выполнена операция',
                `user_id` INT UNSIGNED NOT NULL COMMENT 'пользователь, на чьем счету выполняется операция',
                `amount` INT NOT NULL COMMENT 'сумма операции',
                `created_at` TIMESTAMP NOT NULL COMMENT 'Когда была выполнена операция',
                PRIMARY KEY (`id`),
                INDEX `user` (`user_id` ASC),
                INDEX `created` (`created_at` ASC)
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
        DB::statement('DROP TABLE transactions');
    }
}
