# Развертывание бэкенда

Бэкенд на PHP 7.1, фреймфорк Laravel 5.5

## Предварительные действия

Для запуска бэкенд-сервера требуется `php`, `composer`, `yarn` или `npm`. А так же web-сервер по вкусу :)

```sh
# установка PHP 7.1 Его может не быть в оф.репах Linux
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install php7.1

# установка расширений PHP
sudo apt-get -y install mcrypt php7.1-mcrypt php-mbstring php-pear php7.1-dev php7.1-curl php7.1-gd php7.1-mysql php7.1-sqlite3 php7.1-pgsql php7.1-zip php-xdebug php7.1-xml

# Установка composer
sudo apt-get install composer

# Установка yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn
```

## Собственно развертывание проекта

**Все выполняется в каталоге бэкенда**

Пример:

```sh
cd /home/www/app/backend/
```

### 1. Установка пакетов

```sh
composer install

yarn install
# или
или npm intall
```

### 2. Права доступа

```
chmod 777 bootstrap/cache
find storage/ -type d -exec chmod 777 {} \;
```

### 3. Конфигурация

Копируем файл конфигурации `.env.example` > `.env`

Задаем APP_URL, подключение к БД. Пустую базу нужно создать руками, и дать права доступа юзеру, заявленному в конфиге.

Начиная с Laravel 5.4 по умолчанию включен какой-то сервис шифрования. И это бы не проблема, но ему обязательно нужно задать секретный ключ, иначе нихрена не работает:

```
php artisan key:generate
```

### 4. Накатываем миграции

Сначала нужно создать пустую БД и прописать доступ к ней в `.env`. Только потом накатываем миграции:

```
php artisan migrate
```

### 5. Аутентификация

Аутентификация "из коробки":

```sh
php artisan make:auth
```

#### 5.1 JWT

[GitHub](https://github.com/tymondesigns/jwt-auth)

На данный момент (16.11.2017) библиотека встает криво в Laravel 5.5, см. [issue](https://github.com/tymondesigns/jwt-auth/issues/1298).

Решение: переименовать метод `fire()` в `handle()` тут [vendor/tymon/jwt-auth/src/Commands/JWTGenerateCommand.php] Только потом выполнять:

```sh
php artisan vendor:publish --provider="Tymon\JWTAuth\Providers\JWTAuthServiceProvider"
php artisan jwt:generate
```

Назад потом не забудь переименовать, а то при обновлении `Composer` задаст вопрос, а ты уже не вспомнишь, че там было и почему правил код библиотеки.

**Важно** Секретный ключ генерируемый `php artisan jwt:generate` прописывается прям в `config/jwt.php`, что не есть гуд. Надо убрать его оттуда и прописать только в `.env`:

```
JWT_SECRET=<some_super_secret_key>
```
