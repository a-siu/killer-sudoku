extends Label

@onready var timer: Timer = $Timer

var minutes : int:
	get:
		return int(float(seconds) / 60.0)
var seconds : int

func get_seconds() -> int:
	return seconds

func set_seconds(s: int) -> void:
	seconds = s
	text = "%02d" % minutes + ":" + "%02d" % (seconds % 60)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	seconds = 0
	timer.start()
	# Register with save system
	Game.save_system.set_timer_ref(self)


func _on_timer_timeout() -> void:
	seconds += 1
	text = "%02d" % minutes + ":" + "%02d" % (seconds % 60)
	timer.start()
