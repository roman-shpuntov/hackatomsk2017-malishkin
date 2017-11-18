<?php
Route::group(['prefix' => 'v1'], function () {
    $ns = '\App\Api\v1\Controllers\\';

    Route::post('user', $ns . 'RegisterController@create')->middleware('guest');
    Route::post('login', $ns . 'AuthController@login')->middleware('guest');
    Route::get('logout', $ns . 'AuthController@logout')->middleware('jwt.auth');

    Route::post('game-offer', $ns . 'GameController@gameOffer')->middleware('jwt.auth');
});
