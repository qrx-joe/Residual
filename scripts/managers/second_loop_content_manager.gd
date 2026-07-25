extends Node


func initialize_loop(loop_index: int) -> void:
	if loop_index != 2:
		return
	var world_state: Dictionary = _get_world_state()
	world_state[&"audio_exists"] = true
	world_state[&"soundprint_available"] = true
	world_state[&"evidence_extracted"] = false
	world_state[&"first_loop_choice"] = ""
	world_state[&"completed_actions"] = {}
	world_state[&"negotiation_available"] = false
	world_state[&"negotiation_entered"] = false


func should_offer_choice(loop_index: int) -> bool:
	if loop_index != 2:
		return false
	var world_state: Dictionary = _get_world_state()
	return (
		bool(world_state.get(&"audio_played", false))
		and bool(world_state.get(&"evidence_found", false))
		and String(world_state.get(&"first_loop_choice", "")).is_empty()
	)


func complete_choice(
	choice_id: StringName,
	residual_data_manager: Node
) -> Dictionary:
	var game_state: Node = get_node("/root/GameState")
	var world_state: Dictionary = game_state.get("world_state")
	if bool(world_state.get(&"negotiation_available", false)):
		return {"ok": false, "error": "SECOND_CHOICE_ALREADY_RESOLVED"}

	var persona_state: Dictionary = game_state.get("persona_state")
	if choice_id == &"DELETE_AUDIO":
		residual_data_manager.call(&"record_recording_deletion")
		persona_state[&"obsession"] = (
			int(persona_state.get(&"obsession", 0)) + 2
		)
		var residual_state: Dictionary = game_state.get("residual_state")
		residual_state[&"complete_ghost_recording"] = true
		world_state[&"negotiation_available"] = true
		return {
			"ok": true,
			"title": "SAVE_03 拒绝再次清除",
			"detail": "同一段声音。你已经删过两次。\n谈判通道已开启。",
		}
	if choice_id == &"KEEP_AUDIO":
		residual_data_manager.call(&"record_recording_preservation")
		persona_state[&"trust"] = int(persona_state.get(&"trust", 0)) + 1
		var residual_state: Dictionary = game_state.get("residual_state")
		residual_state[&"ghost_evidence_header"] = true
		world_state[&"negotiation_available"] = true
		return {
			"ok": true,
			"title": "SAVE_03 保留未完成状态",
			"detail": "你保留了它。未完成的部分也留下了。\n谈判通道已开启。",
		}
	return {"ok": false, "error": "UNKNOWN_SECOND_LOOP_CHOICE"}


func enter_negotiation() -> bool:
	var game_state: Node = get_node("/root/GameState")
	var world_state: Dictionary = game_state.get("world_state")
	if not bool(world_state.get(&"negotiation_available", false)):
		return false
	game_state.set(
		"phase",
		_get_phase_value(game_state, &"SAVE_NEGOTIATION")
	)
	world_state[&"negotiation_entered"] = true
	return true


func _get_world_state() -> Dictionary:
	return get_node("/root/GameState").get("world_state")


func _get_phase_value(game_state: Node, phase_name: StringName) -> int:
	var game_state_script: Script = game_state.get_script()
	var constants: Dictionary = game_state_script.get_script_constant_map()
	var phases: Dictionary = constants["Phase"]
	return int(phases[String(phase_name)])
