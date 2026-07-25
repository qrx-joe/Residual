extends Node

signal ghost_recording_spawned
signal ghost_evidence_header_spawned


func record_recording_deletion() -> void:
	var game_state: Node = get_node("/root/GameState")
	var residual_state: Dictionary = game_state.get("residual_state")
	var deletion_count: int = int(
		residual_state.get(&"recording_deletion_count", 0)
	) + 1
	residual_state[&"recording_deleted"] = true
	residual_state[&"recording_deletion_count"] = deletion_count

	var player_knowledge: Dictionary = game_state.get("player_knowledge")
	player_knowledge[&"deleted_recording_once"] = true

	var history: Array = game_state.get("history")
	history.append({
		"event": "DELETE_RECORDING",
		"loop_index": int(game_state.get("loop_index")),
		"deletion_count": deletion_count,
	})


func record_recording_preservation() -> void:
	var game_state: Node = get_node("/root/GameState")
	var residual_state: Dictionary = game_state.get("residual_state")
	residual_state[&"recording_preserved"] = true
	var player_knowledge: Dictionary = game_state.get("player_knowledge")
	player_knowledge[&"preserved_recording_once"] = true
	var history: Array = game_state.get("history")
	history.append({
		"event": "KEEP_RECORDING",
		"loop_index": int(game_state.get("loop_index")),
	})


func prepare_loop(loop_index: int) -> bool:
	if loop_index < 2:
		return false

	var game_state: Node = get_node("/root/GameState")
	var residual_state: Dictionary = game_state.get("residual_state")
	if has_recording_been_deleted():
		if not bool(residual_state.get(&"ghost_recording", false)):
			residual_state[&"ghost_recording"] = true
			get_node("/root/EventBus").emit_signal(
				&"residual_data_spawned",
				&"GHOST_RECORDING"
			)
			ghost_recording_spawned.emit()
		return true
	if has_recording_been_preserved():
		if not bool(residual_state.get(&"ghost_evidence_header", false)):
			residual_state[&"ghost_evidence_header"] = true
			get_node("/root/EventBus").emit_signal(
				&"residual_data_spawned",
				&"GHOST_EVIDENCE_HEADER"
			)
			ghost_evidence_header_spawned.emit()
		return true
	return false


func has_recording_been_deleted() -> bool:
	var game_state: Node = get_node("/root/GameState")
	var residual_state: Dictionary = game_state.get("residual_state")
	return bool(residual_state.get(&"recording_deleted", false))


func has_ghost_recording() -> bool:
	var game_state: Node = get_node("/root/GameState")
	var residual_state: Dictionary = game_state.get("residual_state")
	return bool(residual_state.get(&"ghost_recording", false))


func has_recording_been_preserved() -> bool:
	var game_state: Node = get_node("/root/GameState")
	var residual_state: Dictionary = game_state.get("residual_state")
	return bool(residual_state.get(&"recording_preserved", false))


func has_ghost_evidence_header() -> bool:
	var game_state: Node = get_node("/root/GameState")
	var residual_state: Dictionary = game_state.get("residual_state")
	return bool(residual_state.get(&"ghost_evidence_header", false))
