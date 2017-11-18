<?php
namespace App\Services;

use App\Enums\CellStates;
use App\Models\Game;
use App\Models\GameOffer;
use App\Models\User;
use \Cache;
use Illuminate\Validation\ValidationException;

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
     * @param int $turn   id игрока, чья очередь ходить
     * @param int $size   размер поля, в клетках по стороне квадрата
     * @return array
     */
    public function initGameField(int $gameId, int $turn, int $size): array
    {
        $field = array_fill(0, $size, (array_fill(0, $size, CellStates::FREE)));
        $max = $size - 1;
        $field[0][$max] = $field[$max][0] = CellStates::ONE;
        $field[0][0] = $field[$max][$max] = CellStates::TWO;

        $snapshot = [
            'turn_user_id' => $turn,
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
     * @return array [turn => user id, field = array]
     */
    private function readSnapshotFromCache(int $gameId): array
    {
        $snapshot = Cache::get($this->getGameCacheKey($gameId));
        return json_decode($snapshot, true);
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
     * @param int    $gameId
     * @param string $log
     * @return array
     */
    public function rebuildFieldByLog(int $gameId, string $log): array
    {
        // TODO распасить лог, проиграть его весь над полем, определить, чей ход, записать в кеш и вернуть результат
        return $this->initGameField($gameId, 0, config('game.field_size'));
    }

    /**
     * Проверка хода пользователя
     *
     * Проверки: сейчас ход игрока; можно ходить, куда указал юзер.
     *
     * TODO Хреновое решение. ЭТо как бы валидация, надо возращать ValidationException. Или валидировать в другом месте.
     *
     * @param int    $gameId id игры
     * @param int    $userId id игрока, делающего ход
     * @param string $from   откуда двигает фишку, формат x:y
     * @param string $to     куда двигает фишку, формат x:y
     * @return mixed сообщение об ошибке или TRUE
     */
    public function isStepAllowed(int $gameId, int $userId, string $from, string $to)
    {
        $snapshot = $this->getSnapshot($gameId);
        if ($snapshot['turn_user_id'] != $userId) {
            return 'Not your turn now';
        }

        $field = $snapshot['field'];

        [$fromX, $fromY] = explode(':', $from);
        if (!isset($field[$fromX][$fromY]) || $field[$fromX][$fromY] != $userId) {
            return 'You try to move not your chip';
        }

        [$toX, $toY] = explode(':', $to);
        if (!isset($field[$toX][$toY]) || $field[$toX][$toY] != 0) {
            return 'You try to step to occupied cell';
        }

        if (abs($fromX - $toX) > 2 || abs($fromY - $toY) > 2) {
            return 'You try to step too far';
        }

        $this->snapshot = $snapshot;

        return true;
    }
}
