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
        $data = $request->only('name', 'email', 'password');
        $data['credits'] = config('game.newbee_gift');
        $user = User::create($data);
        $token = JWTAuth::fromUser($user);
        return response()->json([
            'token' => $token,
            'user_id' => $user->id,
            'name' => $user->name,
        ], 201);
    }
}
