# Установка нового проекта Laravel

<https://laravel.ru/docs/v5/installation>

## 1. Установка

```sh
composer install

yarn install
# или
или npm intall
```

## 2. Права доступа

```
chmod 777 bootstrap/cache
find storage/ -type d -exec chmod 777 {} \;
```

## 3. Конфигурация

Копируем файл конфигурации `.env.example` > `.env`

Задаем APP_URL, подключение к БД. Пустую базу нужно создать руками, и дать права доступа юзеру, заявленному в конфиге.

Начиная с Laravel 5.4 по умолчанию включен какой-то сервис шифрования. И это бы не проблема, но ему обязательно нужно задать секретный ключ, иначе нихрена не работает:

```
php artisan key:generate
```

## 4. Накатываем миграции

```
php artisan migrate
```
