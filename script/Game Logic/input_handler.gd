extends Resource
class_name InputHandler

var undo_manager : UndoRedo = UndoRedo.new()
var grid : Grid:
	get:
		return Game.generator.grid

func _init() -> void:
	undo_manager.max_steps = 50


signal draft_toggled(state: bool)
var is_drafting : bool:
	set(v):
		is_drafting = v
		draft_toggled.emit(v)


enum State {SELECTED, IDLE}
signal transitioned(state: State)
var selection_state : State = State.IDLE:
	set(v):
		if v == selection_state:
			return
		selection_state = v
		transitioned.emit(v)
		
signal cell_selected(v: Vector2i)
var selected_cell : Cell
func selection_changed(v: Vector2i):
	if selection_state == State.IDLE:
		selection_state = State.SELECTED
		selected_cell = grid.rows[v.y].content[v.x]
		cell_selected.emit(v)
		prints("Cell Selected:", selected_cell.coords)

		return
		
	if selected_cell.coords == v:
		selection_state = State.IDLE
		cell_selected.emit(Vector2i(0, 0))
		prints("Selection Cancelled")
		return
	
	selected_cell = grid.rows[v.y].content[v.x]
	cell_selected.emit(v)
	prints("Cell Selected:", v)

signal answer_write(cell: Vector2i, num: int)
signal note_write(cell: Vector2i, num: int)
func assign(number: int):
	if selection_state == State.IDLE:
		return
	prints("Input Received:", number)

	if is_drafting:
		var cell_notes : BitMap = selected_cell.notes_bits.duplicate()
		cell_notes.set_bit(number, 0, !cell_notes.get_bit(number, 0))
		undo_manager.create_action("Toggling note")
		undo_manager.add_do_property(selected_cell, "notes_bits", cell_notes)
		undo_manager.add_undo_property(selected_cell, "notes_bits", selected_cell.notes_bits)
		undo_manager.commit_action()
		note_write.emit(selected_cell.coords, number)
		return
		
	undo_manager.create_action("Write answer")
	undo_manager.add_do_property(selected_cell, "display", number)
	undo_manager.add_undo_property(selected_cell, "display", selected_cell.display)
	var new_draft : BitMap = BitMap.new()
	new_draft.resize(Vector2i(10, 1))
	undo_manager.add_do_property(selected_cell, "notes_bits", new_draft)
	undo_manager.add_undo_property(selected_cell, "notes_bits", selected_cell.notes_bits)
	for cell : Cell in selected_cell.get_influence():
		var cell_notes : BitMap = cell.notes_bits.duplicate()
		if cell_notes.get_bit(number, 0):
			cell_notes.set_bit(number, 0, false)
			undo_manager.add_do_property(cell, "notes_bits", cell_notes)
			undo_manager.add_undo_property(cell, "notes_bits", cell.notes_bits)
	
	undo_manager.commit_action()
	answer_write.emit(selected_cell.coords, number)


func smart_hint() -> void:
	pass

func undo_wrapper() -> void:
	if undo_manager.has_undo():
		undo_manager.undo()

func erase() -> void:
	if selection_state == State.IDLE:
		return
	var new_draft : BitMap = BitMap.new()
	new_draft.resize(Vector2i(10, 1))
	undo_manager.create_action("Erase")
	undo_manager.add_do_property(selected_cell, "display", 0)
	undo_manager.add_undo_property(selected_cell, "display", selected_cell.display)
	undo_manager.add_do_property(selected_cell, "notes_bits", new_draft)
	undo_manager.add_undo_property(selected_cell, "notes_bits", selected_cell.notes_bits)
	undo_manager.commit_action()


func passed_input(event: InputEvent) -> void:
	for i in range(1, 10):
		if event.is_action_pressed("input_" + str(i)):
			assign(i)
			return
	if event.is_action_pressed("input_erase"):
		erase()
		return
	if event.is_action_pressed("ui_undo"):
		undo_wrapper()
		return
	if event.is_action_pressed("input_debug"):
		for cell in grid.cells:
			cell.display = cell.number
		#prints("====== Running Tests (P key) ======")
		#var passed := await TestRunner.run_all()
		#if passed:
			#prints("ALL TESTS PASSED")
		#else:
			#prints("SOME TESTS FAILED")
		#prints("====== Tests Done ======")
