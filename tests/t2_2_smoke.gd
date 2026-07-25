extends SceneTree

const ACTION_MANAGER_SCRIPT: Script = preload(
	"res://scripts/managers/action_manager.gd"
)
const FIRST_LOOP_MANAGER_SCRIPT: Script = preload(
	"res://scripts/managers/first_loop_content_manager.gd"
)
const RESIDUAL_MANAGER_SCRIPT: Script = preload(
	"res://scripts/managers/residual_data_manager.gd"
)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_state: Node = root.get_node("GameState")
	var action_manager: Node = ACTION_MANAGER_SCRIPT.new()
	var first_loop_manager: Node = FIRST_LOOP_MANAGER_SCRIPT.new()
	var residual_manager: Node = RESIDUAL_MANAGER_SCRIPT.new()
	root.add_child(action_manager)
	root.add_child(first_loop_manager)
	root.add_child(residual_manager)

	_reset_state(game_state)
	first_loop_manager.call(&"initialize_loop", 1)
	var world_state: Dictionary = game_state.get("world_state")
	if not bool(world_state.get(&"crisis_visible", false)):
		_fail("The 03:00 crisis was not visible at first-loop start")
		return

	var first_phone: Dictionary = action_manager.call(
		&"get_available_action_for_region",
		&"PHONE"
	)
	if String(first_phone.get("id", "")) != "INSPECT_PHOTO":
		_fail("Photo was not the first phone action")
		return
	action_manager.call(&"execute_action", &"INSPECT_PHOTO")
	var second_phone: Dictionary = action_manager.call(
		&"get_available_action_for_region",
		&"PHONE"
	)
	if String(second_phone.get("id", "")) != "PLAY_AUDIO":
		_fail("Audio was not the second phone action")
		return
	action_manager.call(&"execute_action", &"PLAY_AUDIO")
	action_manager.call(&"execute_action", &"SCAN_COMPUTER")
	if not bool(first_loop_manager.call(&"should_offer_choice", 1)):
		_fail("Delete/keep choice did not appear after three actions")
		return

	var delete_result: Dictionary = action_manager.call(
		&"execute_action",
		&"DELETE_AUDIO"
	)
	if not bool(delete_result.get("ok", false)):
		_fail("Delete choice could not execute")
		return
	var failure: Dictionary = first_loop_manager.call(
		&"complete_choice",
		&"DELETE_AUDIO"
	)
	residual_manager.call(&"record_recording_deletion")
	if (
		not bool(world_state.get(&"evidence_extracted", false))
		or bool(world_state.get(&"soundprint_available", true))
	):
		_fail("Delete did not create the evidence/soundprint conflict")
		return
	if not bool(world_state.get(&"read_again_prompted", false)):
		_fail("First-loop failure did not actively prompt another load")
		return
	if not String(failure.get("detail", "")).contains("读取 SAVE_01"):
		_fail("Failure result did not explain how to continue")
		return
	if not bool(
		(game_state.get("residual_state") as Dictionary).get(
			&"recording_deleted",
			false
		)
	):
		_fail("Delete choice did not record its cross-loop cause")
		return

	_reset_state(game_state)
	first_loop_manager.call(&"initialize_loop", 1)
	action_manager.call(&"load_actions")
	action_manager.call(&"execute_action", &"SCAN_COMPUTER")
	var keep_result: Dictionary = action_manager.call(
		&"execute_action",
		&"KEEP_AUDIO"
	)
	if not bool(keep_result.get("ok", false)):
		_fail("Keep choice could not execute")
		return
	var delete_after_keep: Dictionary = action_manager.call(
		&"execute_action",
		&"DELETE_AUDIO"
	)
	if bool(delete_after_keep.get("ok", false)):
		_fail("Mutually exclusive first-loop choices both executed")
		return

	print("T2.2 smoke: crisis, photo/audio/computer, exclusive choice, reload need")
	quit(0)


func _reset_state(game_state: Node) -> void:
	game_state.set("loop_index", 1)
	game_state.set("world_state", {})
	game_state.set("player_knowledge", {})
	game_state.set("persona_state", {})
	game_state.set("residual_state", {})
	game_state.set("history", [])


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
