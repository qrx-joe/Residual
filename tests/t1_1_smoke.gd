extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const NARROW_SIZE: Vector2i = Vector2i(1366, 768)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = NARROW_SIZE
	var main: Control = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame

	var areas: Array[Node] = get_nodes_in_group("investigation_area")
	if areas.size() != 3:
		_fail("Expected 3 investigation areas, found %d" % areas.size())
		return

	for area_node: Node in areas:
		var area: Button = area_node as Button
		if area == null:
			_fail("Investigation area has the wrong script type")
			return

		var area_rect: Rect2 = area.get_global_rect()
		var viewport_rect: Rect2 = root.get_visible_rect()
		if not viewport_rect.encloses(area_rect):
			_fail(
				"%s rect %s is outside visible rect %s at 1366x768"
				% [area.name, area_rect, viewport_rect]
			)
			return

		var count_before: int = main.selection_count
		area.pressed.emit()
		area.pressed.emit()
		if main.selection_count != count_before + 1:
			_fail("%s accepted a rapid duplicate click" % area.name)
			return
		await create_timer(0.35).timeout

	print("T1.1 smoke: 3 areas visible at 1366x768; rapid clicks locked")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
