<?php
namespace App\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * Валидация запроса на вход
 */
class LoginRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'email'    => 'required|email',
            'password' => 'required',
        ];
    }
}
