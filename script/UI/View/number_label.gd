@tool
extends Control
class_name NumberLabel

@export var number : int:
	set(v):
		number = v
		if v == 0:
			text = ''
		else:
			text = str(v)
		queue_redraw()

@export var color: Color = Color.BLACK:
	set(v):
		color = v
		queue_redraw()
		
@export_range(.0, 1.0) var text_size_ratio: float = 1:
	set(v):
		text_size_ratio = v
		queue_redraw()

signal font_loaded
@export var font : FontVariation:
	set(v):
		font = v
		font_loaded.emit()


var text : String
var font_size: int = 32


func _ready() -> void:
	resized.connect(queue_redraw)

func _draw() -> void:
	if !font:
		return
	font_size = max(max(size.x, size.y) * text_size_ratio, 1)
	var string_size = font.base_font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var draw_position = size / 2 + string_size * Vector2(-1, .5) / 2 
	draw_string(font, draw_position, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
