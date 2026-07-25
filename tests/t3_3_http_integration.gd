extends SceneTree

const AI_CLIENT_SCRIPT: Script = preload(
	"res://scripts/ai/ai_client.gd"
)

var received_decision: Dictionary = {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var config: Node = root.get_node("Config")
	if not bool(config.get("ai_enabled")):
		_fail("RESIDUAL_AI_ENABLED did not enable the client")
		return

	var game_state: Node = root.get_node("GameState")
	game_state.set("loop_index", 3)
	game_state.set("persona_state", {
		&"trust": 1,
		&"obsession": 3,
		&"conflict": 1,
		&"broken_promises": 0,
	})
	game_state.set("history", [
		{"event": "NEGOTIATION_DECISION", "decision": "BARGAIN"},
	])

	var client: Node = AI_CLIENT_SCRIPT.new()
	var request_node: HTTPRequest = HTTPRequest.new()
	request_node.name = "HTTPRequest"
	client.add_child(request_node)
	root.add_child(client)
	await process_frame
	client.connect(&"decision_ready", _on_decision_ready)

	var allowed_decisions: Array[String] = ["PRESERVE", "ALLOW"]
	var allowed_targets: Array[String] = [
		"failed_timeline",
		"photo_fragment",
	]
	var allowed_mutations: Array[String] = ["spawn_photo_fragment"]
	if not bool(client.call(
		&"request_save_decision",
		allowed_decisions,
		allowed_targets,
		allowed_mutations
	)):
		_fail("HTTP integration request was rejected")
		return

	var deadline: int = Time.get_ticks_msec() + 2000
	while received_decision.is_empty() and Time.get_ticks_msec() < deadline:
		await process_frame
	if received_decision.is_empty():
		_fail("Godot client did not receive the backend response")
		return
	if String(received_decision.get("source", "")) != "backend":
		_fail("HTTP integration unexpectedly used client fallback")
		return
	if String(received_decision.get("decision", "")) not in allowed_decisions:
		_fail("Backend decision escaped the Godot allowlist")
		return

	print("T3.3 HTTP: Godot -> backend -> double-validated decision")
	quit(0)


func _on_decision_ready(decision: Dictionary) -> void:
	received_decision = decision


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
