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
     * @param int       $size размер поля, в клетках по стороне квадрата
     * @return Game
     */
    public function newGame(GameOffer $offer, User $user2, int $size): Game
    {
        $snapshot = $this->initGameField($offer->user_id, $user2->id, $size);

        $this->model->fill([
            'type'     => $offer->type,
            'prize'    => $offer->bet * 2,
            'is_ended' => 0,
            'snapshot' => json_encode($snapshot),
        ])->save();

        $this->model->users()->attach([$offer->user->id, $user2->id]);

        return $this->model;
    }

    /**
     * Инициализация игрового поля
     * @param int  $userId1 id игрока, чья очередь ходить
     * @param int  $userId2 id второго игрока
     * @param int  $size    размер поля, в клетках по стороне квадрата
     * @return array
     */
    public function initGameField(int $userId1, int $userId2, int $size): array
    {
        $field = array_fill(0, $size, (array_fill(0, $size, 0)));
        $max = $size - 1;
        $field[0][$max] = $field[$max][0] = $userId1;
        $field[0][0] = $field[$max][$max] = $userId2;

        return [
            'turn_user_id' => $userId1,
            'field'        => $field,
        ];
    }

    /**
     * Получение текущего снимка поля
     *
     * Прим: в нормальной ситуации не может быть такого, что снимка поля нет. Первый снимок созается при создании игры
     *
     * @param int $gameId
     * @return array
     */
    public function getSnapshot(int $gameId): array
    {
        $snapshot = $this->model->find($gameId)->snapshot;
        return json_decode($snapshot, true);
    }
}
