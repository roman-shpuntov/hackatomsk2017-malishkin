<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * @property int $id
 * @property int $game_id    id игры, на основании которой выполнена операция
 * @property int $user_id    id пользователя, на чьем счету выполняется операция
 * @property int $amount     сумма операции
 */
class Transaction extends Model
{
    /**
     * Нужно только одно поле с датой, created_at. Исключить updated_at. см. self::boot()
     * @var bool
     */
    public $timestamps = false;

    /**
     * The attributes that aren't mass assignable.
     *
     * @var array
     */
    protected $guarded = [
        'id',
        'created_at',
    ];

    /**
     * The attributes that should be cast to native types.
     * @var array
     */
    protected $casts = [
        'amount' => 'integer',
    ];

    /**
     * Нужно только одно поле с датой, created_at. Исключить updated_at.
     */
    public static function boot()
    {
        parent::boot();
        static::creating(function ($model) {
            $model->created_at = $model->freshTimestamp();
        });
    }
}
