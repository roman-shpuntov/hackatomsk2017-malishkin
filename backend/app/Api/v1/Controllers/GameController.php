<?php
namespace App\Api\V1\Controllers;

use App\Http\Controllers\Controller;
use App\Requests\GameOfferRequest;
use App\Services\GameOfferService;
use Auth;

/**
 * Контроллер игрового процесса
 */
class GameController extends Controller
{
    /**
     * @var GameOfferService
     */
    private $offerSvc;

    /**
     * @param GameOfferService $offerSvc
     */
    public function __construct(GameOfferService $offerSvc)
    {
        $this->offerSvc = $offerSvc;
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
        $user = Auth::user();

        $offer = $this->offerSvc->searchGame($user->id, $request['type'], $request['bet']);

        if (!$offer) {
            $offer = $this->offerSvc->addOffer($user->id, $request['type'], $request['bet']);
        }

        return response()->json([
            'channel' => 'game-' . $offer->user->id,
        ]);
    }
}
