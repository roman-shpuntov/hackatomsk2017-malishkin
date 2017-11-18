<?php
namespace App\Enums;

/**
 * Альтернативная реализация php::SplEnum.
 *
 * Используется рефлексия класса для получения всех констант, результат кешируется в статическом свойстве супер-класса.
 *
 * @link https://github.com/Saritasa/php-common
 * @copyright Saritasa LLC
 *
 * Класс изменен по отношению к первоисточнику.
 */
abstract class Enum implements \JsonSerializable
{
    /**
     * Внутренний кеш для полученных констант enum-классов наследников
     * @var null
     */
    private static $constantsCache = [];

    /**
     * Массив всех констант класса
     * @return array [имя константы => значение]
     */
    public static function getConstants(): array
    {
        $calledClass = get_called_class();
        if (!array_key_exists($calledClass, self::$constantsCache)) {
            $reflect = new \ReflectionClass($calledClass);
            self::$constantsCache[$calledClass] = $reflect->getConstants();
        }
        return self::$constantsCache[$calledClass];
    }

    /**
     * Проверить, хранится ли переданное значение в константах класса
     * @param mixed $value  значение на проверку
     * @param bool  $strict TRUE - строгая проверка, включая совпадение типа значения
     * @return bool
     */
    public static function isValidValue($value, bool $strict = true): bool
    {
        $constants = self::getConstants();
        return in_array($value, $constants, $strict);
    }

    /**
     * Представление констант класса в качестве json-объекта
     * @return string
     */
    public function jsonSerialize(): string
    {
        return json_encode(self::getConstants(), JSON_UNESCAPED_UNICODE);
    }
}
