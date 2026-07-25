extends Node3D

const STATE_NAMES: Array[String] = [
	"CALM",
	"OBSERVING",
	"PROTECTING",
	"HOSTILE",
	"GHOST",
]

@onready var core: Save03CoreVisual = $Save03Core
@onready var state_label: Label = %StateLabel
@onready var state_buttons: Array[Button] = [
	%CalmButton,
	%ObservingButton,
	%ProtectingButton,
	%HostileButton,
	%GhostButton,
]


func _ready() -> void:
	for index: int in state_buttons.size():
		state_buttons[index].pressed.connect(_set_state.bind(index))
	_set_state(Save03CoreVisual.VisualState.CALM)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.pressed or event.echo:
		return
	var state_index: int = int(event.keycode) - int(KEY_1)
	if state_index >= 0 and state_index < STATE_NAMES.size():
		_set_state(state_index)


func _set_state(state_index: int) -> void:
	core.set_visual_state(state_index as Save03CoreVisual.VisualState)
	state_label.text = "SAVE_03 / %s" % STATE_NAMES[state_index]
	for index: int in state_buttons.size():
		state_buttons[index].disabled = index == state_index

