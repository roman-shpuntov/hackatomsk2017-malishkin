<?php
namespace App\Enums;

/**
 * Состояние клетки поля
 */
class CellStates extends Enum
{
    /**
     * Клетка занята первым игроком
     */
    const ONE = 1;

    /**
     * Клетка занята вторым игроком
     */
    const TWO = 2;

    /**
     * Клетка свободна для хода
     */
    const FREE = 0;
}
