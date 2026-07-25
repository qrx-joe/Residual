extends SceneTree

const AUDIO_CONTROLLER_SCRIPT: Script = preload(
	"res://scripts/audio/audio_controller.gd"
)
const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")

var cues: Array[StringName] = []


func _init() -> void:
	var original_volume_db: float = AudioServer.get_bus_volume_db(0)
	var original_muted: bool = AudioServer.is_bus_mute(0)

	var controller: Node = Node.new()
	controller.set_script(AUDIO_CONTROLLER_SCRIPT)
	controller.connect(&"cue_played", _on_cue_played)
	root.add_child(controller)
	await process_frame

	assert(controller.get("ambience_player") != null)
	assert(controller.get("voice_player") != null)
	assert(controller.get("sfx_player") != null)
	assert((controller.get("ambience_player") as AudioStreamPlayer).playing)

	controller.call(&"play_intro")
	assert(cues.back() == &"AZHI_INTRO")
	await _stop_and_flush(controller)
	controller.call(&"play_action", &"PLAY_AUDIO")
	assert(cues.back() == &"AZHI_RECORDING")
	await _stop_and_flush(controller)
	controller.call(&"play_action", &"USE_GHOST_AUDIO")
	assert(cues.back() == &"AZHI_GHOST")
	await _stop_and_flush(controller)
	controller.call(&"play_choice", &"DELETE_AUDIO")
	assert(cues.back() == &"DELETE_CONFIRM")
	await _stop_and_flush(controller)
	controller.call(&"play_overwrite_stage", 3)
	assert(cues.back() == &"OVERWRITE_REVERSE")
	await _stop_and_flush(controller)
	controller.call(&"play_overwrite_stage", 4)
	assert(cues.back() == &"CORE_GLITCH")
	await _stop_and_flush(controller)

	controller.call(&"set_master_volume", 0.25)
	assert(is_equal_approx(float(controller.get("master_volume")), 0.25))
	assert(
		is_equal_approx(
			AudioServer.get_bus_volume_db(0),
			linear_to_db(0.25)
		)
	)
	controller.call(&"set_muted", true)
	assert(AudioServer.is_bus_mute(0))
	controller.call(&"set_muted", false)
	assert(not AudioServer.is_bus_mute(0))

	var main: Control = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	assert(main.get_node("%VolumeSlider") is HSlider)
	assert(main.get_node("%MuteButton") is Button)

	var main_audio: Node = main.get_node("%AudioController")
	main_audio.call(&"stop_all")
	controller.call(&"stop_all")
	await create_timer(0.2).timeout
	main.free()
	controller.free()
	AudioServer.set_bus_volume_db(0, original_volume_db)
	AudioServer.set_bus_mute(0, original_muted)
	await create_timer(0.2).timeout
	print("T4.3 smoke: ambience, voice, cues, volume, and mute passed")
	quit()


func _on_cue_played(cue_id: StringName) -> void:
	cues.append(cue_id)


func _stop_and_flush(controller: Node) -> void:
	await process_frame
	controller.call(&"stop_all")
	await process_frame
