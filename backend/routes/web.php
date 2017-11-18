<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

Auth::routes();

Route::get('/home', 'HomeController@index')->name('home');

Route::get('/pusher', function () {
    //$event = new App\Events\GridUpdatedEvent([11 => 'b', 12 => null, 13 => 'w'], 234);
    //event($event);
    // broadcast($event)->toOthers(); // Тот же хрен, вид сбоку

    $options = array(
        'cluster'   => 'eu',
        'encrypted' => true,
    );
    $pusher = new Pusher\Pusher(
        '994095a2c453e06bd4c1',
        '036138a4366f90eb52ad',
        '431220',
        $options
    );

    $data['message'] = 'Hello, world! ' . date('m.d.Y H:i:s');
    $pusher->trigger('private-my-channel', 'my-event', $data);

    return "Event has been sent!";
});

