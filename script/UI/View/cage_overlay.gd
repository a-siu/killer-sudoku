extends Control


@export var cell_con : CellContainer
@onready var cage_label: NumberLabel = $CageLabel

func _ready() -> void:
	resized.connect(queue_redraw)
	visible = true

	



func _draw() -> void:
	var cell : Cell = cell_con.cell
	if !cell or !cell.cage:
		return
	var get_coords := func(c: Cell): return c.coords
	var occupied : Array = cell.cage.content.map(get_coords.bind())
	
	for dir : Vector2i in [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]:
		
		if cell.coords + dir in occupied:
			continue
		var transform := Transform2D.IDENTITY.looking_at(dir)
		var half_side_length := Vector2.RIGHT * Vector2.RIGHT.dot(size / 2)
		transform = transform.translated(size / 2)
		transform = transform.translated_local(half_side_length)
		transform = transform.rotated_local(-90.0/180 * PI)
		var start_offset := transform.translated_local(half_side_length).origin
		var end_offset := transform.translated_local(-half_side_length).origin
		draw_dashed_line(start_offset, end_offset, Color.BLACK, 1, 5)
	if cell == cell.cage.content[0]:
		cage_label.number = cell.cage.sum
		cage_label.visible = true
	
