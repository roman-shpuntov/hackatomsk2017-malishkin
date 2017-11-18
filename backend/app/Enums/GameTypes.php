<?php
namespace App\Enums;

/**
 * Типы игры: бесплатная, с фиксированной ставкой, с произвольной ставкой
 */
class GameTypes extends Enum
{
    const
        FREE = 'free',
        FIXED_BET = 'fixed_bet',
        FLOAT_BET = 'float_bet';
}
