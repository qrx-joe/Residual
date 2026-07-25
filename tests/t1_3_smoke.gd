extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_state: Node = root.get_node("GameState")
	var save_data: Node = root.get_node("SaveData")

	var initial_world: Dictionary = {
		"actions_remaining": 4,
		"display_time": "02:47",
		"drawer": {
			"locked": true,
		},
	}
	game_state.set("world_state", initial_world.duplicate(true))
	game_state.set("player_knowledge", {"photo_code": "03/17"})
	game_state.set("persona_state", {"trust": 2})
	game_state.set("residual_state", {"ghost_audio": false})
	save_data.call(&"create_world_snapshot")

	var changed_world: Dictionary = game_state.get("world_state")
	changed_world["actions_remaining"] = 0
	changed_world["display_time"] = "03:00"
	changed_world["drawer"]["locked"] = false
	changed_world["transient_evidence"] = true

	var knowledge: Dictionary = game_state.get("player_knowledge")
	knowledge["heard_recording"] = true
	var persona: Dictionary = game_state.get("persona_state")
	persona["trust"] = 3
	var residual: Dictionary = game_state.get("residual_state")
	residual["ghost_audio"] = true

	var restored: bool = bool(save_data.call(&"restore_world_snapshot"))
	if not restored:
		_fail("World snapshot could not be restored")
		return

	var restored_world: Dictionary = game_state.get("world_state")
	if restored_world != initial_world:
		_fail("World state did not restore to the 02:47 snapshot")
		return
	if not bool(knowledge.get("heard_recording", false)):
		_fail("Player knowledge was incorrectly rolled back")
		return
	if int(persona.get("trust", 0)) != 3:
		_fail("Persona state was incorrectly rolled back")
		return
	if not bool(residual.get("ghost_audio", false)):
		_fail("Residual state was incorrectly rolled back")
		return

	print("T1.3 smoke: world restored; knowledge, persona, residual preserved")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
