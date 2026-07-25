extends Node

const SAVE_PATH: String = "user://residual_save_v1.json"
const SCHEMA_VERSION: int = 1
const BUILD_VERSION: String = "0.1.0"

var _world_snapshot: Dictionary = {}
var _active_save_path: String = SAVE_PATH


func _ready() -> void:
	var save_path_override: String = OS.get_environment(
		"RESIDUAL_SAVE_PATH"
	)
	if not save_path_override.is_empty():
		_active_save_path = save_path_override

	if OS.get_environment("RESIDUAL_DISABLE_PERSISTENCE") != "1":
		load_persistent_state()


func get_save_path() -> String:
	return _active_save_path


func create_world_snapshot() -> void:
	var game_state: Node = get_node("/root/GameState")
	var world_state: Dictionary = game_state.get("world_state")
	_world_snapshot = world_state.duplicate(true)


func has_world_snapshot() -> bool:
	return not _world_snapshot.is_empty()


func restore_world_snapshot() -> bool:
	if not has_world_snapshot():
		return false

	var game_state: Node = get_node("/root/GameState")
	game_state.set("world_state", _world_snapshot.duplicate(true))
	return true


func get_world_snapshot() -> Dictionary:
	return _world_snapshot.duplicate(true)


func clear_world_snapshot() -> void:
	_world_snapshot.clear()


func save_persistent_state(path_override: String = "") -> bool:
	var target_path: String = (
		path_override if not path_override.is_empty() else _active_save_path
	)
	var game_state: Node = get_node("/root/GameState")
	var payload: Dictionary = {
		"schema_version": SCHEMA_VERSION,
		"build_version": BUILD_VERSION,
		"game_state": {
			"loop_index": int(game_state.get("loop_index")),
		},
		"player_knowledge": (
			game_state.get("player_knowledge") as Dictionary
		).duplicate(true),
		"persona_state": (
			game_state.get("persona_state") as Dictionary
		).duplicate(true),
		"residual_state": (
			game_state.get("residual_state") as Dictionary
		).duplicate(true),
		"history": (game_state.get("history") as Array).duplicate(true),
		"settings": {},
	}

	var file: FileAccess = FileAccess.open(target_path, FileAccess.WRITE)
	if file == null:
		push_error("Could not open save path for writing: %s" % target_path)
		return false

	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	return true


func load_persistent_state(path_override: String = "") -> bool:
	var target_path: String = (
		path_override if not path_override.is_empty() else _active_save_path
	)
	if not FileAccess.file_exists(target_path):
		return false

	var file: FileAccess = FileAccess.open(target_path, FileAccess.READ)
	if file == null:
		push_error("Could not open save path for reading: %s" % target_path)
		return false

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		push_error("Save file is not a JSON object: %s" % target_path)
		return false

	var payload: Dictionary = parsed
	if int(payload.get("schema_version", -1)) != SCHEMA_VERSION:
		push_error("Unsupported save schema: %s" % target_path)
		return false

	var game_state_data: Variant = payload.get("game_state", {})
	if not game_state_data is Dictionary:
		return false

	var game_state: Node = get_node("/root/GameState")
	game_state.set(
		"loop_index",
		int((game_state_data as Dictionary).get("loop_index", 0))
	)
	_restore_dictionary(payload, "player_knowledge", game_state)
	_restore_dictionary(payload, "persona_state", game_state)
	_restore_dictionary(payload, "residual_state", game_state)

	var saved_history: Variant = payload.get("history", [])
	if saved_history is Array:
		game_state.set("history", (saved_history as Array).duplicate(true))
	return true


func _restore_dictionary(
	payload: Dictionary,
	key: String,
	game_state: Node
) -> void:
	var saved_value: Variant = payload.get(key, {})
	if saved_value is Dictionary:
		game_state.set(key, (saved_value as Dictionary).duplicate(true))
