extends Control

var grid : Grid = Game.grid
var cages : CageCluster = Game.cages

# Called when the node enters the scene tree for the first time.
func _ready() -> void:


	_debug_grid()
	
func _debug_grid() -> void:
	print(grid)
	print(grid.verify())

func rotate() -> void:
	grid.rotate()
	_debug_grid()

func shuffle() -> void:
	var rng = RandomNumberGenerator.new()
	var weights = [1, 1, 1]
	var col_1 = [0, 3, 6][rng.rand_weighted(weights)]
	var col_2 = [0, 1, 2][rng.rand_weighted(weights)]
	print("Swapping:", col_1, " and ", col_1 + col_2)
	grid.swap_col(col_1, col_1 + col_2)
	_debug_grid()

@export_range(0.1, .2) var text_size_ratio : float = 0.1:
	set(v):
		text_size_ratio = v
		queue_redraw()
		
@export var color : Color = Color.BLACK:
	set(v):
		color = v
		queue_redraw()

#func _draw() -> void:
	#var text : String = grid._to_string()
	#var font : Font = theme.default_font
	#var font_size = max(min(size.x, size.y) * text_size_ratio, 1)
	#var string_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	#var draw_position = (size - string_size) / 2 + Vector2(0, font.get_ascent(font_size))
	#draw_string(font, draw_position, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _recompile():
	grid._recompile()

func print_rand_numbers():
	var arr = Array(range(81))
	arr.shuffle()
	arr = arr.slice(0, 33)
	print(arr)

func show_cage():
	for cage in cages.content:
		print(cage)
	print('')


func show_prop() -> void:
	print(get_property_list())
