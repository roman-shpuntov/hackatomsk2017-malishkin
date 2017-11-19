<?php
namespace App\Api\V1\Controllers;

use App\GameNotifier;
use App\Http\Controllers\Controller;
use App\Models\User;
use App\Requests\CancelRequest;
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

            $response = [
                'game_info' => [
                    'game_id'  => $game->id,
                    'game_key' => $game->game_key,
                    'prize'    => $game->prize,
                    'users'    => $game->users->toArray(),
                    'snapshot' => json_decode($game->snapshot, true),
                ],
            ];

            $this->notifier->offerAccepted($offer->game_key, $response);

            $response['channel'] = $this->notifier->getChannelName($offer->game_key);
            return response()->json($response);
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
        $snapshot = $this->gameSvc->step(...$params);

        $gameKey = $request->get('game_key');

        if ($winnerId = $this->gameSvc->checkAnyWinner($snapshot)) {
            $this->gameSvc->gameEndedHandler($request->get('game_id'), $winnerId);
            $this->notifier->gameEnded($gameKey, $winnerId);
            return response()->json(['game_ended' => $winnerId]);
        }

        $snapshot = compact('snapshot');
        $this->notifier->gridUpdated($gameKey, $snapshot);
        return response()->json($snapshot);
    }

    /**
     * Отмена игры
     * @param CancelRequest $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function cancelGame(CancelRequest $request)
    {
        $this->gameSvc->cancelGame($request->get('game_id'), $request->get('user_id'));
        $this->notifier->gameCanceled($request->get('gameKey'), $request->get('user_id'));
        return response()->json(['success' => 'You canceled the game.']);
    }
}
