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
     * Функция отладки: отрисовывает поле считая 0:0 в левом нижнем углу
     * @param array $field
     */
    private function drawGrid(array $field)
    {
        $size = count($field);
        for ($row = $size - 1; $row >= 0; $row--) {
            for ($col = 0; $col < $size; $col++) {
                echo $field[$row][$col] . ' ';
            }
            echo PHP_EOL;
        }
        echo PHP_EOL;
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

    /**
     * Тест: пересчет поля при ходе игрока
     */
    public function test_calculateStepResult_middle()
    {
        $size = 7;
        $field = array_fill(0, $size, (array_fill(0, $size, 0)));

        $field[3][2] = 2;
        $field[3][4] = 7;
        $field[4][4] = 7;
        $field[5][4] = 7;
        $field[4][5] = 7; // это не должно замениться

        // $this->drawGrid($field); // DBG

        // Шагаем по диагонали, вверх-вправо
        $this->service->calculateStepResult($field, 2, '3:2', '4:3', $size);

        // $this->drawGrid($field); // DBG

        // эти две - результат движения на соседнюю по диагонали клетку
        $this->assertEquals(2, $field[3][2]);
        $this->assertEquals(2, $field[3][4]);

        // Эти - захваченные
        $this->assertEquals(2, $field[3][4]);
        $this->assertEquals(2, $field[4][4]);
        $this->assertEquals(2, $field[5][4]);

        // Эта осталась без изменений
        $this->assertEquals(7, $field[4][5]);
    }
}
