@tool
extends ColorRect

@export var grid_color : Color = Color.BLACK
var col : int = 9
@export var overlay_color : Color = Color.SKY_BLUE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resized.connect(queue_redraw)

func _draw() -> void:
	_draw_grid()
	
func _draw_grid() -> void:

	var step_x = size.x / col
	var step_y = size.y / col
	var coarse_grid_inteval : int = 3
	for i in range(col):
		var current_color : Color = grid_color
		var current_width : int = -1
		if i % coarse_grid_inteval == 0:
			current_color.lightened(.3)
			current_width = 2
		draw_line(Vector2(i * step_x, 0), Vector2(i * step_x, size.y), current_color, current_width)
		draw_line(Vector2(0, i * step_y), Vector2(size.x, i * step_y), current_color, current_width)

	draw_rect(Rect2(Vector2.ZERO, size), grid_color, false, 2)
	
