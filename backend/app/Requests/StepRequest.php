<?php
namespace App\Requests;

use App\Models\Game;
use Illuminate\Validation\Rule;
use Illuminate\Foundation\Http\FormRequest;

/**
 * Валидация хода пользователя
 */
class StepRequest extends FormRequest
{
    /**
     * @var Game
     */
    private $model;

    /**
     * @param Game            $model
     * @param array           $query      The GET parameters
     * @param array           $request    The POST parameters
     * @param array           $attributes The request attributes (parameters parsed from the PATH_INFO, ...)
     * @param array           $cookies    The COOKIE parameters
     * @param array           $files      The FILES parameters
     * @param array           $server     The SERVER parameters
     * @param string|resource $content    The raw body data
     */
    public function __construct(
        Game $model,
        array $query = array(),
        array $request = array(),
        array $attributes = array(),
        array $cookies = array(),
        array $files = array(),
        array $server = array(),
        $content = null
    ) {
        parent::__construct($query, $request, $attributes, $cookies, $files, $server, $content);
        $this->model = $model;
    }

    /**
     * Determine if the user is authorized to make this request.
     * @return bool
     */
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        $coordinateRules = 'required|regex:/\d{1,2}:\d{1,2}/';
        return [
            'game_id'  => 'required|integer|exists:games,id|game_allowed:' . $this->get('user_id'),
            'game_key' => [
                'required',
                Rule::exists('games')->where(function ($query) {
                    $query->where('id', $this->get('game_id'));
                }),
            ],
            'user_id'  => 'required|integer',
            'from'     => $coordinateRules,
            'to'       => $coordinateRules,
        ];
    }

    /**
     * Проверки: сейчас ход игрока; можно ходить, куда указал юзер
     *
     * TODO по-прежнему корявое решение. Нужно улучшить. Вопрос №2: как это тестировать?
     */
    public function getValidatorInstance()
    {
        $validator = parent::getValidatorInstance();

        $validator->after(function () use ($validator) {
            if ($validator->errors()) {
                return;
            }

            [$gameId, $userId, $from, $to] = array_values($this->only('game_id', 'user_id', 'from', 'to'));

            $snapshot = optional($this->model->find($gameId))->snapshot;
            if (!$snapshot) {
                return $validator->errors()->add('bug', 'Something wrong, a game snapshot not found');
            }
            $snapshot = json_decode($snapshot, true);

            if ($snapshot['turn_user_id'] != $userId) {
                return $validator->errors()->add('turn', 'Not your turn now');
            }

            $field = $snapshot['field'];

            [$fromRow, $fromCol] = explode(':', $from);
            if (!isset($field[$fromRow][$fromCol]) || $field[$fromRow][$fromCol] != $userId) {
                return $validator->errors()->add('not_own_chip', 'You try to move not your chip');
            }

            [$toRow, $toCol] = explode(':', $to);
            if (!isset($field[$toRow][$toCol]) || $field[$toRow][$toCol] != 0) {
                return $validator->errors()->add('occupied_cell', 'You try to step to occupied cell');
            }

            if (abs($fromRow - $toRow) > 2 || abs($fromCol - $toCol) > 2) {
                $validator->errors()->add('far_step', 'You try to step too far');
            }
        });

        return $validator;
    }
}
