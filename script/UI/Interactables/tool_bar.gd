extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _on_draft_toggled(toggled_on: bool) -> void:
	Game.input.is_drafting = toggled_on

func _on_erase_pressed() -> void:
	Game.input.erase()

func _on_undo_pressed() -> void:
	Game.input.undo_wrapper()

func _on_smart_hint_pressed() -> void:
	Game.input.smart_hint()
