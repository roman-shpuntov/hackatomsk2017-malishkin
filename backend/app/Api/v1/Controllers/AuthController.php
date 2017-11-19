<?php
namespace App\Api\v1\Controllers;

use App\Requests\LoginRequest;
use JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;
use App\Http\Controllers\Controller;
use Auth;

/**
 * Вход и выход юзера
 */
class AuthController extends Controller
{
    /**
     * Вход юзера
     * @param LoginRequest $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(LoginRequest $request)
    {
        $credentials = $request->only('email', 'password');

        try {
            if (! $token = JWTAuth::attempt($credentials)) {
                return response()->json(['error' => 'invalid_credentials'], 401);
            }
        } catch (JWTException $e) {
            return response()->json(['error' => 'could_not_create_token'], 500);
        }

        $user = Auth::user();
        return response()->json([
            'token' => $token,
            'user_id' => $user->id,
            'name' => $user->name,
        ]);
    }

    /**
     * Выход юзера
     * @return \Illuminate\Http\JsonResponse
     */
    public function logout()
    {
        JWTAuth::invalidate(JWTAuth::getToken());
        return response()->json(['success' => 'You are logged out']);
    }
}
