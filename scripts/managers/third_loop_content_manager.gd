extends Node


func initialize_loop(loop_index: int) -> void:
	if loop_index < 3:
		return
	var world_state: Dictionary = _get_world_state()
	world_state[&"audio_exists"] = true
	world_state[&"evidence_extracted"] = false
	world_state[&"physical_chip_acquired"] = false
	world_state[&"final_soundprint_available"] = false
	world_state[&"final_evidence_decrypted"] = false
	world_state[&"completed_actions"] = {}


func is_final_evidence_decrypted() -> bool:
	return bool(
		_get_world_state().get(&"final_evidence_decrypted", false)
	)


func _get_world_state() -> Dictionary:
	return get_node("/root/GameState").get("world_state")
