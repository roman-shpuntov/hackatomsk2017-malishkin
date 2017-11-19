<?php
namespace App\Requests;

use App\Enums\GameTypes;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Auth;

/**
 * Валидация запроса с предложением игры
 */
class GameOfferRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'type' => [
                'required',
                Rule::in(GameTypes::getConstants()),
            ],
            'bet'  => 'integer|nullable',
        ];
    }

    public function messages()
    {
        return [
            'type.in' => 'Unknown game type',
        ];
    }

    /**
     * Проверка, достаточно ли у пользователя средств, если игра со ставкой
     */
    public function getValidatorInstance()
    {
        $validator = parent::getValidatorInstance();

        $validator->after(function () use ($validator) {
            if ($validator->errors()) {
                return;
            }

            [$type, $bet] = array_values($this->only('type', 'bet'));

            if ($type == GameTypes::FREE) {
                return;
            }

            if (Auth::user()->credits < $bet) {
                $validator->errors()->add('no_credit', 'You have not enough credits for this game');
            }
        });

        return $validator;
    }
}
