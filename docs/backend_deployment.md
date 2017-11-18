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

```
php artisan migrate
```
