extends RefCounted
class_name Config


enum CONFIG {resolution, performance_throttle}

var config : Dictionary = {
	CONFIG.resolution: Vector2i(1080, 1920),
	CONFIG.performance_throttle: 20
}

func read_config() -> void:
	
	pass

func write_config() -> void:
	
	pass
	
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
