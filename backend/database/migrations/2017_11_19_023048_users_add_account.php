<?php
use Illuminate\Database\Migrations\Migration;

/**
 * Добавляем счета пользователям для учета игровой валюты
 */
class UsersAddAccount extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        DB::statement(
            "ALTER TABLE `users` 
            ADD COLUMN `credits` INT NULL COMMENT 'счет пользователя для учета игровой валюты' AFTER `remember_token`"
        );
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        DB::statement("ALTER TABLE `games` DROP COLUMN `credits`");
    }
}
