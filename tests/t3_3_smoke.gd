extends SceneTree

const VALIDATOR_SCRIPT: Script = preload(
	"res://scripts/ai/ai_response_validator.gd"
)
const AI_CLIENT_SCRIPT: Script = preload(
	"res://scripts/ai/ai_client.gd"
)

var received_decisions: Array[Dictionary] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_state: Node = root.get_node("GameState")
	var config: Node = root.get_node("Config")
	_reset_state(game_state)

	var validator: RefCounted = VALIDATOR_SCRIPT.new()
	var context: Dictionary = _make_context()
	var valid_response: Dictionary = _make_valid_response()
	if (
		validator.call(
			"validate_response",
			valid_response,
			context
		) as Dictionary
	).is_empty():
		_fail("Valid backend decision was rejected")
		return

	var unknown_mutation: Dictionary = valid_response.duplicate(true)
	unknown_mutation["mutations"] = ["delete_main_evidence"]
	if not (
		validator.call(
			"validate_response",
			unknown_mutation,
			context
		) as Dictionary
	).is_empty():
		_fail("Unknown mutation was partially accepted")
		return

	var disallowed_decision: Dictionary = valid_response.duplicate(true)
	disallowed_decision["decision"] = "ALLOW"
	if not (
		validator.call(
			"validate_response",
			disallowed_decision,
			context
		) as Dictionary
	).is_empty():
		_fail("Decision outside the current allowlist was accepted")
		return

	var client: Node = AI_CLIENT_SCRIPT.new()
	var request_node: HTTPRequest = HTTPRequest.new()
	request_node.name = "HTTPRequest"
	client.add_child(request_node)
	root.add_child(client)
	await process_frame
	client.connect(&"decision_ready", _on_decision_ready)

	config.set("ai_enabled", false)
	var started_at: int = Time.get_ticks_msec()
	var accepted: bool = bool(client.call(
		&"request_save_decision",
		_array_of_strings(["PRESERVE", "DISTORT"]),
		_array_of_strings(["azhi_audio", "operation_log"]),
		_array_of_strings([
			"spawn_ghost_audio",
			"distort_noncritical_log",
		])
	))
	var returned_after_ms: int = Time.get_ticks_msec() - started_at
	if not accepted or returned_after_ms > 50:
		_fail("Offline request blocked the main thread")
		return
	if not received_decisions.is_empty():
		_fail("Offline fallback emitted synchronously in the caller stack")
		return
	await process_frame
	if received_decisions.size() != 1:
		_fail("Offline fallback did not arrive on the next frame")
		return
	if String(received_decisions[0].get("source", "")) != "fallback":
		_fail("Offline result was not marked as fallback")
		return

	var built_context: Dictionary = client.call(
		"_build_request_context",
		_array_of_strings(["PRESERVE"]),
		_array_of_strings(["azhi_audio"]),
		_array_of_strings(["spawn_ghost_audio"])
	)
	var serialized_context: String = JSON.stringify(built_context)
	if (
		"ROUTERBASE" in serialized_context
		or "API_KEY" in serialized_context
		or "Authorization" in serialized_context
	):
		_fail("Client request context included credential material")
		return

	config.set("ai_enabled", true)
	config.set("backend_url", "http://127.0.0.1:1")
	config.set("request_timeout_seconds", 0.15)
	if not bool(client.call(
		&"request_save_decision",
		_array_of_strings(["REFUSE", "PRESERVE"]),
		_array_of_strings(["ghost_save_slot"]),
		_array_of_strings(["show_ghost_save_slot"])
	)):
		_fail("Network failure test request was not accepted")
		return
	var responsive_frames: int = 0
	var deadline: int = Time.get_ticks_msec() + 1500
	while received_decisions.size() < 2 and Time.get_ticks_msec() < deadline:
		await process_frame
		responsive_frames += 1
	if received_decisions.size() != 2:
		_fail("Unreachable backend did not produce fallback")
		return
	if responsive_frames < 1:
		_fail("Network request did not yield control to the scene tree")
		return
	if String(received_decisions[1].get("source", "")) != "fallback":
		_fail("Network failure did not use fallback")
		return

	config.set("ai_enabled", false)
	config.set("backend_url", "http://127.0.0.1:8787")
	config.set("request_timeout_seconds", 5.0)
	print(
		"T3.3 smoke: request assembly, double validation, async offline fallback"
	)
	quit(0)


func _on_decision_ready(decision: Dictionary) -> void:
	received_decisions.append(decision)


func _make_context() -> Dictionary:
	return {
		"allowed_decisions": ["PRESERVE", "DISTORT"],
		"allowed_targets": ["azhi_audio", "operation_log"],
		"allowed_mutations": [
			"spawn_ghost_audio",
			"distort_noncritical_log",
		],
		"max_dialogue_lines": 2,
		"max_chars_per_line": 20,
	}


func _make_valid_response() -> Dictionary:
	return {
		"decision": "PRESERVE",
		"reason_code": "BROKEN_PROMISE",
		"target": "azhi_audio",
		"mutations": ["spawn_ghost_audio"],
		"dialogue": ["你答应过我。", "这次，录音留下。"],
		"persona_delta": {
			"trust": -1,
			"obsession": 1,
			"conflict": 0,
		},
	}


func _array_of_strings(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value: Variant in values:
		result.append(String(value))
	return result


func _reset_state(game_state: Node) -> void:
	game_state.set("loop_index", 3)
	game_state.set("world_state", {})
	game_state.set("player_knowledge", {})
	game_state.set("persona_state", {
		&"trust": 1,
		&"obsession": 5,
		&"conflict": 2,
		&"protected_target": "azhi_audio",
		&"broken_promises": 1,
	})
	game_state.set("residual_state", {})
	game_state.set("history", [
		{"event": "DELETE_RECORDING"},
		{"event": "NEGOTIATION_DECISION", "decision": "CONFESS"},
	])


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
