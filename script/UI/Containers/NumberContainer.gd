extends Container

@onready var sprite_2d: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resized.connect(_on_resized)
	_on_resized()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	

func _on_resized():
	var children = get_children()
	if len(children) == 0:
		return
	
	for child in children:
		var true_size = child.texture.get_image().get_size()
		var MBSquare = max(true_size.x, true_size.y) * Vector2(1, 1)
		child.scale = scale / MBSquare
		print("Children ", child, " scaled to ", child.scale)
		child.position = size / 2
		print("Children ", child, " moved to ", child.position)
