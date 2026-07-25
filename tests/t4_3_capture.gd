extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const OUTPUT_PATH := "res://docs/evidence/T4.3/audio-controls-1366x768.png"


func _init() -> void:
	var capture_viewport := SubViewport.new()
	capture_viewport.size = Vector2i(1366, 768)
	capture_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(capture_viewport)

	var main: Control = MAIN_SCENE.instantiate()
	capture_viewport.add_child(main)
	await process_frame
	await process_frame

	DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path("res://docs/evidence/T4.3")
	)
	var image: Image = capture_viewport.get_texture().get_image()
	assert(image.get_size() == Vector2i(1366, 768))
	var error: Error = image.save_png(OUTPUT_PATH)
	assert(error == OK, "Failed to save T4.3 audio controls evidence")

	main.get_node("%AudioController").call(&"stop_all")
	await process_frame
	main.free()
	capture_viewport.free()
	print("T4.3 capture: audio-controls-1366x768.png")
	quit()
