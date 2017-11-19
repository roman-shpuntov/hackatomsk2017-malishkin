<?php
Route::group(['prefix' => 'v1'], function () {
    $ns = '\App\Api\v1\Controllers\\';

    Route::post('user', $ns . 'RegisterController@create')->middleware('guest');
    Route::post('login', $ns . 'AuthController@login')->middleware('guest');
    Route::get('logout', $ns . 'AuthController@logout')->middleware('jwt.auth');

    Route::post('game-offer', $ns . 'GameController@gameOffer')->middleware('jwt.auth');

    // Ахтунг! Не закрывать эти роуты за аутентификацией. Если юзер разлогинится во время игры, это будет расценнено,
    // как проигрыш.
    Route::post('step', $ns . 'GameController@step');
    Route::post('cancel-game', $ns . 'GameController@cancelGame');
});
