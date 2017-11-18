<?php
namespace Tests\Unit;

use App\Enums\CellStates;
use App\Models\Game;
use App\Services\GameService;
use Tests\TestCase;

class GameServiceTest extends TestCase
{
    /**
     * Тест: генерация игрового поля в начальном состоянии.
     *
     * Ожидаем двумерный массив 7x7. По углам массива отмечены фишки двух игроков, остальные элементы - нули.
     */
    public function test_initGameField()
    {
        $model = $this->createMock(Game::class);
        $svc = new GameService($model);
        $field = $svc->initGameField(3, 7);

        $field = json_decode($field, true);

        $this->assertEquals(7, count($field));
        $this->assertEquals(7, count($field[0]));
        $this->assertEquals(7, count($field[6]));
        $this->assertEquals(CellStates::ONE, $field[6][0]);
        $this->assertEquals(CellStates::ONE, $field[0][6]);
        $this->assertEquals(CellStates::TWO, $field[0][0]);
        $this->assertEquals(CellStates::TWO, $field[6][6]);
    }
}
