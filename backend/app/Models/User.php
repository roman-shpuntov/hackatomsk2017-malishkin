<?php

namespace App\Models;

use Illuminate\Notifications\Notifiable;
use Illuminate\Foundation\Auth\User as Authenticatable;

/**
 * @property int $id
 * @property string $name
 * @property string $email
 * @property string $password
 */
class User extends Authenticatable
{
    use Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'name', 'email', 'password',
    ];

    /**
     * The attributes that should be hidden for arrays.
     *
     * @var array
     */
    protected $hidden = [
        'password', 'remember_token', 'pivot',
    ];

    /**
     * Sets the user's password.
     * @param string $password
     */
    public function setPasswordAttribute($password)
    {
        if ($this->exists && $password === '') {
            return;
        }
        $this->attributes['password'] = password_hash($password, PASSWORD_DEFAULT);
    }

    /**
     * Validate password
     * @param string $password
     * @return boolean
     */
    public function checkPassword($password)
    {
        return password_verify($password, $this->password);
    }
}
