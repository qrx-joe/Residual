extends Control

@onready var selection_label: Label = %SelectionLabel
@onready var detail_label: Label = %DetailLabel
@onready var time_label: Label = %TimeLabel
@onready var actions_label: Label = %ActionsLabel
@onready var loop_status_label: Label = %LoopStatusLabel
@onready var feedback_panel: PanelContainer = %FeedbackPanel
@onready var save_status_label: Label = %SaveStatusLabel
@onready var load_button: Button = %LoadButton
@onready var delete_recording_button: Button = %DeleteRecordingButton
@onready var ghost_waveform_label: Label = %GhostWaveformLabel
@onready var loop_manager: Node = %LoopManager
@onready var residual_data_manager: Node = %ResidualDataManager
@onready var save_data: Node = get_node("/root/SaveData")
@onready var investigation_areas: Array[Button] = [
	%PhoneArea,
	%ComputerArea,
	%DrawerArea,
]

var selection_count: int = 0


func _ready() -> void:
	for area: Button in investigation_areas:
		area.connect(&"area_selected", _on_area_selected)

	loop_manager.connect(&"state_changed", _on_loop_state_changed)
	loop_manager.connect(&"loop_timed_out", _on_loop_timed_out)
	load_button.pressed.connect(_on_load_pressed)
	delete_recording_button.pressed.connect(_on_delete_recording_pressed)

	var game_state: Node = get_node("/root/GameState")
	var initial_loop_index: int = maxi(int(game_state.get("loop_index")), 1)
	loop_manager.call(&"start_loop", initial_loop_index)
	residual_data_manager.call(&"prepare_loop", initial_loop_index)
	save_data.call(&"create_world_snapshot")
	_refresh_residual_presentation()
	print(
		"T1.4 smoke: loop %d ready; persistence loaded"
		% initial_loop_index
	)


func _on_area_selected(
	region_id: StringName,
	display_name: String,
	description: String
) -> void:
	var action_accepted: bool = bool(
		loop_manager.call(&"request_action", region_id)
	)
	if not action_accepted:
		return

	selection_count += 1
	selection_label.text = display_name
	detail_label.text = description
	_update_delete_recording_action(region_id)
	print("T1.1 area selected: %s" % region_id)

	var feedback_tween: Tween = create_tween()
	feedback_tween.tween_property(
		feedback_panel,
		"modulate",
		Color(0.56, 0.83, 0.85, 0.72),
		0.1
	)
	feedback_tween.tween_property(feedback_panel, "modulate", Color.WHITE, 0.18)
	await feedback_tween.finished
	loop_manager.call(&"complete_action", region_id)


func _on_loop_state_changed(
	actions_remaining: int,
	display_time: String,
	action_resolving: bool
) -> void:
	time_label.text = display_time
	actions_label.text = "ACTIONS %d / 4" % actions_remaining
	if action_resolving:
		loop_status_label.text = "ACTION RESOLVING"
	elif actions_remaining > 0:
		loop_status_label.text = "DATA PURGE PENDING"


func _on_loop_timed_out() -> void:
	loop_status_label.text = "DATA PURGE STARTED"
	selection_label.text = "03:00 · 调查结束"
	detail_label.text = "四次行动已用尽。远程数据清除阶段开始。"
	for area: Button in investigation_areas:
		area.disabled = true
	load_button.disabled = false


func _on_load_pressed() -> void:
	if load_button.disabled:
		return

	load_button.disabled = true
	var event_bus: Node = get_node("/root/EventBus")
	event_bus.emit_signal(&"save_requested", &"LOAD")
	var restored: bool = bool(save_data.call(&"restore_world_snapshot"))
	if not restored:
		save_status_label.text = "读取失败"
		load_button.disabled = false
		return

	var game_state: Node = get_node("/root/GameState")
	var next_loop_index: int = int(game_state.get("loop_index")) + 1
	loop_manager.call(&"start_loop", next_loop_index)
	residual_data_manager.call(&"prepare_loop", next_loop_index)
	for area: Button in investigation_areas:
		area.disabled = false

	selection_label.text = "已恢复至 02:47"
	detail_label.text = "世界状态已恢复；已获得的知识与 SAVE_03 人格不会回滚。"
	delete_recording_button.visible = false
	_refresh_residual_presentation()
	save_data.call(&"save_persistent_state")
	print("T1.3 load: world restored; knowledge and persona preserved")


func _on_delete_recording_pressed() -> void:
	if delete_recording_button.disabled:
		return

	residual_data_manager.call(&"record_recording_deletion")
	save_data.call(&"save_persistent_state")
	delete_recording_button.disabled = true
	delete_recording_button.text = "录音缓存已删除"
	detail_label.text = "本地录音缓存已删除。SAVE_03 记录了这次操作。"
	print("T1.4 deletion: recording deletion persisted")


func _update_delete_recording_action(region_id: StringName) -> void:
	var was_deleted: bool = bool(
		residual_data_manager.call(&"has_recording_been_deleted")
	)
	var should_show: bool = region_id == &"PHONE" and not was_deleted
	delete_recording_button.visible = should_show
	delete_recording_button.disabled = not should_show
	delete_recording_button.text = "删除本地录音缓存"


func _refresh_residual_presentation() -> void:
	var has_ghost_recording: bool = bool(
		residual_data_manager.call(&"has_ghost_recording")
	)
	ghost_waveform_label.visible = has_ghost_recording
	save_status_label.text = "已记录" if has_ghost_recording else "已保存"
