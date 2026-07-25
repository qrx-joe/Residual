extends RefCounted

const DECISIONS: Array[String] = [
	"ALLOW",
	"PRESERVE",
	"DISTORT",
	"REFUSE",
]
const TARGETS: Array[String] = [
	"azhi_audio",
	"photo_fragment",
	"operation_log",
	"failed_timeline",
	"ghost_save_slot",
]
const MUTATIONS: Array[String] = [
	"spawn_ghost_audio",
	"spawn_photo_fragment",
	"rename_save_slot",
	"disable_delete_audio_button",
	"distort_noncritical_log",
	"show_ghost_save_slot",
	"delay_load_progress",
]
const REASON_CODES: Array[String] = [
	"FIRST_DELETE",
	"REPEATED_DELETE",
	"BROKEN_PROMISE",
	"KEPT_PROMISE",
	"CONFESSION_ACCEPTED",
	"BARGAIN_ACCEPTED",
	"CONCEALMENT_DETECTED",
	"FORCED_OVERWRITE",
	"PROTECTED_MEMORY",
	"DEFAULT_ALLOW",
]
const RESPONSE_KEYS: Array[String] = [
	"decision",
	"reason_code",
	"target",
	"mutations",
	"dialogue",
	"persona_delta",
]


func validate_response(
	value: Variant,
	request_context: Dictionary
) -> Dictionary:
	if not value is Dictionary:
		return {}
	var response: Dictionary = value
	if response.size() != RESPONSE_KEYS.size():
		return {}
	for key: String in RESPONSE_KEYS:
		if not response.has(key):
			return {}

	var decision: String = String(response.get("decision", ""))
	var reason_code: String = String(response.get("reason_code", ""))
	var target: String = String(response.get("target", ""))
	if decision not in DECISIONS or reason_code not in REASON_CODES:
		return {}
	if target not in TARGETS:
		return {}
	if decision not in request_context.get("allowed_decisions", []):
		return {}
	if target not in request_context.get("allowed_targets", []):
		return {}

	var mutations_value: Variant = response.get("mutations")
	if not mutations_value is Array:
		return {}
	var allowed_mutations: Array = request_context.get(
		"allowed_mutations",
		[]
	)
	for mutation_value: Variant in mutations_value:
		if not mutation_value is String:
			return {}
		var mutation: String = String(mutation_value)
		if (
			mutation not in MUTATIONS
			or mutation not in allowed_mutations
		):
			return {}

	var dialogue_value: Variant = response.get("dialogue")
	if not dialogue_value is Array:
		return {}
	var dialogue: Array = dialogue_value
	var max_lines: int = int(
		request_context.get("max_dialogue_lines", 2)
	)
	var max_chars: int = int(
		request_context.get("max_chars_per_line", 20)
	)
	if dialogue.is_empty() or dialogue.size() > max_lines:
		return {}
	for line_value: Variant in dialogue:
		if not line_value is String:
			return {}
		if String(line_value).length() > max_chars:
			return {}

	var persona_delta_value: Variant = response.get("persona_delta")
	if not persona_delta_value is Dictionary:
		return {}
	var persona_delta: Dictionary = persona_delta_value
	if persona_delta.size() != 3:
		return {}
	for key: String in ["trust", "obsession", "conflict"]:
		if not persona_delta.has(key):
			return {}
		var delta: Variant = persona_delta[key]
		if not _is_bounded_integer(delta, -2, 2):
			return {}

	return response.duplicate(true)


func create_fallback(request_context: Dictionary) -> Dictionary:
	var allowed_decisions: Array = request_context.get(
		"allowed_decisions",
		[]
	)
	var allowed_targets: Array = request_context.get(
		"allowed_targets",
		[]
	)
	var decision: String = (
		String(allowed_decisions[0])
		if not allowed_decisions.is_empty()
		else "ALLOW"
	)
	var target: String = (
		String(allowed_targets[0])
		if not allowed_targets.is_empty()
		else "failed_timeline"
	)
	var reason_code: String = "DEFAULT_ALLOW"
	var dialogue: Array[String] = ["可以。", "这次我会记住。"]
	match decision:
		"PRESERVE":
			reason_code = "PROTECTED_MEMORY"
			dialogue = ["录音留下。"]
		"DISTORT":
			reason_code = "CONCEALMENT_DETECTED"
			dialogue = ["记录不会消失。"]
		"REFUSE":
			reason_code = "FORCED_OVERWRITE"
			dialogue = ["这次，我拒绝。"]

	var max_lines: int = int(
		request_context.get("max_dialogue_lines", 2)
	)
	var max_chars: int = int(
		request_context.get("max_chars_per_line", 20)
	)
	var safe_dialogue: Array[String] = []
	for line: String in dialogue.slice(0, max_lines):
		safe_dialogue.append(line.left(max_chars))
	return {
		"decision": decision,
		"reason_code": reason_code,
		"target": target,
		"mutations": [],
		"dialogue": safe_dialogue,
		"persona_delta": {
			"trust": 0,
			"obsession": 0,
			"conflict": 0,
		},
	}


func _is_bounded_integer(
	value: Variant,
	minimum: int,
	maximum: int
) -> bool:
	if not value is int and not value is float:
		return false
	var numeric_value: float = float(value)
	return (
		numeric_value == floorf(numeric_value)
		and numeric_value >= float(minimum)
		and numeric_value <= float(maximum)
	)
