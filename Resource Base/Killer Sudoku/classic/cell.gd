extends Resource
class_name Cell



var grid : Grid
var cage : Cage
var tuple : Vector2i
enum DATA {
	NUMBER,
	DISPLAY,
	BITS,
	COORDS
}
signal display_changed
var number : int:
	get:
		return tuple.x
	set(v):
		tuple.x = v
var display : int:
	get:
		return tuple.y
	set(v):
		tuple.y = v
		display_changed.emit()

signal notes_changed
var notes_bits: BitMap = BitMap.new():
	set(v):
		notes_bits = v
		notes_changed.emit()

#var coords_bits: 

var coords : Vector2i:
	set(v):
		coords = v
		#if !grid:
			#return
		#self.col.content[v.y] = self
		#self.row.content[v.x] = self
		#self.block.content[v.y % 3 * 3 + v.x % 3] = self



var col : House:
	get:
		return grid.columns[int(coords.x)]

var row : House:
	get:
		return grid.rows[int(coords.y)]

var block : House:
	get:
		return grid.blocks[int(coords.y / 3) * 3 + int(coords.x / 3)]		

#var housing : Vector4i # row col block cage

func get_influence() -> Array[Cell]:
	var district : Array[Cell]
	for arr in [col.content, row.content, cage.content, block.content]:
		for cell in arr:
			if cell in district or cell == self:
				continue
			district.append(cell)
	return district

func _init() -> void:
	Game.save_system.save_data.connect(write_to_save)
	Game.save_system.load_data.connect(read_from_save)

func read_from_save(data : Dictionary):
	if coords not in data:
		push_error("No data for Cell:", coords)
		return
	number = data[coords][DATA.NUMBER]
	display = data[coords][DATA.DISPLAY]
	notes_bits = data[coords][DATA.BITS]

func write_to_save(data : Dictionary):
	if not coords not in data:
		data[coords] = Dictionary()
	data[coords][DATA.NUMBER] = number
	data[coords][DATA.DISPLAY] = display
	data[coords][DATA.BITS] = notes_bits

func _to_string() -> String:
	return str(number)
