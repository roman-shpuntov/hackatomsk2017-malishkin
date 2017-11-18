<?php
namespace Tests\Unit;

use App\Enums\CellStates;
use App\Models\Game;
use App\Services\GameService;
use Tests\TestCase;

class GameServiceTest extends TestCase
{
    private $service;

    public function setUp()
    {
        $model = $this->createMock(Game::class);
        $this->service = new GameService($model);
        parent::setUp();
    }

    /**
     * Тест: генерация игрового поля в начальном состоянии.
     *
     * Ожидаем двумерный массив 7x7. По углам массива отмечены фишки двух игроков, остальные элементы - нули.
     */
    public function test_initGameField()
    {
        $snapshot = $this->service->initGameField(34, 15, 7); // $userId1, $userId2, $size

        $this->assertEquals(34, $snapshot['turn_user_id']);

        $field = $snapshot['field'];
        $this->assertEquals(7, count($field));
        $this->assertEquals(7, count($field[0]));
        $this->assertEquals(7, count($field[6]));
        $this->assertEquals(34, $field[6][0]);
        $this->assertEquals(34, $field[0][6]);
        $this->assertEquals(15, $field[0][0]);
        $this->assertEquals(15, $field[6][6]);
    }
}
