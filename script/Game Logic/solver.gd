extends Resource
class_name Solver



static func sleep(frame: int = 1):
	for i in range(frame):
		await Game.get_tree().process_frame

static func sum(arr : Array) -> int:
	if not arr.all(func(v): return is_instance_of(v, TYPE_INT)):
		return 0
	var added := 0
	for n : int in arr:
		added += n
	return added
	
static func _get_possible_daughters(number: int, max: int, choose: int) -> Array:
	if choose == 1:
		if number in range(1, max+1):
			return [number]
		return []
	if sum(range(max, max-choose, -1)) < number:
		return []
	var next : int = min(max, number)
	return _get_possible_daughters(number, next - 1, choose) + _get_possible_daughters(number - next, next - 1, choose - 1).map(func(arr: Array): return arr + [next])
	#number - max, max - 1, choose - 1
	
	
func label_cages():
	var input = Game.input
	for cage in Game.generator.cages.content:
		var combinations := _get_possible_daughters(cage.sum, 9, cage.content.size())
		if cage.content.size() == 1:
			input.selection_changed(cage.content[0].coords)
			input.is_drafting = false
			input.assign(combinations[0][0])
			continue
		
		
			
