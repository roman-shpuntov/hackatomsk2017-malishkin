<?php
namespace App\Services;

use App\Enums\CellStates;
use App\Models\Game;
use App\Models\GameOffer;
use App\Models\User;
use \Cache;

/**
 * Сервис игры
 */
class GameService
{
    /**
     * @var Game
     */
    private $model;

    /**
     * @param Game $model
     */
    public function __construct(Game $model)
    {
        $this->model = $model;
    }

    /**
     * Создание новой игры
     * @param GameOffer $offer предложение об игре от первого игрока
     * @param User      $user2 второй игрок
     * @return Game
     */
    public function newGame(GameOffer $offer, User $user2): Game
    {
        $this->model->fill([
            'type'     => $offer->type,
            'prize'    => $offer->bet * 2,
            'is_ended' => 0,
        ])->save();

        $this->model->users()->attach([$offer->user->id, $user2->id]);

        return $this->model;
    }

    /**
     * Инициализация игрового поля
     * @param int $gameId id игры
     * @param int $size размер поля, в клетках по стороне квадрата
     * @return string json
     */
    public function initGameField(int $gameId, int $size): string
    {
        $field = array_fill(0, $size, (array_fill(0, $size, CellStates::FREE)));
        $max = $size - 1;
        $field[0][$max] = $field[$max][0] = CellStates::ONE;
        $field[0][0] = $field[$max][$max] = CellStates::TWO;

        $field = json_encode($field);

        Cache::put($gameId, $field, 60);

        return $field;
    }
}
