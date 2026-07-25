extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var config: Node = root.get_node("Config")
	config.set("demo_mode", true)
	root.size = Vector2i(1366, 768)

	var main: Control = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame

	if not main.has_node("%DemoControls"):
		await _finish(main, "Demo controls are missing", 1)
		return

	var demo_controls: HBoxContainer = main.get_node("%DemoControls")
	if not demo_controls.visible:
		await _finish(main, "Demo controls are hidden in demo mode", 1)
		return
	if not root.get_visible_rect().encloses(
		demo_controls.get_global_rect()
	):
		await _finish(
			main,
			"Demo controls are outside the 1366x768 viewport",
			1
		)
		return

	var loop_two_button: Button = main.get_node("%DemoLoopTwoButton")
	loop_two_button.pressed.emit()
	await process_frame
	var game_state: Node = root.get_node("GameState")
	if (
		int(game_state.get("loop_index")) != 2
		or not bool(
			(game_state.get("residual_state") as Dictionary).get(
				&"ghost_recording",
				false
			)
		)
	):
		await _finish(main, "Loop 2 demo state was not prepared", 1)
		return

	var force_button: Button = main.get_node("%DemoForceButton")
	force_button.pressed.emit()
	await process_frame
	var negotiation_overlay: Control = main.get_node(
		"%NegotiationOptionsOverlay"
	)
	if not negotiation_overlay.visible:
		await _finish(main, "Force demo did not open negotiation", 1)
		return

	var anomaly_controller: Node = main.get_node("%AnomalyController")
	anomaly_controller.set("timing_scale", 0.01)
	main.get_node("%ForceButton").pressed.emit()
	await anomaly_controller.overwrite_completed
	if not bool(
		(game_state.get("residual_state") as Dictionary).get(
			&"ghost_save",
			false
		)
	):
		await _finish(main, "Force demo did not create the ghost save", 1)
		return

	await _finish(
		main,
		"T5.4 smoke: demo jumps and forced overwrite highlight passed",
		0
	)


func _finish(main: Control, message: String, exit_code: int) -> void:
	main.get_node("%AudioController").call(&"stop_all")
	await create_timer(0.2).timeout
	main.free()
	await create_timer(0.2).timeout
	root.get_node("Config").set("demo_mode", false)
	if exit_code == 0:
		print(message)
	else:
		push_error(message)
	quit(exit_code)
