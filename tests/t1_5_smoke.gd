extends SceneTree

const ANOMALY_CONTROLLER_SCRIPT: Script = preload(
	"res://scripts/managers/anomaly_controller.gd"
)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_state: Node = root.get_node("GameState")
	var anomaly_controller: Node = ANOMALY_CONTROLLER_SCRIPT.new()
	root.add_child(anomaly_controller)
	anomaly_controller.set("timing_scale", 0.01)

	game_state.set("loop_index", 2)
	game_state.set("persona_state", {"conflict": 0})
	game_state.set("residual_state", {"ghost_recording": true})
	game_state.set("history", [])

	var progress_values: Array[float] = []
	var stages: Array[int] = []
	anomaly_controller.connect(
		&"progress_changed",
		func(value: float) -> void: progress_values.append(value)
	)
	anomaly_controller.connect(
		&"stage_changed",
		func(stage: int) -> void: stages.append(stage)
	)

	var first_request: bool = bool(
		anomaly_controller.call(&"request_force_overwrite")
	)
	var rapid_second_request: bool = bool(
		anomaly_controller.call(&"request_force_overwrite")
	)
	if not first_request or rapid_second_request:
		_fail("Rapid input did not preserve the single overwrite sequence")
		return

	await anomaly_controller.overwrite_completed

	if not progress_values.has(99.0) or not progress_values.has(43.0):
		_fail("Progress did not deterministically reach 99 and reverse to 43")
		return
	if stages != [1, 2, 3, 4, 5, 6]:
		_fail("Overwrite stages were skipped or reordered: %s" % [stages])
		return
	if bool(anomaly_controller.get("active")):
		_fail("Overwrite lock remained active after completion")
		return

	var residual_state: Dictionary = game_state.get("residual_state")
	if String(residual_state.get(&"ghost_save_name", "")) != "她曾经来过":
		_fail("Ghost save name was not created")
		return
	if bool(residual_state.get(&"ghost_save_deletable", true)):
		_fail("Ghost save is incorrectly deletable")
		return

	var persona_state: Dictionary = game_state.get("persona_state")
	if int(persona_state.get(&"conflict", 0)) != 2:
		_fail("Force overwrite did not apply the fixed conflict mutation")
		return
	if (game_state.get("history") as Array).size() != 1:
		_fail("Force overwrite history was not recorded exactly once")
		return
	if bool(anomaly_controller.call(&"request_force_overwrite")):
		_fail("Completed overwrite could be triggered a second time")
		return

	print("T1.5 smoke: 99 pause, reverse to 43, ghost save, input lock")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
