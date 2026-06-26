extends Control


var selected_big_tile : Vector2i:
	get:
		return selected_tile / 3 * 3
var selected_tile : Vector2i:
	set(v):
		selected_tile = v
		queue_redraw()

var draw_color : Color

var columns: int = 9
var big_columns: int = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resized.connect(queue_redraw)
	draw_color = get_parent().overlay_color
	Game.input.cell_selected.connect(change_selected_tile)
	
func change_selected_tile(v : Vector2i):
	selected_tile = v

func _draw() -> void:
	var input := Game.input
	if input.selection_state == input.State.IDLE:
		return
	var unit_length : float = size.x / columns
	var unit_square : Rect2 = Rect2(Vector2.ZERO, unit_length * Vector2.ONE)
	
	draw_rect(Rect2(selected_tile * unit_length * Vector2.DOWN, Vector2(size.x, unit_length)), draw_color)
	draw_rect(Rect2(selected_tile * unit_length * Vector2.RIGHT, Vector2(unit_length, size.y)), draw_color)
	
	
	draw_rect(Rect2(selected_big_tile * unit_length * Vector2.ONE, big_columns * unit_length * Vector2.ONE), draw_color)
	
	
	
	draw_rect(Rect2(selected_tile * unit_length * Vector2.ONE, unit_square.size), draw_color.darkened(.2))



		
func _on_gui_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	if not event.is_pressed():
		return
	var next_selected_tile = Vector2i(event.position / size * columns)
	Game.input.selection_changed(next_selected_tile)
