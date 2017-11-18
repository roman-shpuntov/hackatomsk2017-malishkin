<?php
namespace App\Api\V1\Controllers;

class GameController
{
    /**
     * Предложение пользователя поиграть
     *
     * Юзер в запросе указывает ставку, на какие деньги он хочет сыграть. Сервер либо найдет сразу подходящего
     * оппонента, либо добавит его предложение в список ожидающих ответа
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function gameOffer()
    {
        return response()->json(['status' => 'accepted']);
    }
}
