extends Node

signal progress_changed(value: float)
signal stage_changed(stage: Stage)
signal overwrite_completed

enum Stage {
	IDLE,
	READING,
	PAUSED_AT_99,
	REVERSING,
	CORE_CRACKED,
	GHOST_SAVE_CREATED,
	COMPLETE,
}

const GHOST_SAVE_NAME: String = "她曾经来过"
const FORWARD_DURATION: float = 1.4
const PAUSE_DURATION: float = 1.0
const REVERSE_DURATION: float = 0.9

var timing_scale: float = 1.0
var active: bool = false
var stage: Stage = Stage.IDLE
var progress: float = 0.0


func _ready() -> void:
	var timing_override: String = OS.get_environment(
		"RESIDUAL_ANOMALY_TIMING_SCALE"
	)
	if not timing_override.is_empty():
		timing_scale = maxf(timing_override.to_float(), 0.01)


func request_force_overwrite() -> bool:
	if active or has_completed_overwrite():
		return false

	active = true
	var game_state: Node = get_node("/root/GameState")
	game_state.set("phase", _get_phase_value(game_state, &"SAVE_DECISION"))
	call_deferred("_run_overwrite_sequence")
	return true


func has_completed_overwrite() -> bool:
	var game_state: Node = get_node("/root/GameState")
	var residual_state: Dictionary = game_state.get("residual_state")
	return bool(residual_state.get(&"ghost_save", false))


func _run_overwrite_sequence() -> void:
	_set_stage(Stage.READING)
	await _animate_progress(0.0, 99.0, FORWARD_DURATION)
	_set_progress(99.0)

	_set_stage(Stage.PAUSED_AT_99)
	await get_tree().create_timer(PAUSE_DURATION * timing_scale).timeout

	_set_stage(Stage.REVERSING)
	await _animate_progress(99.0, 43.0, REVERSE_DURATION)
	_set_progress(43.0)

	_set_stage(Stage.CORE_CRACKED)
	_commit_force_overwrite()
	_set_stage(Stage.GHOST_SAVE_CREATED)
	_set_stage(Stage.COMPLETE)
	active = false
	overwrite_completed.emit()


func _animate_progress(
	from_value: float,
	to_value: float,
	duration: float
) -> void:
	var tween: Tween = create_tween()
	tween.tween_method(
		Callable(self, "_set_progress"),
		from_value,
		to_value,
		duration * timing_scale
	)
	await tween.finished


func _set_progress(value: float) -> void:
	progress = value
	progress_changed.emit(progress)


func _set_stage(next_stage: Stage) -> void:
	stage = next_stage
	stage_changed.emit(stage)


func _commit_force_overwrite() -> void:
	var game_state: Node = get_node("/root/GameState")
	var residual_state: Dictionary = game_state.get("residual_state")
	residual_state[&"ghost_save"] = true
	residual_state[&"ghost_save_name"] = GHOST_SAVE_NAME
	residual_state[&"ghost_save_deletable"] = false
	residual_state[&"force_overwrite_completed"] = true

	var persona_state: Dictionary = game_state.get("persona_state")
	persona_state[&"conflict"] = int(persona_state.get(&"conflict", 0)) + 2

	var history: Array = game_state.get("history")
	history.append({
		"event": "FORCE_OVERWRITE",
		"loop_index": int(game_state.get("loop_index")),
		"result": "GHOST_SAVE_CREATED",
	})

	game_state.set("phase", _get_phase_value(game_state, &"LOOP_PLAY"))
	get_node("/root/EventBus").emit_signal(
		&"residual_data_spawned",
		&"GHOST_SAVE"
	)


func _get_phase_value(game_state: Node, phase_name: StringName) -> int:
	var game_state_script: Script = game_state.get_script()
	var constants: Dictionary = game_state_script.get_script_constant_map()
	var phases: Dictionary = constants["Phase"]
	return int(phases[String(phase_name)])
