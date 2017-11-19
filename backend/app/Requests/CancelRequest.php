<?php
namespace App\Requests;

use Illuminate\Validation\Rule;
use Illuminate\Foundation\Http\FormRequest;

/**
 * Запрос на отмену игры
 */
class CancelRequest extends FormRequest
{
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
        return [
            'game_id'  => 'required|integer|exists:games,id|game_allowed:' . $this->get('user_id'),
            'game_key' => [
                'required',
                Rule::exists('games')->where(function ($query) {
                    $query->where('id', $this->get('game_id'));
                }),
            ],
            'user_id'  => 'required|integer',
        ];
    }
}
