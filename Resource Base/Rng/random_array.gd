extends Resource
class_name RandomArray

var rng : RandomNumberGenerator
var value : Array
var _current_index : int = 0

var shuffled:
	get:
		var dice : RandomArray = RandomArray.new(range(1, 10), rng)
		dice.rng.state = rng.state
		dice.shuffle()
		return dice

@warning_ignore("shadowed_variable")
func _init(arr: Array, rng : RandomNumberGenerator = RandomNumberGenerator.new()) -> void:
	value = Array(arr)
	self.rng = rng
	shuffle()

func shuffle():
	for i in range(len(value)):
		_swap(i, rng.randi_range(i, len(value) - 1))



func _swap(a : int, b: int):
	if a == b:
		return
	var temp = value[a]
	value[a] = value[b]
	value[b] = temp

func next() -> int:
	var next_value = value[_current_index]
	_current_index += 1
	_current_index %= len(value)
	return next_value
