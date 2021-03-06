<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * @property int    $id
 * @property int    $user_id    id юзера, предложивший игру
 * @property string $type       тип игры, см. Enums\GameTypes
 * @property int    $prize      приз игры
 * @property int    $winner_id  id победителя
 * @property string $snapshot   снимок поля
 * @property string $log        игра лог игры
 * @property string $game_key   защитный ключ игры
 *
 * @property User[] $users      игроки
 */
class Game extends Model
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
        'prize'    => 'integer',
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

    /**
     * Игроки. Выдача для game-offer
     * @return \Illuminate\Database\Eloquent\Relations\BelongsToMany
     */
    public function users()
    {
        return $this->belongsToMany(User::class, 'user_games')->select(\DB::raw('id AS user_id'), 'name');
    }
}
