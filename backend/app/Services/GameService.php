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
     * Снимок поля. Внутренний кеш класса
     * @var array [turn => user id, field = array]
     */
    private $snapshot;

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
     *
     * Поле кешируется на полчаса. Должно хватить на одну игру
     *
     * @param int $gameId id игры
     * @param int $userId1  id игрока, чья очередь ходить
     * @param int $userId2  id второго игрока
     * @param int $size   размер поля, в клетках по стороне квадрата
     * @return array
     */
    public function initGameField(int $gameId, int $userId1, int $userId2, int $size): array
    {
        $field = array_fill(0, $size, (array_fill(0, $size, 0)));
        $max = $size - 1;
        $field[0][$max] = $field[$max][0] = $userId1;
        $field[0][0] = $field[$max][$max] = $userId2;

        $snapshot = [
            'turn_user_id' => $userId1,
            'field'        => $field,
        ];

        $this->updateSnapshotCache($gameId, $snapshot);

        return $snapshot;
    }

    /**
     * Название ключа в кеше: снимок поля игры
     * @param int $gameId
     * @return string
     */
    private function getGameCacheKey(int $gameId): string
    {
        return 'game-' . $gameId;
    }

    /**
     * Обновление кеша снимка поля
     * @param int   $gameId
     * @param array $snapshot
     */
    private function updateSnapshotCache(int $gameId, array $snapshot): void
    {
        Cache::put($this->getGameCacheKey($gameId), json_encode($snapshot), 30);
    }

    /**
     * Чтение снимка поля из кеша
     * @param int $gameId
     * @return null|array [turn => user id, field = array]
     */
    private function readSnapshotFromCache(int $gameId): ?array
    {
        $snapshot = Cache::get($this->getGameCacheKey($gameId));
        return $snapshot ? json_decode($snapshot, true) : null;
    }

    /**
     * Получение текущего снимка поля
     * @param int $gameId
     * @return array
     */
    public function getSnapshot(int $gameId): array
    {
        $snapshot = $this->readSnapshotFromCache($gameId);
        if (!$snapshot) {
            $log = optional($this->model->find($gameId))->log;
            $snapshot = $this->rebuildFieldByLog($gameId, $log);
        }
        return $snapshot;
    }

    /**
     * Восстановить снимок поля по логу игры
     * @param int         $gameId
     * @param string|null $log
     * @return array
     */
    public function rebuildFieldByLog(int $gameId, ?string $log): array
    {
        // TODO распасить лог, проиграть его весь над полем, определить, чей ход, записать в кеш и вернуть результат
        return $this->initGameField($gameId, 0, config('game.field_size'));
    }
}
