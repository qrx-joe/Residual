extends SceneTree

const RESIDUAL_MANAGER_SCRIPT: Script = preload(
	"res://scripts/managers/residual_data_manager.gd"
)
const TEST_SAVE_PATH: String = "user://t1_4_persistence_test.json"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_state: Node = root.get_node("GameState")
	var save_data: Node = root.get_node("SaveData")
	var residual_manager: Node = RESIDUAL_MANAGER_SCRIPT.new()
	root.add_child(residual_manager)

	game_state.set("loop_index", 1)
	game_state.set("player_knowledge", {})
	game_state.set("persona_state", {"trust": 1})
	game_state.set("residual_state", {})
	game_state.set("history", [])

	var ghost_without_deletion: bool = bool(
		residual_manager.call(&"prepare_loop", 2)
	)
	if ghost_without_deletion:
		_fail("Ghost recording appeared without a deletion cause")
		return

	residual_manager.call(&"record_recording_deletion")
	if not bool(residual_manager.call(&"has_recording_been_deleted")):
		_fail("Recording deletion was not recorded")
		return

	var ghost_after_deletion: bool = bool(
		residual_manager.call(&"prepare_loop", 2)
	)
	if not ghost_after_deletion:
		_fail("Deletion did not produce the second-loop ghost recording")
		return

	game_state.set("loop_index", 2)
	var persona: Dictionary = game_state.get("persona_state")
	persona["trust"] = 3
	var saved: bool = bool(
		save_data.call(&"save_persistent_state", TEST_SAVE_PATH)
	)
	if not saved:
		_fail("Persistent save could not be written")
		return

	game_state.set("loop_index", 0)
	game_state.set("player_knowledge", {})
	game_state.set("persona_state", {})
	game_state.set("residual_state", {})
	game_state.set("history", [])
	var loaded: bool = bool(
		save_data.call(&"load_persistent_state", TEST_SAVE_PATH)
	)
	if not loaded:
		_fail("Persistent save could not be loaded")
		return

	var restored_residual: Dictionary = game_state.get("residual_state")
	var restored_knowledge: Dictionary = game_state.get("player_knowledge")
	var restored_history: Array = game_state.get("history")
	if int(game_state.get("loop_index")) != 2:
		_fail("Loop index did not survive restart persistence")
		return
	if not bool(restored_residual.get(&"ghost_recording", false)):
		_fail("Ghost recording did not survive restart persistence")
		return
	if not bool(restored_knowledge.get(&"deleted_recording_once", false)):
		_fail("Deletion knowledge did not survive restart persistence")
		return
	if restored_history.size() != 1:
		_fail("Deletion history did not survive restart persistence")
		return

	var absolute_test_path: String = ProjectSettings.globalize_path(
		TEST_SAVE_PATH
	)
	DirAccess.remove_absolute(absolute_test_path)
	print("T1.4 smoke: deletion cause, ghost recording, restart persistence")
	quit(0)


func _fail(message: String) -> void:
	var absolute_test_path: String = ProjectSettings.globalize_path(
		TEST_SAVE_PATH
	)
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(absolute_test_path)
	push_error(message)
	quit(1)
