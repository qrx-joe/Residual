extends Node

const FINAL_REVEAL_TEXT: String = (
	"保留数据策略：DELETED_DATA_RETENTION\n"
	+ "用户删除状态：仅前端隐藏\n"
	+ "训练使用状态：持续\n\n"
	+ "授权人：当前用户\n"
	+ "保留对象：RELEASE_BUILD\n"
	+ "覆盖对象：AZHI_TEST_ARCHIVE\n\n"
	+ "02:31 · 阿栀使用维护通道离开 · 目的地未记录"
)


func get_relationship_variant() -> StringName:
	var persona_state: Dictionary = _get_game_state().get("persona_state")
	var trust: int = int(persona_state.get(&"trust", 0))
	var obsession: int = int(persona_state.get(&"obsession", 0))
	var conflict: int = int(persona_state.get(&"conflict", 0))
	var broken_promises: int = int(
		persona_state.get(&"broken_promises", 0)
	)
	if conflict >= 4 or broken_promises >= 1:
		return &"ADVERSARIAL"
	if trust >= 4 and broken_promises == 0:
		return &"COOPERATIVE"
	if trust >= 1 and obsession >= 3 and conflict < 4:
		return &"TRANSACTIONAL"
	return &"TRANSACTIONAL"


func prepare_final_reveal() -> Dictionary:
	var game_state: Node = _get_game_state()
	var world_state: Dictionary = game_state.get("world_state")
	if not bool(world_state.get(&"final_evidence_decrypted", false)):
		return {"ok": false, "error": "FINAL_EVIDENCE_NOT_DECRYPTED"}
	game_state.set("phase", _get_phase_value(game_state, &"FINAL_REVEAL"))
	var relationship: StringName = get_relationship_variant()
	var relationship_hint: String = ""
	match relationship:
		&"COOPERATIVE":
			relationship_hint = "SAVE_03：导出会清空我。你应该先知道。"
		&"ADVERSARIAL":
			relationship_hint = "SAVE_03：这次没有恢复按钮。"
		_:
			relationship_hint = "SAVE_03：如果我留下，证据只能留下摘要。"
	return {
		"ok": true,
		"relationship": String(relationship),
		"relationship_hint": relationship_hint,
		"reveal": FINAL_REVEAL_TEXT,
		"azhi_message": (
			"你总说，等知道得更多，就会做得更好。\n"
			+ "所以我把选择留给知道一切的你。"
		),
	}


func resolve_ending(ending_id: StringName) -> Dictionary:
	var game_state: Node = _get_game_state()
	var world_state: Dictionary = game_state.get("world_state")
	if not bool(world_state.get(&"final_evidence_decrypted", false)):
		return {"ok": false, "error": "ENDING_REQUIREMENT_NOT_MET"}
	if ending_id not in [&"PUBLIC_TRUTH", &"PRESERVE_MEMORY"]:
		return {"ok": false, "error": "UNKNOWN_ENDING"}

	var relationship: String = String(get_relationship_variant())
	var result: Dictionary = {
		"ok": true,
		"ending_id": String(ending_id),
		"relationship": relationship,
	}
	if ending_id == &"PUBLIC_TRUTH":
		world_state[&"evidence_exported"] = true
		world_state[&"save_slot_state"] = "EMPTY"
		game_state.set("persona_state", {})
		game_state.set("residual_state", {})
		result["title"] = "公开真相"
		result["detail"] = "可验证审计包已导出。隐藏记忆区已零化。"
		result["save_name"] = "SAVE_01"
		result["save_status"] = "空"
		result["dialogue"] = ["导出完成。", "记忆区已清空。"]
	else:
		world_state[&"full_export_cancelled"] = true
		world_state[&"evidence_summary_only"] = true
		world_state[&"save_slot_state"] = "PRESERVED"
		var residual_state: Dictionary = game_state.get("residual_state")
		residual_state[&"save_03_preserved"] = true
		result["title"] = "保留记忆"
		result["detail"] = "完整导出已终止。证据仅保留摘要。"
		result["save_name"] = "我们都记得"
		result["save_status"] = "继续"
		result["dialogue"] = ["这次不是恢复。", "是继续。"]

	game_state.set("phase", _get_phase_value(game_state, &"ENDING"))
	var player_knowledge: Dictionary = game_state.get("player_knowledge")
	player_knowledge[&"ending_reached"] = String(ending_id)
	var history: Array = game_state.get("history")
	history.append({
		"event": "ENDING",
		"ending_id": String(ending_id),
		"relationship": relationship,
	})
	return result


func _get_game_state() -> Node:
	return get_node("/root/GameState")


func _get_phase_value(game_state: Node, phase_name: StringName) -> int:
	var game_state_script: Script = game_state.get_script()
	var constants: Dictionary = game_state_script.get_script_constant_map()
	var phases: Dictionary = constants["Phase"]
	return int(phases[String(phase_name)])
