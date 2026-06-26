extends Control

@onready var button: Button = $NumberedButton
@onready var number_label: NumberLabel = $NumberedButton/NumberLabel

var number: int:
	set(v):
		number_label.number = v
		
var color: Color :
	set(v):
		number_label.color = v
				
signal assign(number: int)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	number_label.text_size_ratio = .8
	button.pressed.connect(func(): assign.emit(number_label.number))
