<?php

namespace App\Providers;

use App\Validators\GameAllowedValidator;
use App\Validators\StepAllowedValidator;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Validator;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        Validator::extend(
            'game_allowed',
            GameAllowedValidator::class,
            GameAllowedValidator::errorMessage()
        );
    }

    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        //
    }
}
