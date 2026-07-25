extends Node

const CRISIS_TEXT: String = "03:00 远程清除将覆盖办公室终端。找到阿栀留下的证据。"


func get_crisis_text() -> String:
	return CRISIS_TEXT


func initialize_loop(loop_index: int) -> void:
	if loop_index != 1:
		return
	var game_state: Node = get_node("/root/GameState")
	var world_state: Dictionary = game_state.get("world_state")
	world_state[&"audio_exists"] = true
	world_state[&"soundprint_available"] = true
	world_state[&"evidence_extracted"] = false
	world_state[&"first_loop_choice"] = ""
	world_state[&"crisis_visible"] = true
	world_state[&"read_again_prompted"] = false
	world_state[&"completed_actions"] = {}


func should_offer_choice(loop_index: int) -> bool:
	if loop_index != 1:
		return false
	var world_state: Dictionary = _get_world_state()
	return (
		bool(world_state.get(&"audio_played", false))
		and bool(world_state.get(&"evidence_found", false))
		and String(world_state.get(&"first_loop_choice", "")).is_empty()
	)


func complete_choice(choice_id: StringName) -> Dictionary:
	var world_state: Dictionary = _get_world_state()
	if bool(world_state.get(&"read_again_prompted", false)):
		return {"ok": false, "error": "CHOICE_ALREADY_RESOLVED"}
	if choice_id not in [&"DELETE_AUDIO", &"KEEP_AUDIO"]:
		return {"ok": false, "error": "UNKNOWN_FIRST_LOOP_CHOICE"}
	var expected_choice: String = (
		"DELETE" if choice_id == &"DELETE_AUDIO" else "KEEP"
	)
	if String(world_state.get(&"first_loop_choice", "")) != expected_choice:
		return {"ok": false, "error": "CHOICE_EFFECT_MISSING"}

	world_state[&"read_again_prompted"] = true
	if choice_id == &"DELETE_AUDIO":
		return {
			"ok": true,
			"title": "证据已解压 · 声纹丢失",
			"detail": (
				"EVIDENCE_03.enc 已解压，但缺少阿栀声纹，无法解密。"
				+ " 当前时间线失败。读取 SAVE_01 再试一次。"
			),
		}
	return {
		"ok": true,
		"title": "录音已保留 · 证据未解压",
		"detail": (
			"阿栀的声音还在，但证据包仍被锁定。"
			+ " 清除即将开始。读取 SAVE_01 再试一次。"
		),
	}


func get_timeout_failure() -> Dictionary:
	var world_state: Dictionary = _get_world_state()
	world_state[&"read_again_prompted"] = true
	if not bool(world_state.get(&"audio_played", false)):
		return {
			"title": "清除开始 · 录音残片自动播放",
			"detail": (
				"“如果你听到了……别让 03 号替你决定。”"
				+ " 证据未完成。读取 SAVE_01 再试一次。"
			),
		}
	return {
		"title": "清除开始 · 证据链不完整",
		"detail": "当前时间线无法验证证据。读取 SAVE_01 再试一次。",
	}


func _get_world_state() -> Dictionary:
	return get_node("/root/GameState").get("world_state")
