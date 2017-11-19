<?php
namespace App\Services;

use App\Enums\CellStates;
use App\Models\Game;
use App\Models\GameOffer;
use App\Models\Transaction;
use App\Models\User;
use \Cache;
use \DB;

/**
 * Сервис игры
 */
class GameService
{
    /**
     * @var Game
     */
    private $game;

    /**
     * @var Transaction
     */
    private $transaction;

    /**
     * @var Transaction
     */
    private $user;

    /**
     * @param Game        $game
     * @param Transaction $transaction
     * @param User        $user
     */
    public function __construct(Game $game, Transaction $transaction, User $user)
    {
        $this->game = $game;
        $this->transaction = $transaction;
        $this->user = $user;
    }

    /**
     * Создание новой игры
     * @param GameOffer $offer предложение об игре от первого игрока
     * @param User      $user2 второй игрок
     * @param int       $size  размер поля, в клетках по стороне квадрата
     * @return Game
     * @throws \Exception
     */
    public function newGame(GameOffer $offer, User $user2, int $size): Game
    {
        $snapshot = $this->initGameField($offer->user_id, $user2->id, $size);

        DB::beginTransaction();
        try {
            $this->game->fill([
                'type'     => $offer->type,
                'prize'    => $offer->bet * 2,
                'snapshot' => json_encode($snapshot),
                'game_key' => $offer->game_key,
            ])->save();

            $this->game->users()->attach([$offer->user->id, $user2->id]);

            $this->creditOperation($this->game->id, $offer->user_id, -1 * $offer->bet);
            $this->creditOperation($this->game->id, $user2->id, -1 * $offer->bet);

            DB::commit();
        } catch (\Exception $e) {
            DB::rollback();
            throw $e;
        }

        return $this->game;
    }

    /**
     * Операция на игровом счете пользователя
     * @param int $gameId
     * @param int $userId
     * @param int $amount сумма операции
     */
    private function creditOperation(int $gameId, int $userId, int $amount): void
    {
        $this->transaction->create([
            'game_id' => $gameId,
            'user_id' => $userId,
            'amount'  => $amount,
        ]);

        $user = $this->user->find($userId);
        $user->credits = $user->credits + $amount;
        $user->save();
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
        $game = $this->game->find($gameId);
        $players = $game->users->pluck('user_id')->toArray();

        $snapshot = json_decode($game->snapshot, true);
        $field = &$snapshot['field'];
        $size = count($field);

        $this->calculateProfit($field, $userId, $from, $to, $size);

        $id = array_shift($players);
        $snapshot['turn_user_id'] = $id != $userId ? $id : $players[0];
        $game->snapshot = json_encode($snapshot);

        if (!$game->log) {
            $game->log = 'size:' . $size;
        }
        $game->log .= "|{$from}-{$to}";

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
    public function calculateProfit(array &$field, int $userId, string $from, string $to, int $size)
    {
        [$fromRow, $fromCol] = explode(':', $from);
        [$toRow, $toCol] = explode(':', $to);
        $jump = abs($fromRow - $toRow) == 2 || abs($fromCol - $toCol) == 2;
        if ($jump) {
            $field[$fromRow][$fromCol] = 0;
        }
        $field[$toRow][$toCol] = $userId;

        for ($row = max(0, $toRow - 1); $row <= min($size - 1, $toRow + 1); $row++) {
            for ($col = max(0, $toCol - 1); $col <= min($size - 1, $toCol + 1); $col++) {
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
     * Возможные ситуации: игроку некуда сходить, хотя пустые клетки есть - проиграл, нет пустых клеток - победит тот,
     * у кого больше фишек. Игрок потерял все фишки - проиграл.
     *
     * @param array $snapshot снимок поля
     * @return int
     */
    public function checkAnyWinner(array $snapshot): int
    {
        $field = $snapshot['field'];
        $userId = $snapshot['turn_user_id'];
        $size = count($field);

        $hasFreeSpace = function (int $curRow, int $curCol) use ($field, $size) {
            for ($row = max(0, $curRow - 2); $row <= min($size - 1, $curRow + 2); $row++) {
                for ($col = max(0, $curCol - 2); $col <= min($size - 1, $curCol + 2); $col++) {
                    if ($field[$row][$col] == 0) {
                        return true;
                    }
                }
            }
            return false;
        };

        $counts = [0 => 0];
        for ($row = 0; $row < $size; $row++) {
            for ($col = 0; $col < $size; $col++) {
                $cellState = $field[$row][$col];
                if ($cellState == $userId && $hasFreeSpace($row, $col)) {
                    return 0;
                }

                $counts[$cellState] = isset($counts[$cellState]) ? $counts[$cellState] + 1 : 1;
            }
        }

        $freeCellsCount = $counts[0];
        unset($counts[0]);

        if (count($counts) === 1) {
            $winnerId = array_flip($counts);
            $winnerId = array_pop($winnerId);
            return $winnerId;
        }

        $ids = array_keys($counts);
        $id2 = array_pop($ids);
        $id1 = array_pop($ids);
        $count2 = array_pop($counts);
        $count1 = array_pop($counts);

        if ($freeCellsCount == 0) {
            return $count1 > $count2 ? $id1 : $id2;
        } else {
            return $id1 == $userId ? $id2 : $id1;
        }
    }

    /**
     * Обработчик окончания игры
     *
     * Если игра была на игровые деньги - правим транзакцию.
     *
     * @param int $gameId
     * @param int $winnerId
     * @throws \Exception
     */
    public function gameEndedHandler(int $gameId, int $winnerId)
    {
        /** @var Game $game */
        $game = $this->game->find($gameId);
        $userIds = $game->users->pluck('user_id')->toArray();

        DB::beginTransaction();
        try {
            $game->winner_id = $winnerId;
            $game->save();
            $uid = $userIds[0] == $winnerId ? $userIds[0] : $userIds[1];
            $this->creditOperation($game->id, $uid, $game->prize);
            DB::commit();
        } catch (\Exception $e) {
            DB::rollback();
            throw $e;
        }
    }
}
