extends SceneTree

const ACTION_MANAGER_SCRIPT: Script = preload(
	"res://scripts/managers/action_manager.gd"
)
const THIRD_LOOP_MANAGER_SCRIPT: Script = preload(
	"res://scripts/managers/third_loop_content_manager.gd"
)
const ENDING_MANAGER_SCRIPT: Script = preload(
	"res://scripts/managers/ending_manager.gd"
)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_state: Node = root.get_node("GameState")
	var action_manager: Node = ACTION_MANAGER_SCRIPT.new()
	var third_loop_manager: Node = THIRD_LOOP_MANAGER_SCRIPT.new()
	var ending_manager: Node = ENDING_MANAGER_SCRIPT.new()
	root.add_child(action_manager)
	root.add_child(third_loop_manager)
	root.add_child(ending_manager)

	_reset_third_loop(game_state)
	third_loop_manager.call(&"initialize_loop", 3)
	if not bool(action_manager.call(&"load_actions")):
		_fail("T2.5 actions failed to load")
		return
	if not _expect_region_action(
		action_manager,
		&"DRAWER",
		&"QUICK_OPEN_DRAWER"
	):
		return
	if not _expect_region_action(
		action_manager,
		&"COMPUTER",
		&"QUICK_FIND_EVIDENCE"
	):
		return
	if not _expect_region_action(
		action_manager,
		&"PHONE",
		&"USE_GHOST_AUDIO"
	):
		return

	for action_id: StringName in [
		&"QUICK_OPEN_DRAWER",
		&"QUICK_FIND_EVIDENCE",
		&"USE_GHOST_AUDIO",
	]:
		if not bool(
			(action_manager.call(&"execute_action", action_id) as Dictionary)
			.get("ok", false)
		):
			_fail("%s could not execute" % action_id)
			return
	if not _expect_region_action(
		action_manager,
		&"COMPUTER",
		&"DECRYPT_EVIDENCE"
	):
		return
	if not bool(
		(
			action_manager.call(
				&"execute_action",
				&"DECRYPT_EVIDENCE"
			) as Dictionary
		).get("ok", false)
	):
		_fail("DECRYPT_EVIDENCE could not execute")
		return
	if not bool(
		third_loop_manager.call(&"is_final_evidence_decrypted")
	):
		_fail("Final evidence state was not set")
		return

	var reveal: Dictionary = ending_manager.call(&"prepare_final_reveal")
	if not bool(reveal.get("ok", false)):
		_fail("Final reveal could not open")
		return
	var reveal_text: String = String(reveal.get("reveal", ""))
	for required_text: String in [
		"DELETED_DATA_RETENTION",
		"仅前端隐藏",
		"RELEASE_BUILD",
		"AZHI_TEST_ARCHIVE",
		"02:31",
		"目的地未记录",
	]:
		if required_text not in reveal_text:
			_fail("Final reveal omitted: %s" % required_text)
			return
	if (
		String(reveal.get("azhi_message", "")).split("\n").size()
		!= 2
	):
		_fail("Azhi final message exceeded the two-line budget")
		return
	if not _verify_preserved_soundprint_path(
		game_state,
		action_manager,
		third_loop_manager
	):
		return

	if not _verify_relationship_variants(game_state, ending_manager):
		return
	if not _verify_public_truth(game_state, ending_manager):
		return
	if not _verify_preserve_memory(game_state, ending_manager):
		return

	print(
		"T2.5 smoke: evidence chain, reveal, 3 relationships, 2 local endings"
	)
	quit(0)


func _verify_preserved_soundprint_path(
	game_state: Node,
	action_manager: Node,
	third_loop_manager: Node
) -> bool:
	game_state.set("loop_index", 3)
	game_state.set("world_state", {})
	game_state.set("player_knowledge", {
		&"photo_code_hint": "03/17",
		&"evidence_path_known": true,
		&"preserved_recording_once": true,
		&"negotiation_choice": "BARGAIN",
	})
	game_state.set("residual_state", {})
	third_loop_manager.call(&"initialize_loop", 3)
	if not _expect_region_action(
		action_manager,
		&"PHONE",
		&"USE_PRESERVED_AUDIO"
	):
		return false
	var action: Dictionary = action_manager.call(
		&"get_action",
		&"USE_PRESERVED_AUDIO"
	)
	if int(action.get("cost", -1)) != 0:
		_fail("Preserved soundprint was not a zero-cost action")
		return false
	if not bool(
		(
			action_manager.call(
				&"execute_action",
				&"USE_PRESERVED_AUDIO"
			) as Dictionary
		).get("ok", false)
	):
		_fail("Preserved recording path could not provide a soundprint")
		return false
	return true


func _verify_relationship_variants(
	game_state: Node,
	ending_manager: Node
) -> bool:
	game_state.set("persona_state", {
		&"trust": 4,
		&"obsession": 0,
		&"conflict": 0,
		&"broken_promises": 0,
	})
	if ending_manager.call(&"get_relationship_variant") != &"COOPERATIVE":
		_fail("Cooperative relationship was not classified")
		return false
	game_state.set("persona_state", {
		&"trust": 2,
		&"obsession": 3,
		&"conflict": 1,
		&"broken_promises": 0,
	})
	if ending_manager.call(&"get_relationship_variant") != &"TRANSACTIONAL":
		_fail("Transactional relationship was not classified")
		return false
	game_state.set("persona_state", {
		&"trust": 5,
		&"obsession": 0,
		&"conflict": 4,
		&"broken_promises": 0,
	})
	if ending_manager.call(&"get_relationship_variant") != &"ADVERSARIAL":
		_fail("Adversarial relationship was not classified")
		return false
	return true


func _verify_public_truth(
	game_state: Node,
	ending_manager: Node
) -> bool:
	_reset_ending_state(game_state)
	var result: Dictionary = ending_manager.call(
		&"resolve_ending",
		&"PUBLIC_TRUTH"
	)
	if not bool(result.get("ok", false)):
		_fail("PUBLIC_TRUTH was not reachable")
		return false
	var world_state: Dictionary = game_state.get("world_state")
	if (
		not bool(world_state.get(&"evidence_exported", false))
		or String(world_state.get(&"save_slot_state", "")) != "EMPTY"
		or not (game_state.get("persona_state") as Dictionary).is_empty()
		or not (game_state.get("residual_state") as Dictionary).is_empty()
	):
		_fail("PUBLIC_TRUTH did not apply its declared cost")
		return false
	return _verify_dialogue_budget(result)


func _verify_preserve_memory(
	game_state: Node,
	ending_manager: Node
) -> bool:
	_reset_ending_state(game_state)
	var result: Dictionary = ending_manager.call(
		&"resolve_ending",
		&"PRESERVE_MEMORY"
	)
	if not bool(result.get("ok", false)):
		_fail("PRESERVE_MEMORY was not reachable")
		return false
	var world_state: Dictionary = game_state.get("world_state")
	var residual_state: Dictionary = game_state.get("residual_state")
	if (
		not bool(world_state.get(&"full_export_cancelled", false))
		or not bool(world_state.get(&"evidence_summary_only", false))
		or not bool(residual_state.get(&"save_03_preserved", false))
		or String(result.get("save_name", "")) != "我们都记得"
	):
		_fail("PRESERVE_MEMORY did not apply its declared cost")
		return false
	var dialogue: Array = result.get("dialogue", [])
	if dialogue != ["这次不是恢复。", "是继续。"]:
		_fail("PRESERVE_MEMORY fixed dialogue changed")
		return false
	return _verify_dialogue_budget(result)


func _verify_dialogue_budget(result: Dictionary) -> bool:
	var dialogue: Array = result.get("dialogue", [])
	if dialogue.size() > 2:
		_fail("%s exceeded two ending lines" % result.get("ending_id", ""))
		return false
	for line: Variant in dialogue:
		if String(line).length() > 20:
			_fail("%s exceeded 20 characters" % result.get("ending_id", ""))
			return false
	return true


func _expect_region_action(
	action_manager: Node,
	region_id: StringName,
	expected_action_id: StringName
) -> bool:
	var action: Dictionary = action_manager.call(
		&"get_available_action_for_region",
		region_id
	)
	if StringName(String(action.get("id", ""))) != expected_action_id:
		_fail("%s did not offer %s" % [region_id, expected_action_id])
		return false
	return true


func _reset_third_loop(game_state: Node) -> void:
	game_state.set("loop_index", 3)
	game_state.set("world_state", {})
	game_state.set("player_knowledge", {
		&"photo_code_hint": "03/17",
		&"evidence_path_known": true,
		&"negotiation_choice": "CONFESS",
	})
	game_state.set("persona_state", {
		&"trust": 4,
		&"obsession": 0,
		&"conflict": 0,
		&"broken_promises": 0,
	})
	game_state.set("residual_state", {
		&"complete_ghost_recording": true,
	})
	game_state.set("history", [])


func _reset_ending_state(game_state: Node) -> void:
	game_state.set("world_state", {
		&"final_evidence_decrypted": true,
	})
	game_state.set("player_knowledge", {
		&"save_03_source_understood": true,
	})
	game_state.set("persona_state", {
		&"trust": 4,
		&"obsession": 0,
		&"conflict": 0,
		&"broken_promises": 0,
	})
	game_state.set("residual_state", {
		&"complete_ghost_recording": true,
	})
	game_state.set("history", [])


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
