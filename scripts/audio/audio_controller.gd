extends Node

signal volume_changed(value: float)
signal mute_changed(muted: bool)
signal cue_played(cue_id: StringName)

const OFFICE_AMBIENCE: AudioStream = preload(
	"res://assets/audio/ambience/office_night.wav"
)
const UI_CLICK: AudioStream = preload(
	"res://assets/audio/sfx/ui_click.wav"
)
const DELETE_CONFIRM: AudioStream = preload(
	"res://assets/audio/sfx/delete_confirm.wav"
)
const CORE_GLITCH: AudioStream = preload(
	"res://assets/audio/sfx/core_glitch.wav"
)
const OVERWRITE_REVERSE: AudioStream = preload(
	"res://assets/audio/sfx/overwrite_reverse.wav"
)
const AZHI_INTRO: AudioStream = preload(
	"res://assets/audio/voice/voice_azhi_intro.wav"
)
const AZHI_RECORDING: AudioStream = preload(
	"res://assets/audio/voice/voice_azhi_recording.wav"
)
const AZHI_GHOST: AudioStream = preload(
	"res://assets/audio/voice/voice_azhi_ghost.wav"
)

var master_volume: float = 0.58
var muted: bool = false
var ambience_player: AudioStreamPlayer
var voice_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer


func _ready() -> void:
	ambience_player = AudioStreamPlayer.new()
	ambience_player.name = "AmbiencePlayer"
	ambience_player.stream = OFFICE_AMBIENCE
	ambience_player.volume_db = -13.0
	add_child(ambience_player)

	voice_player = AudioStreamPlayer.new()
	voice_player.name = "VoicePlayer"
	add_child(voice_player)

	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	add_child(sfx_player)

	_set_stream_loop(OFFICE_AMBIENCE)
	set_master_volume(master_volume)
	ambience_player.play()


func play_intro() -> void:
	_play_voice(AZHI_INTRO, &"AZHI_INTRO")


func play_action(action_id: StringName) -> void:
	match action_id:
		&"PLAY_AUDIO", &"USE_PRESERVED_AUDIO":
			_play_voice(AZHI_RECORDING, &"AZHI_RECORDING")
		&"USE_GHOST_AUDIO":
			_play_voice(AZHI_GHOST, &"AZHI_GHOST")
		_:
			_play_sfx(UI_CLICK, &"UI_CLICK")


func play_choice(choice_id: StringName) -> void:
	if choice_id == &"DELETE_AUDIO":
		_play_sfx(DELETE_CONFIRM, &"DELETE_CONFIRM")
	else:
		_play_sfx(UI_CLICK, &"UI_CLICK")


func play_overwrite_stage(stage: int) -> void:
	match stage:
		3:
			_play_sfx(OVERWRITE_REVERSE, &"OVERWRITE_REVERSE")
		4:
			_play_sfx(CORE_GLITCH, &"CORE_GLITCH")


func set_ending_state(ending_id: StringName) -> void:
	match ending_id:
		&"PUBLIC_TRUTH":
			ambience_player.pitch_scale = 0.82
			ambience_player.volume_db = -17.0
		&"PRESERVE_MEMORY":
			ambience_player.pitch_scale = 0.94
			ambience_player.volume_db = -10.0
	cue_played.emit(&"ENDING_AMBIENCE")


func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_apply_master_bus()
	volume_changed.emit(master_volume)


func set_muted(value: bool) -> void:
	muted = value
	_apply_master_bus()
	mute_changed.emit(muted)


func stop_all() -> void:
	ambience_player.stop()
	voice_player.stop()
	sfx_player.stop()
	ambience_player.stream = null
	voice_player.stream = null
	sfx_player.stream = null


func _apply_master_bus() -> void:
	AudioServer.set_bus_mute(0, muted)
	AudioServer.set_bus_volume_db(
		0,
		linear_to_db(maxf(master_volume, 0.0001))
	)


func _play_voice(stream: AudioStream, cue_id: StringName) -> void:
	voice_player.stop()
	voice_player.stream = stream
	voice_player.play()
	cue_played.emit(cue_id)


func _play_sfx(stream: AudioStream, cue_id: StringName) -> void:
	sfx_player.stop()
	sfx_player.stream = stream
	sfx_player.play()
	cue_played.emit(cue_id)


func _set_stream_loop(stream: AudioStream) -> void:
	if stream is AudioStreamWAV:
		var wav_stream: AudioStreamWAV = stream as AudioStreamWAV
		wav_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
