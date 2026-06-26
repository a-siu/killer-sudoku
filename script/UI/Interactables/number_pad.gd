extends Container

const NUMBER_PAD_BUTTON = preload("res://scene/UI/number_pad_button.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for button : Node in get_children():
		button.number = int(button.name)
		button.assign.connect(_received)

func _received(number: int) -> void:
	Game.input.assign(number)
