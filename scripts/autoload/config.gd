extends Node

var backend_url: String = "http://127.0.0.1:8787"
var ai_enabled: bool = false
var demo_mode: bool = false
var request_timeout_seconds: float = 5.0
var build_channel: StringName = &"development"


func _ready() -> void:
	var backend_override: String = OS.get_environment(
		"RESIDUAL_BACKEND_URL"
	)
	if backend_override.begins_with("http://") or backend_override.begins_with(
		"https://"
	):
		backend_url = backend_override
	ai_enabled = OS.get_environment("RESIDUAL_AI_ENABLED") == "1"
	var timeout_override: String = OS.get_environment(
		"RESIDUAL_AI_TIMEOUT_SECONDS"
	)
	if timeout_override.is_valid_float():
		request_timeout_seconds = clampf(
			timeout_override.to_float(),
			0.1,
			5.0
		)
	demo_mode = (
		OS.get_environment("RESIDUAL_DEMO_MODE") == "1"
		or "--demo" in OS.get_cmdline_user_args()
	)
