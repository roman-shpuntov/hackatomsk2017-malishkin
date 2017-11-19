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

        // $this->drawGrid($field); // DBG

        $this->assertEquals(7, count($field));
        $this->assertEquals(7, count($field[0]));
        $this->assertEquals(7, count($field[6]));
        $this->assertEquals(34, $field[6][0]);
        $this->assertEquals(34, $field[0][6]);
        $this->assertEquals(15, $field[0][0]);
        $this->assertEquals(15, $field[6][6]);
    }

    /**
     * Тест: пересчет поля при ходе игрока. Середина поля
     */
    public function test_calculateProfit_middle()
    {
        $size = 7;
        $field = array_fill(0, $size, (array_fill(0, $size, 0)));

        $field[3][2] = 2;
        $field[3][4] = 7;
        $field[4][4] = 7;
        $field[5][4] = 7;
        $field[4][5] = 7; // это не должно замениться

        //$this->drawGrid($field); // DBG

        // Шагаем по диагонали, вверх-вправо
        $this->service->calculateProfit($field, 2, '3:2', '4:3', $size);

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

    /**
     * Тест: пересчет поля при ходе игрока. Край поля
     */
    public function test_calculateProfit_edge()
    {
        $size = 7;
        $field = array_fill(0, $size, (array_fill(0, $size, 0)));

        $field[6][0] = 2;
        $field[6][2] = 7;
        $field[6][3] = 7;

        // $this->drawGrid($field); // DBG

        // Шагаем вправо на соседнюю клетку
        $this->service->calculateProfit($field, 2, '6:0', '6:1', $size);

        // $this->drawGrid($field); // DBG

        // эти две - результат движения на соседнюю  клетку
        $this->assertEquals(2, $field[6][0]);
        $this->assertEquals(2, $field[6][1]);

        // Эта - захваченная
        $this->assertEquals(2, $field[6][2]);

        // Эта осталась без изменений
        $this->assertEquals(7, $field[6][3]);
    }

    /**
     * Тест: сможет ли ходить другой игрок или игра окончена. В таком случае выявляем победителя.
     * @dataProvider winnerFields
     * @param array $field
     */
    public function test_checkAnyWinner(array $field, int $exceptedWinnerId)
    {
        $snapshot = [
            'turn_user_id' => 3,
            'field'        => $field,
        ];

        $winnerId = $this->service->checkAnyWinner($snapshot);
        $this->assertEquals($exceptedWinnerId, $winnerId);
    }

    /**
     * Данне для теста победителя
     */
    public function winnerFields()
    {
        return [
            'граница, есть ход' => [
                'field'            => [
                    [3, 0, 3],
                    [7, 7, 7],
                    [0, 0, 0],
                ],
                'exceptedWinnerId' => 0,
            ],

            'центр, есть ход' => [
                'field'            => [
                    [7, 7, 0, 0],
                    [0, 0, 0, 0],
                    [0, 0, 3, 0],
                    [0, 0, 0, 0],
                ],
                'exceptedWinnerId' => 0,
            ],

            'нет хода' => [
                'field'            => [
                    [3, 3, 7, 7],
                    [7, 7, 7, 7],
                    [7, 7, 7, 7],
                    [0, 0, 0, 0],
                ],
                'exceptedWinnerId' => 7,
            ],

            'победа по счету' => [
                'field'            => [
                    [3, 3, 3],
                    [7, 7, 7],
                    [3, 3, 7],
                ],
                'exceptedWinnerId' => 3,
            ],

            'кончились фишки' => [
                'field'            => [
                    [7, 7, 7],
                    [7, 7, 0],
                    [0, 0, 0],
                ],
                'exceptedWinnerId' => 7,
            ],
        ];
    }
}
