extends RefCounted
class_name CageCluster

## the list of cages in the cluster
var content : Array[Cage]

func _populate(size: int = 34) -> void: # add cages to this data structure
	content.resize(size)
	for i in range(content.size()):
		content[i] = Cage.new()

func _add_cell_to_cage(cell: Cell, cage: Cage):
	cage.add_cell(cell)
	prints("added", cell.coords, "to cage")

## force the number of cage heads to increase to match the number (only increase, does not delete existing cages)
func fulfill_cage_heads(number: int, grid : Grid) -> void:
	print("#existing cage: ", content.size(), " Still need: ", number - content.size())
	if not content.size() < number:
		return
	var not_has_cage := func(c: Cell) -> bool: 
		if c.cage: 
			return false 
		return true
	var dice : Array[Cell] = grid.cells.duplicate().filter(not_has_cage)
	dice.shuffle()
	content.resize(number)
	for i in range(number):
		if content[i]:
			continue
		content[i] = Cage.new()
		var cell : Cell = dice.pop_back()
		while cell.cage:
			cell = dice.pop_back()
		content[i].add_cell(cell)

signal cages_filled
signal cages_filled_progress(f: float)


## A simple random method of generating the cage heads + expanding them
func fill(grid : Grid): 
	var cage_number = randi_range(32, 34)
	fulfill_cage_heads(cage_number, grid)
	await expand_cage_heads(grid)
	cages_filled.emit()

## a more robust method of creating cages such that the board only has 1 solution
func fill_strategy_2(grid: Grid):
	## a recursive lambda function to compute nCr with array elements
	var combination := func (arr : Array, choose: int, callback: Callable) -> Array:
		if choose == 1:
			return arr.map(func(v):
				return [v])
		if arr.size() == choose:
			return [arr]
		var next := arr.slice(1)
		return callback.call(next, choose - 1, callback).map(func(v : Array):
			return [arr[0]] + v
			) + callback.call(next, choose, callback)
	## the helper function to slice away possible "cage cycles" to prevent having more than 1 solution (prevent unsolvable sudoku)
	var helper := func(arr_h: Array[House]):
		for i in range(0, 9, 3):
			var combinations : Array = combination.call(arr_h.slice(i, i+3), 2, combination)
			#var forced_cage_indices : Array[int] = []
			for combo : Array in combinations:
				var row_1 : House = combo[0]
				var row_2 : House = combo[1]
				var numbers_checked : Array[int] = []
				var dice := range(1, 10)
				dice.shuffle()
				
				for original_number : int in dice:
					if original_number in numbers_checked:
						continue
					var cycle : Array[int] = [original_number]
					var index_1 := row_1.content.find_custom(func(c: Cell): return c.number == original_number)
					var next_number := row_2.content[index_1].number
					while next_number != original_number:
						await Game.sleep(1)
						cycle.append(next_number)
						var next_index := row_1.content.find_custom(func(c: Cell): return c.number == next_number)
						next_number = row_2.content[next_index].number
					
					# once cycle is found, add to array as "checked numbers"
					numbers_checked.append_array(cycle)
					# if cycle size > 4, the probability of forming a cycle is low, thus we ignore it and let rng handle it
					if cycle.size() > 4:
						continue
					## get all cells that already belong in a cage within a House object
					var caged_cells_in_cycle := func(h: House) -> Array:
						var new_arr := []
						var con = h.content
						for cell_index in range(con.size()):
							if con[cell_index].cage and con[cell_index].number in cycle:
								new_arr.append(cell_index)
						return new_arr
						
					# now we try to compare the already caged cells between the 2 house object
					var indices : Array = caged_cells_in_cycle.call(row_1)
					var indices_2 : Array = caged_cells_in_cycle.call(row_2)
					# condition to check if cycle is already broken by other means already
					if indices.any(func(i: int) -> bool: return i in indices_2):
						# we skip to next set if already broken
						continue
					# if we still need to break them up
					# if they have cage then we prefer adding a single cage near them rather than adding 2 cages at a totally random position (to reduce the cage heads dureign creation)
					if indices or indices_2:
						index_1 = (indices + indices_2).pick_random()
					
					var target_cell : Cell = row_1.content[index_1]
					if not target_cell.cage:
						var cage : Cage = Cage.new()
						cage.add_cell(target_cell)
						content.append(cage)
					target_cell = row_2.content[index_1]
					if not target_cell.cage:
						var cage : Cage = Cage.new()
						cage.add_cell(target_cell)
						content.append(cage)
	
	await helper.call(grid.rows)
	await helper.call(grid.columns)
	sprinkle_cage_heads(grid.blocks, 3)
	var target_cage_count := randi_range(32, 34)
	fulfill_cage_heads(target_cage_count, grid)
			
	await expand_cage_heads(grid)
	for i in content:
		print(i)
	cages_filled.emit()

## iteratively expand existing cages to fully fill the grid
func expand_cage_heads(grid : Grid):
	var _discard : Array = []
	for cage in content:
		_discard.append_array(cage.content)
	var _pointer : int = 0
	var _content_clone : Array = content.duplicate()
	var _process_counter : int = 0
	while _content_clone:
		_process_counter += 1
		if _process_counter > Game.generator.performance_throttle:
			await Game.sleep(1)
			cages_filled_progress.emit(1 - _content_clone.size() / content.size())
			_process_counter = 0
		_pointer %= _content_clone.size()
		
		var current : Cage = _content_clone[_pointer]
		var _added_numbers = current.content.map(func(v: Cell): return v.number)

		var neighbor_vec : Array[Vector2] = current.get_adjacent()
		var neighbor_cell : Array = neighbor_vec.map(func(v: Vector2i): return grid.cells[v.y * 9 + v.x])
		neighbor_cell = neighbor_cell.filter(func(c : Cell):
			if c in _discard:
				return false
			return not c.number in _added_numbers)
		if neighbor_cell.size() == 0:
			#_pointer += 1
			_content_clone.remove_at(_pointer)
			continue
		var pending_cell : Cell = neighbor_cell.pick_random()
		current.add_cell(pending_cell)
		_added_numbers.append(pending_cell.number)
		_discard.append(pending_cell)
		_pointer += 1
	
	for cage in content:
		cage.content.sort_custom(func(c1: Cell, c2: Cell):
			return c1.coords < c2.coords)

## simple "cage add" function based on the number of cage heads in selected set of House. to balance the density of cages
func sprinkle_cage_heads(order: Array[House], threshold_minimum : int):
	var not_has_cage := func(c: Cell) -> bool:
		if c.cage:
			return false	
		return true
	for house in order:
		var candidates : Array[Cell] = house.content.filter(not_has_cage)
		while candidates.size() > house.content.size() - threshold_minimum:
			var cell : Cell = candidates.pop_at(range(candidates.size()).pick_random())
			var cage := Cage.new()
			cage.add_cell(cell)
			content.append(cage)

func _init() -> void:
	Game.save_system.load_data.connect(read_from_save)

func read_from_save(data: Dictionary):
	if SaverLoader.DATATYPE.cage not in data:
		push_error("Data not found, cannot load")
		return
	var cage_list = data[SaverLoader.DATATYPE.cage]
	for coords_list in cage_list:
		 #each "cage" is just an array of cell coords for that cage
		#so can just populate the cages according to the list
		var cage := Cage.new()
		content.append(cage)
		## Coords of the cell in the list
		for coords : Vector2i in coords_list:
			# now need to get the cell from the coords
			# need grid reference
			var cell_to_be_added : Cell = Game.generator.grid.rows[coords.y].content[coords.x]
			cage.add_cell(cell_to_be_added)
