extends House
class_name Cage

var sum : int:
	get:
		var v : int = 0
		for cell : Cell in content:
			v += cell.number
		return v



func get_adjacent() -> Array[Vector2]:
	var _dir : PackedVector2Array = [Vector2.DOWN, Vector2.UP, Vector2.LEFT, Vector2.RIGHT]	
	var _discarded : PackedVector2Array = []
	var content_coords : PackedVector2Array = content.map(func(c: Cell): return c.coords)
	if not content_coords:
		print("Cage does not have head, No adjacent cells")
		return []
	var verified : Array[Vector2] = []

	var helper_dfs := func(checking : Vector2, callback: Callable) -> void:
		if checking in _discarded:
			return
		if checking not in content_coords:
			verified.append(checking)
			_discarded.append(checking)
			return
			
		_discarded.append(checking)
		for dir in _dir:
			var next = checking + dir
			if int(next.x) not in range(9) or int(next.y) not in range(9):
				continue
			callback.call(next, callback)

	helper_dfs.call(content_coords[0], helper_dfs)
	return verified
#
func _init() -> void:
	Game.save_system.save_data.connect(write_to_save)
	#Game.save_system.load_data.connect(read_from_save)

func write_to_save(data: Dictionary):
	if SaverLoader.DATATYPE.cage not in data:
		data[SaverLoader.DATATYPE.cage] = Array()
	var cage_list = data[SaverLoader.DATATYPE.cage]
	var cell_coords_list : Array = content.map(func(c: Cell): return c.coords) # Array[Vec2i]
	# put the whole cell coords array into the array as 1 elemenbt for dictionary encoding to json
	cage_list.append(cell_coords_list)	
	



func add_cell(cell: Cell):
	if cell.cage:
		return
	content.append(cell)
	cell.cage = self
	print("Added Cell: ", cell.coords, " to Cage with head: ", content[0].coords)
	return self

func _to_string() -> String:
	var text = 'Cage of sum: '
	text += str(sum) + ' at: '
	for cell in content:
		text += str(cell.coords)
	return text
