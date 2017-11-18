<?php
namespace App\Api\v1\Controllers;

use App\Requests\NewUserRequest;
use App\Models\User;
use App\Http\Controllers\Controller;
use Route;
use JWTAuth;

/**
 * Регистрация нового пользователя
 */
class RegisterController extends Controller
{
    /**
     * Регистрация нового пользователя
     *
     * После регистрации возвращаем юзеру токен аутентификации
     *
     * @param NewUserRequest $request
     * @return User
     */
    protected function create(NewUserRequest $request)
    {
        $user = User::create($request->only('name', 'email', 'password'));
        $token = JWTAuth::fromUser($user);
        return response()->json(['token' => $token], 201);
    }
}
