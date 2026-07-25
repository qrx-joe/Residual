extends SceneTree

const ACTION_MANAGER_SCRIPT: Script = preload(
	"res://scripts/managers/action_manager.gd"
)
const EXTRA_ACTIONS_PATH: String = "user://t2_1_extra_actions.json"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_state: Node = root.get_node("GameState")
	game_state.set("world_state", {})
	var action_manager: Node = ACTION_MANAGER_SCRIPT.new()
	root.add_child(action_manager)

	if (action_manager.get("actions_by_id") as Dictionary).size() != 12:
		_fail("actions.json did not load all twelve actions")
		return
	var phone: Dictionary = action_manager.call(
		&"get_action",
		&"INSPECT_PHOTO"
	)
	if String(phone.get("display_name", "")) != "检查合照":
		_fail("UI presentation was not loaded from actions.json")
		return
	if not phone.get("tags", []).has("photo"):
		_fail("Action tags were not loaded")
		return

	var result: Dictionary = action_manager.call(
		&"execute_action",
		&"INSPECT_PHOTO"
	)
	if not bool(result.get("ok", false)):
		_fail("Valid action did not execute")
		return
	var world_state: Dictionary = game_state.get("world_state")
	if not bool(world_state.get(&"photo_inspected", false)):
		_fail("Action effect was not applied through ActionManager")
		return

	var before_invalid: Dictionary = world_state.duplicate(true)
	var invalid: Dictionary = action_manager.call(
		&"execute_action",
		&"NOT_A_REAL_ACTION"
	)
	if bool(invalid.get("ok", true)):
		_fail("Invalid action ID was accepted")
		return
	if String(invalid.get("error", "")) != "UNKNOWN_ACTION_ID":
		_fail("Invalid action ID did not return the safe error")
		return
	if world_state != before_invalid:
		_fail("Invalid action ID mutated game state")
		return

	var source_file: FileAccess = FileAccess.open(
		"res://data/actions.json",
		FileAccess.READ
	)
	var extra_payload: Dictionary = JSON.parse_string(source_file.get_as_text())
	source_file.close()
	(extra_payload["actions"] as Array).append({
		"id": "TEST_ACTION",
		"region": "TEST",
		"display_name": "测试行动",
		"description": "由 JSON 新增，不修改 UI 处理逻辑。",
		"cost": 1,
		"prerequisites": [],
		"effects": [],
		"tags": ["test"],
	})
	var extra_file: FileAccess = FileAccess.open(
		EXTRA_ACTIONS_PATH,
		FileAccess.WRITE
	)
	extra_file.store_string(JSON.stringify(extra_payload))
	extra_file.close()
	if not bool(action_manager.call(&"load_actions", EXTRA_ACTIONS_PATH)):
		_fail("ActionManager could not load a newly added JSON action")
		return
	if (
		action_manager.call(&"get_action", &"TEST_ACTION") as Dictionary
	).is_empty():
		_fail("New JSON action required code-specific UI logic")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(EXTRA_ACTIONS_PATH))
	print("T2.1 smoke: JSON actions, effects, tags, safe invalid ID")
	quit(0)


func _fail(message: String) -> void:
	if FileAccess.file_exists(EXTRA_ACTIONS_PATH):
		DirAccess.remove_absolute(
			ProjectSettings.globalize_path(EXTRA_ACTIONS_PATH)
		)
	push_error(message)
	quit(1)
