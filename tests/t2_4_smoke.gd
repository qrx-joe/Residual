extends SceneTree

const SAVE_WILL_MANAGER_SCRIPT: Script = preload(
	"res://scripts/managers/save_will_manager.gd"
)
const GAME_STATE_SCRIPT: Script = preload(
	"res://scripts/autoload/game_state.gd"
)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_state: Node = root.get_node("GameState")
	var manager: Node = SAVE_WILL_MANAGER_SCRIPT.new()
	root.add_child(manager)

	_reset_for_negotiation(game_state)
	var confess: Dictionary = manager.call(&"resolve_decision", &"CONFESS")
	if not bool(confess.get("ok", false)):
		_fail("CONFESS could not execute")
		return
	var persona: Dictionary = game_state.get("persona_state")
	if (
		int(persona.get(&"trust", 0)) != 1
		or not bool(
			(persona.get(&"promises", {}) as Dictionary).get(
				&"preserve_azhi_audio",
				false
			)
		)
	):
		_fail("CONFESS did not create trust and the promise")
		return
	if not bool(manager.call(&"can_continue_after_negotiation")):
		_fail("CONFESS led to a dead end")
		return

	_reset_for_negotiation(game_state)
	var bargain: Dictionary = manager.call(&"resolve_decision", &"BARGAIN")
	if not bool(bargain.get("ok", false)):
		_fail("BARGAIN could not execute")
		return
	if int((game_state.get("persona_state") as Dictionary).get(&"obsession", 0)) != 1:
		_fail("BARGAIN did not apply obsession +1")
		return
	if (
		(game_state.get("residual_state") as Dictionary)
		.get(&"bargained_items", [])
		.size() != 3
	):
		_fail("BARGAIN did not retain the three agreed residuals")
		return
	if not bool(manager.call(&"can_continue_after_negotiation")):
		_fail("BARGAIN led to a dead end")
		return

	_reset_for_negotiation(game_state)
	var conceal: Dictionary = manager.call(&"resolve_decision", &"CONCEAL")
	if not bool(conceal.get("ok", false)):
		_fail("CONCEAL could not execute")
		return
	persona = game_state.get("persona_state")
	if (
		int(persona.get(&"trust", 0)) != -2
		or int(persona.get(&"conflict", 0)) != 1
	):
		_fail("CONCEAL did not apply trust -2 and conflict +1")
		return
	if (
		String(
			(game_state.get("residual_state") as Dictionary).get(
				&"non_core_log_variant",
				""
			)
		) != "未发生的操作"
	):
		_fail("CONCEAL did not create the non-core log variant")
		return
	if not bool(manager.call(&"can_continue_after_negotiation")):
		_fail("CONCEAL led to a dead end")
		return

	_reset_for_negotiation(game_state)
	var force: Dictionary = manager.call(&"resolve_decision", &"FORCE")
	if not bool(force.get("trigger_force_overwrite", false)):
		_fail("FORCE did not request the fixed overwrite highlight")
		return
	if bool(manager.call(&"can_continue_after_negotiation")):
		_fail("FORCE continued before the ghost save existed")
		return
	(game_state.get("residual_state") as Dictionary)[&"ghost_save"] = true
	if not bool(manager.call(&"can_continue_after_negotiation")):
		_fail("FORCE led to a dead end after the highlight")
		return
	if bool(manager.call(&"resolve_decision", &"CONFESS").get("ok", false)):
		_fail("A second negotiation decision was accepted")
		return

	print("T2.4 smoke: four decisions, explicit mutations, promises, no dead ends")
	quit(0)


func _reset_for_negotiation(game_state: Node) -> void:
	var constants: Dictionary = GAME_STATE_SCRIPT.get_script_constant_map()
	var phases: Dictionary = constants["Phase"]
	game_state.set("phase", int(phases["SAVE_NEGOTIATION"]))
	game_state.set("loop_index", 2)
	game_state.set("world_state", {})
	game_state.set("player_knowledge", {})
	game_state.set("persona_state", {})
	game_state.set("residual_state", {})
	game_state.set("history", [])


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
