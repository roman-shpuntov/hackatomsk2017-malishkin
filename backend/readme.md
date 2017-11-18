# Chip'n'flip

Игра.


## Уведомления

[Laravel 5.5 Broadcasting](https://laravel.com/docs/5.5/broadcasting)
[Laravel Echo](https://laravel.ru/posts/655)
[Writing Realtime apps with Laravel 5 and Pusher](https://blog.pusher.com/writing-realtime-apps-with-laravel-5-and-pusher/)
[Laravel chat with Pusher](https://blog.pusher.com/how-to-build-a-laravel-chat-app-with-pusher/)

**Push в Laravel не будет выполняться, если не запущен обработчик очередей!** Так сделано, чтобы не задерживать выполнение скрипта на соединении с Pusher (или другим WebSockets-сервером) и отправкой данных. Т.е. push-уведомление становится фоновой задачей. Аналогичное поведение можно наблюдать при отправке письма через PHP. Если не перекладывать процесс в фон, то юзер может долго ждать, пока сервак ему ответит.

Запустить обработчик очереди, как демон - это отдельная история <https://laravel.com/docs/5.5/queues#running-the-queue-worker>. В качестве отладки можно запустить обработчик прям в консоли:

```sh
php artisan queue:work
```

Но на проде такое не прокатит. Однако, **для текущего проекта нам не нужна постановка в очередь**, т.к. на push-уведомлении основана очередность действий игроков! Нам нужна отправка уведомления в real-time. Поэтому упрощаем все до максимума: никаких Laravel Events, очередей и т.п. После расчета игрового поля отправляем уведомление, ждем когда оно уйдет и завершаем выполнение скрипта.

### Свой WebSockets-сервер

[Laravel Echo server](https://github.com/tlaverdure/laravel-echo-server)
[Рабочий пример с laravel-echo-server](https://github.com/tonimitrevski/laravel-notification-redis-echo)
[Realtime Apps With Laravel Echo: Tips and Tricks](https://komelin.com/articles/realtime-apps-laravel-echo-tips-and-tricks)

[Тут](https://laracasts.com/discuss/channels/laravel/i-am-thoroughly-confused-with-socketio-laravel-echo-redis-and-laravel-echo-server) см. `socket.js`. Это пример независимого WebSockets-сервера для проверки Redis на предмет появления новых сообщений. В принципе, можно запустить его вместо `laravel-echo-server`, но я не вижу в этом смысла.

[Laravel Echo iOS](https://github.com/val-bubbleflat/laravel-echo-ios)

### Pusher

Excluding Recipients <https://pusher.com/docs/server_api_guide/server_excluding_recipients>
