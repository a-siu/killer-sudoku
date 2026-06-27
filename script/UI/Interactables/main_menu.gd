extends Control

@export var progress_bar : ProgressBar
@export var new_game_button : Button
@export var continue_button : Button
@export var settings_button : Button

var buttons : Array[Button]:
	get:
		return [new_game_button, continue_button, settings_button]



func _ready() -> void:
	continue_button.disabled = not Game.save_system.does_save_exist("generator")
	

func update(f: float):
	progress_bar.set_value_no_signal(f)

func game_scene_transition():
	get_tree().change_scene_to_file.call_deferred("res://scene/Main/game.tscn")

func _on_new_game_pressed() -> void:
	Game.generator.grid.random_fill_progress.connect(update)
	Game.generator.cages.cages_filled_progress.connect(update)
	await Game.start_new_game()
	game_scene_transition()


func _on_continue_pressed() -> void:
	game_scene_transition()
	Game.use_old_save()

func _on_settings_pressed() -> void:
	pass
