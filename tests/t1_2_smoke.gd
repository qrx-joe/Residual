extends SceneTree

const LOOP_MANAGER_SCRIPT: Script = preload(
	"res://scripts/managers/loop_manager.gd"
)
const GAME_STATE_SCRIPT: Script = preload(
	"res://scripts/autoload/game_state.gd"
)
const EXPECTED_TIMES: PackedStringArray = [
	"02:50",
	"02:53",
	"02:56",
	"03:00",
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var manager: Node = LOOP_MANAGER_SCRIPT.new()
	root.add_child(manager)
	manager.call(&"start_loop", 1)

	if int(manager.get("actions_remaining")) != 4:
		_fail("Loop did not start with four actions")
		return

	var action_ids: Array[StringName] = [
		&"PHONE",
		&"COMPUTER",
		&"DRAWER",
		&"PHONE",
	]
	for index: int in range(action_ids.size()):
		var accepted: bool = bool(
			manager.call(&"request_action", action_ids[index])
		)
		if not accepted:
			_fail("Action %d was unexpectedly rejected" % (index + 1))
			return

		var duplicate_accepted: bool = bool(
			manager.call(&"request_action", &"DRAWER")
		)
		if duplicate_accepted:
			_fail("Resolving lock accepted a duplicate action")
			return

		manager.call(&"complete_action", action_ids[index])
		var expected_remaining: int = 3 - index
		if int(manager.get("actions_remaining")) != expected_remaining:
			_fail("Remaining actions are incorrect after action %d" % (index + 1))
			return
		if String(manager.call(&"get_display_time")) != EXPECTED_TIMES[index]:
			_fail("Time is incorrect after action %d" % (index + 1))
			return

	var game_state: Node = root.get_node("GameState")
	var game_state_constants: Dictionary = (
		GAME_STATE_SCRIPT.get_script_constant_map()
	)
	var phase_values: Dictionary = game_state_constants["Phase"]
	var loop_timeout_phase: int = int(phase_values["LOOP_TIMEOUT"])
	if int(game_state.get("phase")) != loop_timeout_phase:
		_fail("Fourth action did not enter LOOP_TIMEOUT")
		return

	var fifth_accepted: bool = bool(manager.call(&"request_action", &"COMPUTER"))
	if fifth_accepted:
		_fail("Action was accepted after timeout")
		return

	manager.call(&"complete_action", &"COMPUTER")
	if int(manager.get("actions_remaining")) != 0:
		_fail("Actions remaining dropped below zero")
		return

	print("T1.2 smoke: 4 actions, deterministic time, global lock, timeout")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
