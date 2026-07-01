extends Control

@export var progress_bar : ProgressBar
@export var new_game_button : Button
@export var continue_button : Button
@export var settings_button : Button
@onready var game_title: RichTextLabel = $"Panel/Game Title"

var buttons : Array[Button]:
	get:
		return [new_game_button, continue_button, settings_button]



func _ready() -> void:
	continue_button.disabled = not Game.save_system.does_save_exist("generator")
	


func game_scene_transition():
	get_tree().change_scene_to_file.call_deferred("res://scene/Main/game.tscn")

func _on_new_game_pressed() -> void:
	game_title.add_loading_text()
	


func _on_continue_pressed() -> void:
	game_scene_transition()
	Game.use_old_save()

func _on_settings_pressed() -> void:
	pass


func _on_daily_pressed() -> void:
	game_title.add_loading_text()
	Game.generator.seed_from_string_hash(Time.get_date_string_from_system())
	await Game.start_new_game()
	game_scene_transition()
	pass # Replace with function body.


func _on_endless_pressed() -> void:
	game_title.add_loading_text()
	randomize()
	await Game.start_new_game()
	game_scene_transition()
	pass # Replace with function body.
