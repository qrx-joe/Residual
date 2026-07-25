extends Node


func prepare_loop_two() -> void:
	var game_state: Node = get_node("/root/GameState")
	game_state.set("loop_index", 2)
	game_state.set("world_state", {})
	game_state.set(
		"player_knowledge",
		{
			&"deleted_recording_once": true,
		}
	)
	game_state.set(
		"persona_state",
		{
			&"trust": 0,
			&"obsession": 2,
			&"conflict": 0,
			&"promises": {},
			&"broken_promises": 0,
		}
	)
	game_state.set(
		"residual_state",
		{
			&"recording_deleted": true,
			&"recording_deletion_count": 1,
		}
	)
	game_state.set(
		"history",
		[
			{
				"event": "DEMO_PRESET",
				"target": "LOOP_2",
			},
		]
	)


func prepare_force_negotiation() -> void:
	var game_state: Node = get_node("/root/GameState")
	var world_state: Dictionary = game_state.get("world_state")
	world_state[&"audio_played"] = true
	world_state[&"evidence_found"] = true
	world_state[&"first_loop_choice"] = "DELETE"
	world_state[&"negotiation_available"] = true
	world_state[&"negotiation_entered"] = true

	var residual_state: Dictionary = game_state.get("residual_state")
	residual_state[&"recording_deleted"] = true
	residual_state[&"recording_deletion_count"] = 2
	residual_state[&"ghost_recording"] = true
	residual_state[&"complete_ghost_recording"] = true

	var persona_state: Dictionary = game_state.get("persona_state")
	persona_state[&"obsession"] = 4
	var player_knowledge: Dictionary = game_state.get("player_knowledge")
	player_knowledge.erase(&"negotiation_choice")
	game_state.set(
		"phase",
		_get_phase_value(game_state, &"SAVE_NEGOTIATION")
	)
	var history: Array = game_state.get("history")
	history.append({
		"event": "DEMO_PRESET",
		"target": "FORCE_NEGOTIATION",
	})


func _get_phase_value(game_state: Node, phase_name: StringName) -> int:
	var game_state_script: Script = game_state.get_script()
	var constants: Dictionary = game_state_script.get_script_constant_map()
	var phases: Dictionary = constants["Phase"]
	return int(phases[String(phase_name)])
