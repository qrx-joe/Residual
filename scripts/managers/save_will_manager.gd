extends Node

const DECISIONS: Array[StringName] = [
	&"CONFESS",
	&"BARGAIN",
	&"CONCEAL",
	&"FORCE",
]


func resolve_decision(decision_id: StringName) -> Dictionary:
	if decision_id not in DECISIONS:
		return {"ok": false, "error": "UNKNOWN_NEGOTIATION_DECISION"}
	var game_state: Node = get_node("/root/GameState")
	if int(game_state.get("phase")) != _get_phase_value(
		game_state,
		&"SAVE_NEGOTIATION"
	):
		return {"ok": false, "error": "NEGOTIATION_NOT_ACTIVE"}
	var player_knowledge: Dictionary = game_state.get("player_knowledge")
	if player_knowledge.has(&"negotiation_choice"):
		return {"ok": false, "error": "NEGOTIATION_ALREADY_RESOLVED"}

	var persona_state: Dictionary = game_state.get("persona_state")
	var residual_state: Dictionary = game_state.get("residual_state")
	var result: Dictionary = {"ok": true, "decision": String(decision_id)}
	match decision_id:
		&"CONFESS":
			persona_state[&"trust"] = int(
				persona_state.get(&"trust", 0)
			) + 1
			var promises: Dictionary = persona_state.get(&"promises", {})
			promises[&"preserve_azhi_audio"] = true
			persona_state[&"promises"] = promises
			persona_state[&"protected_target"] = "azhi_audio"
			residual_state[&"ghost_soundprint_allowed"] = true
			result["title"] = "承诺已记录"
			result["detail"] = "那就记住你说过什么。\n下一轮，不要再删掉她。"
		&"BARGAIN":
			persona_state[&"obsession"] = int(
				persona_state.get(&"obsession", 0)
			) + 1
			residual_state[&"bargained_items"] = [
				"ghost_recording",
				"photo_fragment",
				"failed_timeline",
			]
			result["title"] = "交换成立"
			result["detail"] = "你可以回去。\n它留下。"
		&"CONCEAL":
			persona_state[&"trust"] = int(
				persona_state.get(&"trust", 0)
			) - 2
			persona_state[&"conflict"] = int(
				persona_state.get(&"conflict", 0)
			) + 1
			residual_state[&"non_core_log_variant"] = "未发生的操作"
			result["title"] = "操作记录已隐藏"
			result["detail"] = "SAVE_03 没有回应。"
		&"FORCE":
			result["title"] = "强制覆盖"
			result["detail"] = "覆盖请求已发送。"
			result["trigger_force_overwrite"] = true

	player_knowledge[&"negotiation_choice"] = String(decision_id)
	var history: Array = game_state.get("history")
	history.append({
		"event": "NEGOTIATION_DECISION",
		"decision": String(decision_id),
		"loop_index": int(game_state.get("loop_index")),
	})
	return result


func can_continue_after_negotiation() -> bool:
	var game_state: Node = get_node("/root/GameState")
	var player_knowledge: Dictionary = game_state.get("player_knowledge")
	var decision: String = String(
		player_knowledge.get(&"negotiation_choice", "")
	)
	if decision.is_empty():
		return false
	if decision == "FORCE":
		var residual_state: Dictionary = game_state.get("residual_state")
		return bool(residual_state.get(&"ghost_save", false))
	return true


func _get_phase_value(game_state: Node, phase_name: StringName) -> int:
	var game_state_script: Script = game_state.get_script()
	var constants: Dictionary = game_state_script.get_script_constant_map()
	var phases: Dictionary = constants["Phase"]
	return int(phases[String(phase_name)])
