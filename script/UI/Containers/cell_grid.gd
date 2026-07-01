extends GridContainer

const CELL = preload("res://scene/UI/cell.tscn")

func _init() -> void:
	for y in range(columns):
		for x in range(columns):
			var cell = CELL.instantiate()
			add_child(cell)

func _ready() -> void:
	integrate(Game.generator.grid)

func integrate(grid : Grid):
	for y in range(columns):
		for x in range(columns):
			var cell := get_child(9 * y + x)
			cell.cell = Game.generator.grid.rows[y].content[x]
