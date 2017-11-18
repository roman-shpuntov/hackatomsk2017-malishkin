<?php
namespace App\Events;

use Illuminate\Queue\SerializesModels;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;

/**
 * Уведомление об обновлении игрового поля
 */
class GridUpdatedEvent implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    /**
     * Текущее состояние игрового поля
     *
     * Важно: только публичные свойства класса будут сериализованы и отправлены в Pusher
     *
     * @var array
     */
    public $grid;

    /**
     * Id игры
     * @var int
     */
    private $gameId;

    /**
     * Create a new event instance.
     * @param array $grid   текущее состояние игрового поля
     * @param int   $gameId id игры
     */
    public function __construct(array $grid, int $gameId)
    {
        $this->grid = $grid;
        $this->gameId = $gameId;
    }

    /**
     * Get the channels the event should broadcast on.
     * @return \Illuminate\Broadcasting\Channel|array
     */
    public function broadcastOn()
    {
        return new PrivateChannel('game-' . $this->gameId);
    }
}
