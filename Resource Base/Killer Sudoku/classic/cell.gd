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
	
	if SaverLoader.DATATYPE.cell not in data:
		push_error("No data for all cells")
		return
	data = data[SaverLoader.DATATYPE.cell]
	if coords not in data:
		push_error("No data for Cell:", coords)
		return
	number = data[coords][DATA.NUMBER]
	display = data[coords][DATA.DISPLAY]
	var packed_bit = data[coords][DATA.BITS]
	notes_bits = _int_to_1Dbits(packed_bit, 10)

func write_to_save(data : Dictionary):
	if SaverLoader.DATATYPE.cell not in data:
		data[SaverLoader.DATATYPE.cell] = Dictionary()
	data = data[SaverLoader.DATATYPE.cell]
	if coords not in data:
		data[coords] = Dictionary()
	data = data[coords]
	data[DATA.NUMBER] = number
	data[DATA.DISPLAY] = display
	var packed_bit : int = _1Dbits_to_int(notes_bits)
	data[DATA.BITS] = packed_bit

## convert 1d bit map into integer
func _1Dbits_to_int(bits: BitMap) -> int:
	var return_int := 0
	var length := bits.get_size().x
	var _tmp_mult := 1
	for i in range(length):
		var value : int = bits.get_bit(i, 0)
		return_int += value * _tmp_mult
		_tmp_mult *= 2
	return return_int

## convert integer to a 1d bitmap, with the size
func _int_to_1Dbits(num: int, size: int) -> BitMap:
	var _map := BitMap.new()
	_map.create(Vector2i(size, 1))
	for i in range(size):
		if num % 2 == 0:
			num /= 2
			continue
		_map.set_bit(i, 0, true)
		num	-= 1
		num /= 2
	return _map
	
func _to_string() -> String:
	return str(number)
