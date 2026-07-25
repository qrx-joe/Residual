extends Node

const DEFAULT_ACTIONS_PATH: String = "res://data/actions.json"
const SUPPORTED_SCHEMA_VERSION: int = 1
const REQUIRED_FIELDS: PackedStringArray = [
	"id",
	"display_name",
	"description",
	"prerequisites",
	"effects",
	"tags",
]

var actions_by_id: Dictionary = {}
var last_error: String = ""


func _ready() -> void:
	if not load_actions():
		push_error(last_error)


func load_actions(path: String = DEFAULT_ACTIONS_PATH) -> bool:
	actions_by_id.clear()
	last_error = ""
	if not FileAccess.file_exists(path):
		return _set_load_error("ACTIONS_FILE_NOT_FOUND")

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _set_load_error("ACTIONS_FILE_OPEN_FAILED")
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		return _set_load_error("ACTIONS_ROOT_INVALID")

	var payload: Dictionary = parsed
	if int(payload.get("schema_version", -1)) != SUPPORTED_SCHEMA_VERSION:
		return _set_load_error("ACTIONS_SCHEMA_UNSUPPORTED")
	var actions: Variant = payload.get("actions", [])
	if not actions is Array:
		return _set_load_error("ACTIONS_LIST_INVALID")

	for action_value: Variant in actions:
		if not action_value is Dictionary:
			return _set_load_error("ACTION_ENTRY_INVALID")
		var action: Dictionary = action_value
		for field: String in REQUIRED_FIELDS:
			if not action.has(field):
				return _set_load_error("ACTION_FIELD_MISSING:%s" % field)
		var action_id: StringName = StringName(String(action["id"]))
		if action_id == &"" or actions_by_id.has(action_id):
			return _set_load_error("ACTION_ID_INVALID:%s" % action_id)
		if (
			not action["prerequisites"] is Array
			or not action["effects"] is Array
			or not action["tags"] is Array
		):
			return _set_load_error("ACTION_COLLECTION_INVALID:%s" % action_id)
		actions_by_id[action_id] = action.duplicate(true)
	return true


func get_action(action_id: StringName) -> Dictionary:
	if not actions_by_id.has(action_id):
		return {}
	return (actions_by_id[action_id] as Dictionary).duplicate(true)


func execute_action(action_id: StringName) -> Dictionary:
	if not actions_by_id.has(action_id):
		return {
			"ok": false,
			"error": "UNKNOWN_ACTION_ID",
			"action_id": String(action_id),
		}

	var action: Dictionary = actions_by_id[action_id]
	var prerequisite_error: String = _check_prerequisites(
		action["prerequisites"] as Array
	)
	if not prerequisite_error.is_empty():
		return {
			"ok": false,
			"error": prerequisite_error,
			"action_id": String(action_id),
		}

	for effect_value: Variant in action["effects"] as Array:
		if not effect_value is Dictionary:
			return {"ok": false, "error": "EFFECT_INVALID"}
		var effect_result: Dictionary = _apply_effect(effect_value)
		if not bool(effect_result.get("ok", false)):
			return effect_result
	return {"ok": true, "action": action.duplicate(true)}


func _check_prerequisites(prerequisites: Array) -> String:
	var game_state: Node = get_node("/root/GameState")
	for prerequisite_value: Variant in prerequisites:
		if not prerequisite_value is Dictionary:
			return "PREREQUISITE_INVALID"
		var prerequisite: Dictionary = prerequisite_value
		var state_name: String = String(prerequisite.get("state", ""))
		var key: StringName = StringName(String(prerequisite.get("key", "")))
		var expected: Variant = prerequisite.get("equals")
		var state: Variant = game_state.get(state_name)
		if not state is Dictionary or (state as Dictionary).get(key) != expected:
			return "PREREQUISITE_NOT_MET"
	return ""


func _apply_effect(effect: Dictionary) -> Dictionary:
	if String(effect.get("operation", "")) != "SET":
		return {"ok": false, "error": "EFFECT_OPERATION_UNSUPPORTED"}
	var target_name: String = String(effect.get("target", ""))
	if target_name not in [
		"world_state",
		"player_knowledge",
		"persona_state",
		"residual_state",
	]:
		return {"ok": false, "error": "EFFECT_TARGET_INVALID"}

	var game_state: Node = get_node("/root/GameState")
	var target: Dictionary = game_state.get(target_name)
	target[StringName(String(effect.get("key", "")))] = effect.get("value")
	return {"ok": true}


func _set_load_error(error: String) -> bool:
	last_error = error
	return false
