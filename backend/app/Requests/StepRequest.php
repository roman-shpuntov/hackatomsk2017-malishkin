<?php
namespace App\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * Валидация хода пользователя
 */
class StepRequest extends FormRequest
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
        $coordinateRules = 'required|regex:/\d{1,2}:\d{1,2}/';
        return [
            'game_id' => 'required|integer|exists:games,id|game_allowed:' . $this->get('user_id'),
            'user_id' => 'required|integer',
            'from'    => $coordinateRules,
            'to'      => $coordinateRules,
        ];
    }
}
