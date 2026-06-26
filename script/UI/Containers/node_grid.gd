extends GridContainer
class_name NodeSquareGrid

@export var scene_of_node : PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	populate()
	
func populate() -> void:
	if scene_of_node == null:
		return
	var count = columns * columns
	for i in range(count):
		var node = scene_of_node.instantiate()
		add_child(node)
