extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const EVIDENCE_DIRECTORY := "res://docs/evidence/T4.2"

var capture_viewport: SubViewport


func _init() -> void:
	capture_viewport = SubViewport.new()
	capture_viewport.size = Vector2i(1920, 1080)
	capture_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(capture_viewport)
	var main: Control = MAIN_SCENE.instantiate()
	capture_viewport.add_child(main)
	await process_frame
	await process_frame
	_capture("formal-office-1920x1080.png", Vector2i(1920, 1080))

	main.call(&"_show_action_art", &"READ_LETTER")
	await process_frame
	await process_frame
	_capture("document-panel-1920x1080.png", Vector2i(1920, 1080))

	main.call(&"_on_document_close_pressed")
	capture_viewport.size = Vector2i(1366, 768)
	await process_frame
	await process_frame
	_capture("formal-office-1366x768.png", Vector2i(1366, 768))

	main.call(&"_show_action_art", &"READ_LETTER")
	await process_frame
	await process_frame
	_capture("document-panel-1366x768.png", Vector2i(1366, 768))

	main.get_node("%AudioController").call(&"stop_all")
	await process_frame
	main.free()
	capture_viewport.free()
	quit()


func _capture(file_name: String, expected_size: Vector2i) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(
		EVIDENCE_DIRECTORY
	))
	var image: Image = capture_viewport.get_texture().get_image()
	assert(image.get_size() == expected_size)
	var error: Error = image.save_png("%s/%s" % [EVIDENCE_DIRECTORY, file_name])
	assert(error == OK, "Failed to save T4.2 evidence: %s" % file_name)
	print("T4.2 capture: %s" % file_name)
