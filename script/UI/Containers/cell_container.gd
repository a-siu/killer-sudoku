extends AspectRatioContainer
class_name CellContainer

@export var answer: NumberLabel
@export var draft: GridContainer
@export var cage_component : Control

var cell : Cell:
	set(v):
		if cell:
			cell.notes_changed.disconnect(refresh)
			cell.display_changed.disconnect(refresh)
		cell = v
		cell.notes_changed.connect(refresh)
		cell.display_changed.connect(refresh)
		cage_component.queue_redraw()
		refresh()

func refresh() -> void:
	answer.number = cell.display
	for i in range(1, 10):
		set_note_visibility(i, cell.notes_bits.get_bit(i, 0))

func _draft_find(number : int) -> int:
	return draft.get_children().find_custom(func(c : NumberLabel):
		return c.number == number
		)

func _get_label(number : int) -> NumberLabel:
	return draft.get_children()[_draft_find(number)]

	
func set_note_visibility(number: int, state: bool) -> void:
	_get_label(number).self_modulate.a = int(state)

func _ready() -> void:
	hide_all_note()
		
func hide_all_note() -> void:
	for child : NumberLabel in draft.get_children():
		child.self_modulate.a = 0
