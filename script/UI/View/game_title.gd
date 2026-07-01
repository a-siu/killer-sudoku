extends RichTextLabel
class_name GameTitle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func add_loading_text() -> void:
	push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
	push_font_size(24)
	push_italics()
	append_text('[pulse freq=2.0]%s[/pulse]' % 'Generating...')
	pop_all()
	
