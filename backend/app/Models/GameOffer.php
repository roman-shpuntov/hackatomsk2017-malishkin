<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * @property int    $user_id  id юзера, предложивший игру
 * @property string $type     тип игры, см. Enums\GameTypes
 * @property int    $bet      ставка
 *
 * @property User   $user     юзер, предложивший игру
 */
class GameOffer extends Model
{
    /**
     * The table associated with the model.
     * @var string
     */
    protected $table = 'game_offers';

    /**
     * Нужно только одно поле с датой, created_at. Исключить updated_at. см. self::boot()
     * @var bool
     */
    public $timestamps = false;

    /**
     * The attributes that are mass assignable.
     * @var array
     */
    protected $fillable = [
        'user_id',
        'type',
        'bet',
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
     * Пользователь, предложивший игру
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
