extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")


func _init() -> void:
	root.size = Vector2i(1920, 1080)
	var main: Control = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame

	var background: TextureRect = main.get_node("%Background")
	assert(background.texture != null, "Formal office background must be assigned")
	assert(background.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_COVERED)
	assert(background.size.x >= 1919.0 and background.size.y >= 1079.0)

	var document_overlay: Control = main.get_node("%DocumentOverlay")
	var document_texture: TextureRect = main.get_node("%DocumentTexture")
	assert(not document_overlay.visible, "Document viewer starts closed")
	main.call(&"_show_action_art", &"READ_LETTER")
	assert(document_overlay.visible, "Letter action opens document viewer")
	assert(document_texture.texture != null, "Document viewer displays the letter")
	main.call(&"_on_document_close_pressed")
	assert(not document_overlay.visible, "Document viewer can be closed")

	var waveform: TextureRect = main.get_node("%GhostWaveformTexture")
	assert(waveform.texture != null, "Residual waveform artwork must be assigned")
	for path: String in [
		"res://assets/2d/backgrounds/office_main.png",
		"res://assets/2d/documents/azhi_letter.png",
		"res://assets/2d/documents/data_purge_notice.png",
		"res://assets/2d/effects/ghost_waveform.png",
		"res://assets/2d/icons/backup_chip.png",
		"res://assets/2d/icons/storage_device.png",
	]:
		assert(FileAccess.file_exists(path), "Missing T4.2 asset: %s" % path)

	main.get_node("%AudioController").call(&"stop_all")
	await create_timer(0.2).timeout
	main.free()
	await create_timer(0.2).timeout
	print("T4.2 smoke: formal office, document viewer, icons, and waveform ready")
	quit()
