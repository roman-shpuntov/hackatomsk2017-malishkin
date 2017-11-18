<?php
namespace App\Services;

use App\Enums\CellStates;
use App\Models\Game;
use App\Models\GameOffer;
use App\Models\User;

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

        $this->initGameField($this->model->id, config('game.field_size'));

        return $this->model;
    }
}
