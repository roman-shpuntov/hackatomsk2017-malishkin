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
     * @param string $gameKey защитный ключ игры
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

    public function gridUpdated()
    {
        // TODO
    }

    public function gameEnded()
    {
        // TODO
    }
}
