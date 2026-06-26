extends Node
class_name Config



func read_config() -> void:
	pass

func write_config() -> void:
	var _config_json = JSON.new()
	var _has_config = get_tree().get_nodes_in_group("has_config")

	pass
	
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
