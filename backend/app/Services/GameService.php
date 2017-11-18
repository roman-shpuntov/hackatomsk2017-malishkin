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
     * @param int       $size  размер поля, в клетках по стороне квадрата
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
     * @param int $userId1 id игрока, чья очередь ходить
     * @param int $userId2 id второго игрока
     * @param int $size    размер поля, в клетках по стороне квадрата
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
     * Ход игрока
     *
     * Просчитать профит, обновить снимок поля, записать в снимок и лог в БД
     *
     * @param int    $gameId id игры
     * @param int    $userId id игрока, делающего ход
     * @param string $from   координаты, откуда делается ход
     * @param string $to     координаты, куда ходит игрок
     * @return array
     */
    public function step(int $gameId, int $userId, string $from, string $to): array
    {
        /** @var Game $game */
        $game = $this->model->find($gameId);
        $players = $game->users->pluck('user_id');

        $snapshot = json_decode($game->snapshot, true);
        $field = &$snapshot['field'];
        $size = count($field);

        $this->calculateStepResult($field, $userId, $from, $to, $size);

        $snapshot['turn_user_id'] = array_shift($players) != $userId ?: $players[0];
        $game->snapshot = json_encode($snapshot);

        if (!$game->log) {
            $game->log = 'size:' . $size;
        }
        $game->log .= "|{from}-{$to}";

        $game->save();

        return $snapshot;
    }

    /**
     * Пересчет поля при ходе игрока: перемещение или копирование фишки; переворот всех соседних фишек противника
     *
     * Внимание: метод публичный только для покрытия unit-тестом. Реальный вызов вне класса не предполагается.
     *
     * @param array  $field  матрица поля
     * @param int    $userId id игрока, делающего ход
     * @param string $from   координаты, откуда делается ход
     * @param string $to     координаты, куда ходит игрок
     * @param int    $size   размер поля, в клетках по стороне квадрата
     */
    public function calculateStepResult(array &$field, int $userId, string $from, string $to, int $size)
    {
        [$fromRow, $fromCol] = explode(':', $from);
        [$toRow, $toCol] = explode(':', $to);
        $jump = abs($fromRow - $toRow) == 2 || abs($fromCol - $toCol) == 2;
        if ($jump) {
            $field[$fromRow][$fromCol] = 0;
        }
        $field[$toRow][$toCol] = $userId;

        for ($row = max(0, $toRow - 1); $row <= min($size, $toRow + 1); $row++) {
            for ($col = max(0, $toCol - 1); $col <= min($size, $toCol + 1); $col++) {
                $cellState = &$field[$row][$col];
                if ($cellState) {
                    $cellState = $userId;
                }
            }
        }
    }

    /**
     * Проверить, сможет ли ходить другой игрок или игра окончена.
     *
     * Если вычисление определит победителя, возвращаем его id, иначе - 0
     *
     * @param array $snapshot снимок поля
     * @return int
     */
    public function hasWinner(array $snapshot): int
    {
        // TODO
    }
}
