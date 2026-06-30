extends Resource
class_name Generator

@export var grid : Grid
@export var cages : CageCluster
@export var offset : Dictionary[int, int]
var config_system : Config
var performance_throttle : int = 20

func _init() -> void:
	initialize_new_game()
	pass
	

func initialize_new_game():
	#var date : String = Time.get_date_string_from_system()
	var date : String = Time.get_date_string_from_system()

	prints("Date parsed:", date)
	var seed : int = hash(date) + offset.get(hash(date), 0)
	prints("Seed generated:", seed)
	seed(seed)
	grid = Grid.new()
	cages = CageCluster.new()
		
		
signal puzzle_generated
func generate_puzzle():
	await grid.random_fill()
	#await cages.fill(grid)
	await cages.fill_strategy_2(grid)

	puzzle_generated.emit()
