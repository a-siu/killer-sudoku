extends Node


var save_system : SaverLoader
var generator : Generator
#var scene_manager : SceneManager
#var ui_wrapper := UIManager.new()
var input : InputHandler 

func _init() -> void:
	save_system = SaverLoader.new()

## a "perfect" sleep function for other functions (use await Game.sleep)
func sleep(frames : int = 1):
	for i in range(frames):
		await get_tree().process_frame

func _ready() -> void:
	generator = Generator.new()
	input = InputHandler.new()
	
	
	
signal game_start
signal save_exist(is_success : bool)
var game_in_progress : bool = false

	
func use_old_save():
	save_system.load_game("generator")
	game_in_progress = true

func start_new_game():
	await generator.generate_puzzle()
	game_in_progress = true

func open_settings() -> void:
	# open settings scene
	pass

func finish_game():
	pass


func _input(event: InputEvent) -> void:
	input.passed_input(event)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED:
			if game_in_progress:
				save_system.save_game("generator")
		NOTIFICATION_WM_CLOSE_REQUEST:
			if game_in_progress:
				save_system.save_game("generator")
			get_tree().quit()
