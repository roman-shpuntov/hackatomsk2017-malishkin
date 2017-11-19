<?php
namespace App\Validators;

use App\Models\Game;
use Illuminate\Validation\Validator;

/**
 * Проверки: игра доступна указанному юзеру; игра не окончена
 *
 * Название валидатора: game_allowed
 */
class GameAllowedValidator
{
    /**
     * @var Game
     */
    private $game;

    /**
     * @param Game $game
     */
    public function __construct(Game $game)
    {
        $this->game = $game;
    }

    /**
     * проверки: игра доступна указанному юзеру; игра не окончена
     * @param string    $attribute  название параметра в запросе
     * @param int       $gameId id игры
     * @param array     $parameters доп.параметры: ожидаем user id
     * @param validator $validator
     * @return bool
     */
    public function validate(string $attribute, int $gameId, array $parameters, Validator $validator): bool
    {
        $userId = array_get($parameters, 0);
        $game = $this->game->find($gameId);
        return $game && !$game->winner_id && $game->users->contains('user_id', $userId);
    }

    /**
     * Сообщение об ошибке. Без конкретизации причины отказа
     * @return string
     */
    public static function errorMessage(): string
    {
        return 'Game not allowed for user';
    }
}
