<?php
namespace App\Requests;

use App\Enums\GameTypes;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

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
}
