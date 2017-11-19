<?php
namespace App;

use Pusher\Pusher;

/**
 * Push-уведомления о процессе игры. Упрощенная версия Laravel events, специально под отправку в основном потоке
 * приложения, с минимальными задержками на обработке.
 */
class  GameNotifier
{
    const CHANNEL_PREFIX = 'game-';

    /**
     * @var Pusher
     */
    private $pusher;

    /**
     * Инициализируем класс Pusher (pusher.com)
     */
    public function __construct()
    {
        $conf = config('broadcasting.connections.pusher');
        $this->pusher = new Pusher(
            $conf['key'],
            $conf['secret'],
            $conf['app_id'],
            $conf['options']
        );
    }

    /**
     * Получение названия канала игры
     * @param string $gameKey защитный ключ игры
     * @return string
     */
    public function getChannelName(string $gameKey): string
    {
        return self::CHANNEL_PREFIX . $gameKey;
    }

    /**
     * Уведомление игроку, предложившему игру о том, что его предложение принято и игра создана
     * @param string $gameKey  защитный ключ игры
     * @param array  $gameInfo минимальная инфа об игре
     */
    public function offerAccepted(string $gameKey, array $gameInfo): void
    {
        $this->pusher->trigger(
            $this->getChannelName($gameKey),
            'offer-accepted',
            $gameInfo
        );
    }

    /**
     * Поле пересчитано после хода игрока. Сообщаем другому игроку об этом.
     * @param string $gameKey  защитный ключ игры
     * @param array  $snapshot снимок поля
     */
    public function gridUpdated(string $gameKey, array $snapshot)
    {
        $this->pusher->trigger(
            $this->getChannelName($gameKey),
            'grid-updated',
            $snapshot
        );
    }

    /**
     * Игра окончена, объявляем победителя
     * @param string $gameKey  защитный ключ игры
     * @param int    $winnerId id победителя
     */
    public function gameEnded(string $gameKey, int $winnerId)
    {
        $this->pusher->trigger(
            $this->getChannelName($gameKey),
            'game-ended',
            ['winner' => $winnerId]
        );
    }

    /**
     * Игра отменена указанным пользователем
     * @param string $gameKey     защитный ключ игры
     * @param int    $initiatorId id юзера, отменившего игру
     */
    public function gameCanceled(string $gameKey, int $initiatorId)
    {
        $this->pusher->trigger(
            $this->getChannelName($gameKey),
            'game-canceled',
            ['initiator' => $initiatorId]
        );
    }
}
