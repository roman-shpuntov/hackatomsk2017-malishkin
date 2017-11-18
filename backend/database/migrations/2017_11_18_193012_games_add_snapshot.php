<?php

use Illuminate\Database\Migrations\Migration;

/**
 * Поле для хранения снимка поля
 */
class GamesAddSnapshot extends Migration
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
            ADD COLUMN `snapshot` TEXT NULL COMMENT 'Снимок поля' AFTER `is_ended`"
        );
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        DB::statement("ALTER TABLE `games` DROP COLUMN `snapshot`");
    }
}
