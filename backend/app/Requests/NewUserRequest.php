<?php
namespace App\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * Валидация запроса на создание нового пользователя
 */
class NewUserRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     * @return bool
     */
    public function authorize()
    {
        // Allows all users access
        return true;
    }

    /**
     * Правила для валидации нового пользователя
     * @return array
     */
    public function rules()
    {
        return [
            'name'     => 'required|string|max:255',
            'email'    => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
        ];
    }
}
