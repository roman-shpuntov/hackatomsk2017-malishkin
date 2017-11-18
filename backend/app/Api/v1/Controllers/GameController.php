<?php
namespace App\Api\V1\Controllers;

use App\GameNotifier;
use App\Http\Controllers\Controller;
use App\Models\User;
use App\Requests\GameOfferRequest;
use App\Requests\StepRequest;
use App\Services\GameOfferService;
use App\Services\GameService;
use Auth;

/**
 * Контроллер игрового процесса
 */
class GameController extends Controller
{
    /**
     * Push-уведомления по игре
     * @var GameNotifier
     */
    private $notifier;

    /**
     * @var GameOfferService
     */
    private $offerSvc;

    /**
     * @var GameService
     */
    private $gameSvc;

    /**
     * @param GameNotifier     $notifier
     * @param GameOfferService $offerSvc
     * @param GameService      $gameSvc
     */
    public function __construct(GameNotifier $notifier, GameOfferService $offerSvc, GameService $gameSvc)
    {
        $this->notifier = $notifier;
        $this->offerSvc = $offerSvc;
        $this->gameSvc = $gameSvc;
    }

    /**
     * Предложение пользователя поиграть
     *
     * Юзер в запросе указывает тип игры и ставку, на какие деньги он хочет сыграть. Сервер либо найдет сразу
     * подходящего оппонента, либо добавит его предложение в список ожидающих ответа.
     *
     * TODO поиск предложения (там есть удаление записи) и создание новой игры должны быть в транзакции БД.
     * Но я не знаю, как бы ее запустить корректно. Не в контроллере это делается, факт. Но и в разных сервисах тоже
     * не сделать управление одной транзакцией. Вопрос открыт.
     *
     * @param GameOfferRequest $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function gameOffer(GameOfferRequest $request)
    {
        /** @var User $user */
        $user = Auth::user();

        $offer = $this->offerSvc->searchGame($user->id, $request['type'], $request['bet']);

        if ($offer) {
            $game = $this->gameSvc->newGame($offer, $user, config('game.field_size'));

            $gameInfo = [
                'game_id'  => $game->id,
                'prize'    => $game->prize,
                'users'    => $game->users->toArray(),
                'snapshot' => $game->snapshot,
            ];

            $this->notifier->offerAccepted($offer->game_key, $gameInfo);

            return response()->json([
                'channel'   => $this->notifier->getChannelName($offer->game_key),
                'game_info' => $gameInfo,
            ]);
        } else {
            $gameKey = $this->offerSvc->addOffer($user->id, $request['type'], $request['bet']);
            return response()->json(['channel' => $this->notifier->getChannelName($gameKey)]);
        }
    }

    /**
     * Ход игрока
     * @param StepRequest $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function step(StepRequest $request)
    {
        $params = array_values($request->only('game_id', 'user_id', 'from', 'to'));
        $this->gameSvc->step(...$params);
    }
}
