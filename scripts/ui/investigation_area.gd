extends Button

signal area_selected(region_id: StringName, display_name: String, description: String)

@export var region_id: StringName
@export var display_name: String
@export_multiline var description: String
@export_range(0.1, 1.0, 0.05) var click_lock_seconds: float = 0.25

var _click_locked: bool = false


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	if _click_locked:
		return

	_click_locked = true
	area_selected.emit(region_id, display_name, description)
	await get_tree().create_timer(click_lock_seconds).timeout
	_click_locked = false
