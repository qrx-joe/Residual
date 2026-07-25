extends SceneTree

const RESIDUAL_MANAGER_SCRIPT: Script = preload(
	"res://scripts/managers/residual_data_manager.gd"
)
const SECOND_LOOP_MANAGER_SCRIPT: Script = preload(
	"res://scripts/managers/second_loop_content_manager.gd"
)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_state: Node = root.get_node("GameState")
	var residual_manager: Node = RESIDUAL_MANAGER_SCRIPT.new()
	var second_loop_manager: Node = SECOND_LOOP_MANAGER_SCRIPT.new()
	root.add_child(residual_manager)
	root.add_child(second_loop_manager)

	_reset_state(game_state)
	residual_manager.call(&"record_recording_deletion")
	if not bool(residual_manager.call(&"prepare_loop", 2)):
		_fail("Deletion path did not guarantee a second-loop residual")
		return
	if not bool(residual_manager.call(&"has_ghost_recording")):
		_fail("Deletion path did not create the ghost recording")
		return

	game_state.set("loop_index", 2)
	second_loop_manager.call(&"initialize_loop", 2)
	var world_state: Dictionary = game_state.get("world_state")
	if not bool(world_state.get(&"audio_exists", false)):
		_fail("Second-loop restart did not initialize the audio state")
		return
	world_state[&"audio_played"] = true
	world_state[&"evidence_found"] = true
	world_state[&"first_loop_choice"] = "DELETE"
	var second_delete: Dictionary = second_loop_manager.call(
		&"complete_choice",
		&"DELETE_AUDIO",
		residual_manager
	)
	if not bool(second_delete.get("ok", false)):
		_fail("Second deletion did not resolve")
		return
	var residual_state: Dictionary = game_state.get("residual_state")
	var persona_state: Dictionary = game_state.get("persona_state")
	if int(residual_state.get(&"recording_deletion_count", 0)) != 2:
		_fail("Second deletion cause count is not two")
		return
	if not bool(residual_state.get(&"complete_ghost_recording", false)):
		_fail("Second deletion did not complete the ghost recording")
		return
	if int(persona_state.get(&"obsession", 0)) != 2:
		_fail("Second deletion did not apply obsession +2")
		return
	if not bool(second_loop_manager.call(&"enter_negotiation")):
		_fail("Deletion path did not open the negotiation entry")
		return

	_reset_state(game_state)
	residual_manager.call(&"record_recording_preservation")
	if not bool(residual_manager.call(&"prepare_loop", 2)):
		_fail("Preservation path did not guarantee a residual")
		return
	if not bool(residual_manager.call(&"has_ghost_evidence_header")):
		_fail("Preservation path did not create a ghost evidence header")
		return

	game_state.set("loop_index", 2)
	second_loop_manager.call(&"initialize_loop", 2)
	world_state = game_state.get("world_state")
	world_state[&"audio_played"] = true
	world_state[&"evidence_found"] = true
	world_state[&"first_loop_choice"] = "KEEP"
	var second_keep: Dictionary = second_loop_manager.call(
		&"complete_choice",
		&"KEEP_AUDIO",
		residual_manager
	)
	if not bool(second_keep.get("ok", false)):
		_fail("Second preservation did not resolve")
		return
	persona_state = game_state.get("persona_state")
	if int(persona_state.get(&"trust", 0)) != 1:
		_fail("Second preservation did not apply trust +1")
		return
	if not bool(second_loop_manager.call(&"enter_negotiation")):
		_fail("Preservation path did not open the negotiation entry")
		return

	print("T2.3 smoke: guaranteed residuals, second cause, negotiation entry")
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
