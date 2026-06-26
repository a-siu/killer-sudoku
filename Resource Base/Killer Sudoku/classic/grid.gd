extends Resource
class_name Grid

enum directions {UP, LEFT, DOWN, RIGHT}

var rows : Array[House] # the main data structure for managing the grid


var columns : Array[House]
var blocks : Array[House]
var cells : Array[Cell]

func verify() -> bool: # check if grid is finished
	for col in columns:
		if col.verify() == false:
			return false
	for row in rows:
		if row.verify() == false:
			return false
	for block in blocks:
		if block.verify() == false:
			return false
	
	return true


signal random_fill_progress(f: float)
signal random_fill_finished
func random_fill() -> void: # randomly assign each cell to a number, according to sudoku rules
	_populate()
	var not_assigned := func(c: Cell) -> bool: 
		if c.number:
			return false
		return true
	var get_3_houses := func(c: Cell) -> Array:
		var arr := []
		arr.append(rows[c.coords.y])
		arr.append(columns[c.coords.x])
		arr.append(blocks[int(c.coords.y / 3) * 3 + int(c.coords.x / 3)])
		return arr
	var get_cell_number := func(c: Cell) -> int: return c.number
	var house_to_numbers := func (h: House) -> Array[int]: return h.content.map(get_cell_number)

	var helper_dfs := func(dice: Array, callback: Callable, _process_counter: int = 0) -> bool:
		_process_counter += 1
		var candidate : int = cells.find_custom(not_assigned)
		if _process_counter >= Game.generator.performance_throttle:
			await Game.sleep(1)
			self.random_fill_progress.emit(float(candidate) / cells.size())
			_process_counter = 0
		if candidate == -1:
			random_fill_progress.emit(1)
			return true
		var current : Cell = cells[candidate]
		var houses : Array = get_3_houses.call(current)
		var banned_numbers : Array[int] = []
		for house : House in houses:
			for cell in house.content:
				if cell.number in banned_numbers:
					continue
				banned_numbers.append(cell.number)
		
		for number in dice:
			if number in banned_numbers:
				continue
			current.number = number
			var new_dice := dice.duplicate()
			new_dice.shuffle()
			if await callback.call(new_dice, callback, _process_counter):
				return true	
		current.number = 0
		return false
		
	var dice := range(1, 10)
	
	for i in range(0, 9, 4):
		dice.shuffle()
		blocks[i].assign_all(dice)
	dice.shuffle()
	await helper_dfs.call(dice, helper_dfs, 0)
	random_fill_finished.emit()


func _recompile() -> void: # re-construct data structures from rows
	for i in range(9):
		var row : House = rows[i]
		for j in range(9):
			var current_cell : Cell = row.content[j]
			var cell_index : int = 9 * i + j
			
			cells[cell_index] = current_cell
			current_cell.coords = Vector2(j, i)
			columns[j].content[i] = current_cell
			var block_index := i / 3 * 3 + j / 3
			var sub_block_index := i % 3 * 3 + j % 3
			blocks[block_index].content[sub_block_index] = current_cell

func _init() -> void:
	_populate()
	
func _populate() -> void: # fill each array with their data structure
	for arr_house : Array[House] in [columns, rows, blocks]:
		arr_house.resize(9)
		for i in range(9):
			var house : House = House.new()
			house.content.resize(9) 
			arr_house[i] = house
			
			
	for row in rows:
		for i in range(9):
			var new_cell := Cell.new()
			new_cell.grid = self
			new_cell.notes_bits.create(Vector2i(10, 1))
			row.content[i] = new_cell
	cells.resize(81)
	_recompile()

func _generic_fill() -> void: # fill the grid with a less random approach
	var dice := range(1, 10)
	dice.shuffle()
	var base_array = dice.duplicate()
	var shift_1 = 3
	var shift_2 = 1
	for i in range(0, 8, 3):
		for j in range(3):
			rows[i+j].assign_all(base_array)
			base_array = base_array.slice(shift_1) + base_array.slice(0, shift_1)
		base_array = base_array.slice(shift_2) + base_array.slice(0, shift_2)


func _to_string() -> String: # appropiate string representation
	var arr : Array = []
	for i in rows:
		arr.append(str(i))
	arr.insert(6, '\n')
	arr.insert(3, '\n')
	return '\n'.join(arr)


#region translational
func rotate(by : int = 1) -> void: # rotate anti-clockwise, can be used to generate new puzzles from old puzzle
	by %= 4
	match by:
		0:
			return
		1:
			var temp = rows
			rows = columns
			columns = temp
			rows.reverse()
		2:
			rows.reverse()
			for row in rows:
				row.content.reverse()
		3:
			var temp = rows
			rows = columns
			columns = temp
			for row in rows:
				row.content.reverse()
	_recompile()

func mirror(dir : directions) -> void: # mirror the grid 
	match dir:
		directions.LEFT, directions.RIGHT:
			for row in rows:
				row.content.reverse()
		directions.UP, directions.DOWN:
			rows.reverse()
	_recompile()

func transpose(): # matrix transpose
	rows = columns
	_recompile()

func swap_row(a: int, b: int) -> void: #swapping 2 rows by their index
	if a == b: return
	var temp = rows.duplicate()
	rows[a] = temp[b]
	rows[b] = temp[a]
	_recompile()

func swap_col(a: int, b: int) -> void: # swapping 2 columns by their index
	for row in rows:
		var temp = row.content[a]
		row.content[a] = row.content[b]
		row.content[b] = temp
	_recompile()

func shift(dir : directions) -> void:
	match dir:
		directions.LEFT:
			for row in rows:
				row.content = row.content.slice(3) + row.content.slice(0, 3)
		directions.RIGHT:
			for row in rows:
				row.content = row.content.slice(6) + row.content.slice(0, 6)
		directions.UP:
			rows = rows.slice(3) + rows.slice(0, 3)
		directions.DOWN:
			rows = rows.slice(6) + rows.slice(0, 6)

#endregion
