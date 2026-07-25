extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")


func _init() -> void:
	var main: Control = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame

	var game_state: Node = root.get_node("GameState")
	game_state.set("loop_index", 1)
	game_state.set(
		"world_state",
		{
			&"evidence_found": true,
			&"audio_exists": true,
			&"first_loop_choice": "",
		}
	)

	var loop_manager: Node = main.get_node("%LoopManager")
	loop_manager.call(&"start_loop", 1)
	for action_index: int in range(4):
		if not bool(loop_manager.call(&"request_action", &"TEST_ACTION")):
			await _finish(main, "Could not reach the timeout state", 1)
			return
		loop_manager.call(&"complete_action", &"TEST_ACTION")
	if not bool(loop_manager.get("timed_out")):
		await _finish(main, "Fourth action did not reach timeout", 1)
		return

	var decision_overlay: Control = main.get_node("%FirstLoopDecisionOverlay")
	var delete_button: Button = main.get_node("%DeleteAudioChoiceButton")
	var keep_button: Button = main.get_node("%KeepAudioChoiceButton")
	decision_overlay.visible = true
	delete_button.disabled = false
	keep_button.disabled = false

	main.call(&"_on_first_loop_choice", &"DELETE_AUDIO")
	if (
		not decision_overlay.visible
		or delete_button.disabled
		or keep_button.disabled
	):
		await _finish(
			main,
			"Rejected timeout delete locked the remaining choice path",
			1
		)
		return

	main.call(&"_on_first_loop_choice", &"KEEP_AUDIO")
	if decision_overlay.visible or (
		String(
			(game_state.get("world_state") as Dictionary).get(
				&"first_loop_choice",
				""
			)
		) == "KEEP"
	) == false:
		await _finish(main, "Offline keep path did not complete", 1)
		return

	await _finish(
		main,
		"T5.2 smoke: timeout delete rejection preserves the offline keep path",
		0
	)


func _finish(main: Control, message: String, exit_code: int) -> void:
	main.get_node("%AudioController").call(&"stop_all")
	await create_timer(0.2).timeout
	main.free()
	await create_timer(0.2).timeout
	if exit_code == 0:
		print(message)
	else:
		push_error(message)
	quit(exit_code)
