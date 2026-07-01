extends RefCounted
class_name Generator

var grid : Grid
var cages : CageCluster
var offset : Dictionary[int, int]
var config_system : Config
var performance_throttle : int = 20

func _init() -> void:
	initialize_new_game()
	pass
	

func initialize_new_game():
	#var date : String = Time.get_date_string_from_system()
	grid = Grid.new()
	cages = CageCluster.new()
		
		
signal puzzle_generated
func generate_puzzle():
	await grid.random_fill()
	#await cages.fill(grid)
	await cages.fill_strategy_2(grid)

	puzzle_generated.emit()


func set_seed(number: int) -> void:
	seed(number)

func seed_from_string_hash(string_to_be_hashed: String) -> void:
	prints("String parsed:", string_to_be_hashed)
	var new_seed : int = hash(string_to_be_hashed)
	prints("Seed:", new_seed)
	seed(new_seed)
