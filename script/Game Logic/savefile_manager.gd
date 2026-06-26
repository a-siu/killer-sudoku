extends RefCounted
class_name SaverLoader

const SAVE_PATH := "user://%s"

signal save_data(data: Dictionary)
signal load_data(data: Dictionary)

var _timer_ref: Node = null
var _loaded_elapsed_seconds: int = 0

enum DATATYPE {cell, cage}
var game_data_packet : Dictionary

func set_timer_ref(timer_node: Node) -> void:
	_timer_ref = timer_node
	if _loaded_elapsed_seconds > 0 and timer_node.has_method("set_seconds"):
		timer_node.set_seconds(_loaded_elapsed_seconds)


func open_file(path: String, access: FileAccess.ModeFlags) -> FileAccess:
	return FileAccess.open(path, access)
	return FileAccess.open_encrypted_with_pass(path, access, str(hash(path)))

func save_game(name : String) -> void:
	var elapsed := 0
	if _timer_ref and _timer_ref.has_method("get_seconds"):
		elapsed = _timer_ref.get_seconds()
	prints("Saving:", name, "elapsed:", elapsed)
	
	# Write timer meta before other components
	if _timer_ref and _timer_ref.has_method("get_seconds"):
		game_data_packet["elapsed_seconds"] = _timer_ref.get_seconds()
	
	save_data.emit(game_data_packet)	
	
	var file_path := SAVE_PATH % name
	var file_folder := SAVE_PATH % ''
	DirAccess.make_dir_recursive_absolute(file_folder)
	var file := open_file(file_path, FileAccess.WRITE) 
	#var file := ConfigFile.new()
	file.store_var(game_data_packet)
	file.close()
	prints("Saved:", name)

func load_game(name: String) -> void:
	var file_path := SAVE_PATH % name
	if !does_save_exist(name):
		push_error(error_string(ERR_FILE_NOT_FOUND))
		game_data_packet = Dictionary()
		return
	var file := open_file(file_path, FileAccess.READ)

	var _temp_data = file.get_var()
	if not _temp_data:
		push_error(error_string(ERR_QUERY_FAILED))
		_temp_data = Dictionary()
	file.close()
	
	game_data_packet = _temp_data.duplicate()
	# Store elapsed seconds for timer restoration
	_loaded_elapsed_seconds = game_data_packet.get("elapsed_seconds", 0)
	
	# If timer already registered, set it
	if _timer_ref and _timer_ref.has_method("set_seconds"):
		_timer_ref.set_seconds(_loaded_elapsed_seconds)
	
	load_data.emit(game_data_packet)
	

func does_save_exist(name: String) -> bool:
	var file_path := SAVE_PATH % name
	return FileAccess.file_exists(file_path)
