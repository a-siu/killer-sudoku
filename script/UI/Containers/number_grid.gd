extends NodeSquareGrid
class_name NumberGrid

enum Parameter {COLOR, FONT_SIZE}

@export var color : Color = Color.WHITE:
	set(v):
		color = v
		_update(Parameter.COLOR)

@export var numbers: Array[int] = [7,8,9,4,5,6,1,2,3]:
	set(v):
		numbers = v
		resort_by_layout()

@export var font_size: int = 32:
	set(v):
		font_size = v
		_update(Parameter.FONT_SIZE)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init()

func init() -> void:
	populate()
	resort_by_layout()
	
signal numbers_sorted
func resort_by_layout() -> void:
	if len(get_children()) == 0:
		return
	var nodes : Array[Node] = get_children()
	for i in range(len(numbers)):
		nodes[i].number = numbers[i]
	numbers_sorted.emit()


func _update(param: Parameter) -> void:
	if len(get_children()) == 0:
		return
	for child in get_children():
		if param == Parameter.COLOR:
			child.color = color
			continue
		if param == Parameter.FONT_SIZE:
			child.font_size = font_size
			continue
