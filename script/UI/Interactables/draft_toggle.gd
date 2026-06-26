extends Button

const off_texture = preload("res://drawable/InputPad/drafts-20-regular.svg")
const on_texture = preload("res://drawable/InputPad/drafts-20-filled.svg")

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		icon = on_texture
	else:
		icon = off_texture


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("input_draft"):
		button_pressed = !button_pressed
		return
