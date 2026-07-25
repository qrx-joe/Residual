extends Node

signal decision_ready(decision: Dictionary)

const RESPONSE_VALIDATOR_SCRIPT: Script = preload(
	"res://scripts/ai/ai_response_validator.gd"
)

@onready var http_request: HTTPRequest = $HTTPRequest

var _request_in_flight: bool = false
var _active_context: Dictionary = {}
var _validator: RefCounted = RESPONSE_VALIDATOR_SCRIPT.new()


func _ready() -> void:
	http_request.request_completed.connect(_on_request_completed)


func request_save_decision(
	allowed_decisions: Array[String],
	allowed_targets: Array[String],
	allowed_mutations: Array[String]
) -> bool:
	if _request_in_flight:
		return false
	_active_context = _build_request_context(
		allowed_decisions,
		allowed_targets,
		allowed_mutations
	)
	_request_in_flight = true

	var config: Node = get_node("/root/Config")
	if not bool(config.get("ai_enabled")):
		call_deferred("_complete_with_fallback")
		return true

	http_request.timeout = float(
		config.get("request_timeout_seconds")
	)
	var backend_url: String = String(config.get("backend_url"))
	var endpoint: String = (
		backend_url.trim_suffix("/") + "/v1/save-decision"
	)
	var request_error: Error = http_request.request(
		endpoint,
		PackedStringArray(["Content-Type: application/json"]),
		HTTPClient.METHOD_POST,
		JSON.stringify(_active_context)
	)
	if request_error != OK:
		call_deferred("_complete_with_fallback")
	return true


func is_request_in_flight() -> bool:
	return _request_in_flight


func _build_request_context(
	allowed_decisions: Array[String],
	allowed_targets: Array[String],
	allowed_mutations: Array[String]
) -> Dictionary:
	var game_state: Node = get_node("/root/GameState")
	var persona_state: Dictionary = game_state.get("persona_state")
	var history: Array = game_state.get("history")
	var recent_actions: Array[String] = []
	var start_index: int = maxi(history.size() - 10, 0)
	for index: int in range(start_index, history.size()):
		var history_value: Variant = history[index]
		if not history_value is Dictionary:
			continue
		var history_item: Dictionary = history_value
		var action_name: String = String(
			history_item.get(
				"decision",
				history_item.get("event", "")
			)
		)
		if not action_name.is_empty():
			recent_actions.append(action_name.left(64))

	var protected_target: Variant = persona_state.get(
		"protected_target",
		null
	)
	if (
		protected_target != null
		and String(protected_target) not in allowed_targets
	):
		protected_target = null
	return {
		"session_id": "loop-%d-history-%d" % [
			int(game_state.get("loop_index")),
			history.size(),
		],
		"loop_index": maxi(int(game_state.get("loop_index")), 1),
		"persona": {
			"trust": int(persona_state.get("trust", 0)),
			"obsession": int(persona_state.get("obsession", 0)),
			"conflict": int(persona_state.get("conflict", 0)),
			"protected_target": protected_target,
			"broken_promises": int(
				persona_state.get("broken_promises", 0)
			),
		},
		"recent_actions": recent_actions,
		"allowed_decisions": allowed_decisions.duplicate(),
		"allowed_targets": allowed_targets.duplicate(),
		"allowed_mutations": allowed_mutations.duplicate(),
		"max_dialogue_lines": 2,
		"max_chars_per_line": 20,
	}


func _on_request_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	if not _request_in_flight:
		return
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		_complete_with_fallback()
		return
	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	var validated: Dictionary = _validator.call(
		"validate_response",
		parsed,
		_active_context
	)
	if validated.is_empty():
		_complete_with_fallback()
		return
	_complete(validated, "backend")


func _complete_with_fallback() -> void:
	if not _request_in_flight:
		return
	var fallback: Dictionary = _validator.call(
		"create_fallback",
		_active_context
	)
	_complete(fallback, "fallback")


func _complete(decision: Dictionary, source: String) -> void:
	var completed_decision: Dictionary = decision.duplicate(true)
	completed_decision["source"] = source
	_request_in_flight = false
	_active_context.clear()
	decision_ready.emit(completed_decision)
	get_node("/root/EventBus").emit_signal(
		"save_decision_ready",
		completed_decision
	)
