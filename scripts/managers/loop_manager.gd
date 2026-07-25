extends Node

signal state_changed(
	actions_remaining: int,
	display_time: String,
	action_resolving: bool
)
signal loop_timed_out

const MAX_ACTIONS: int = 4
const LOOP_TIMES: PackedStringArray = [
	"02:47",
	"02:50",
	"02:53",
	"02:56",
	"03:00",
]

var actions_remaining: int = MAX_ACTIONS
var action_index: int = 0
var action_resolving: bool = false
var timed_out: bool = false


func start_loop(loop_index: int) -> void:
	actions_remaining = MAX_ACTIONS
	action_index = 0
	action_resolving = false
	timed_out = false
	var game_state: Node = _get_game_state()
	game_state.set("loop_index", loop_index)
	game_state.set("phase", _get_phase_value(game_state, &"LOOP_PLAY"))
	_sync_game_state()
	_get_event_bus().emit_signal(&"loop_started", loop_index)
	state_changed.emit(actions_remaining, get_display_time(), action_resolving)


func request_action(action_id: StringName) -> bool:
	if action_resolving or timed_out or actions_remaining <= 0:
		return false

	action_resolving = true
	_get_event_bus().emit_signal(&"action_requested", action_id)
	state_changed.emit(actions_remaining, get_display_time(), action_resolving)
	return true


func complete_action(action_id: StringName) -> void:
	if not action_resolving or timed_out:
		return

	action_index = mini(action_index + 1, MAX_ACTIONS)
	actions_remaining = maxi(MAX_ACTIONS - action_index, 0)
	action_resolving = false

	if actions_remaining == 0:
		timed_out = true
		var game_state: Node = _get_game_state()
		game_state.set("phase", _get_phase_value(game_state, &"LOOP_TIMEOUT"))

	_sync_game_state()
	var result: Dictionary = {
		"actions_remaining": actions_remaining,
		"display_time": get_display_time(),
	}
	_get_event_bus().emit_signal(&"action_resolved", action_id, result)
	state_changed.emit(actions_remaining, get_display_time(), action_resolving)

	if timed_out:
		var game_state: Node = _get_game_state()
		_get_event_bus().emit_signal(
			&"loop_ended",
			int(game_state.get("loop_index"))
		)
		loop_timed_out.emit()


func get_display_time() -> String:
	return LOOP_TIMES[action_index]


func _sync_game_state() -> void:
	var game_state: Node = _get_game_state()
	var world_state: Dictionary = game_state.get("world_state")
	world_state[&"actions_remaining"] = actions_remaining
	world_state[&"display_time"] = get_display_time()


func _get_game_state() -> Node:
	return get_node("/root/GameState")


func _get_event_bus() -> Node:
	return get_node("/root/EventBus")


func _get_phase_value(game_state: Node, phase_name: StringName) -> int:
	var game_state_script: Script = game_state.get_script()
	var constants: Dictionary = game_state_script.get_script_constant_map()
	var phases: Dictionary = constants["Phase"]
	return int(phases[String(phase_name)])
