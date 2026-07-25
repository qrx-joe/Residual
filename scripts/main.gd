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
@onready var force_overwrite_button: Button = %ForceOverwriteButton
@onready var overwrite_overlay: Control = %OverwriteOverlay
@onready var overwrite_progress: ProgressBar = %OverwriteProgress
@onready var overwrite_stage_label: Label = %OverwriteStageLabel
@onready var save_03_line_label: Label = %Save03LineLabel
@onready var overwrite_continue_button: Button = %OverwriteContinueButton
@onready var ghost_save_slot: VBoxContainer = %GhostSaveSlot
@onready var loop_manager: Node = %LoopManager
@onready var residual_data_manager: Node = %ResidualDataManager
@onready var anomaly_controller: Node = %AnomalyController
@onready var action_manager: Node = %ActionManager
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
	force_overwrite_button.pressed.connect(_on_force_overwrite_pressed)
	overwrite_continue_button.pressed.connect(_on_overwrite_continue_pressed)
	anomaly_controller.connect(&"progress_changed", _on_overwrite_progress_changed)
	anomaly_controller.connect(&"stage_changed", _on_overwrite_stage_changed)
	anomaly_controller.connect(&"overwrite_completed", _on_overwrite_completed)

	var game_state: Node = get_node("/root/GameState")
	var initial_loop_index: int = maxi(int(game_state.get("loop_index")), 1)
	loop_manager.call(&"start_loop", initial_loop_index)
	residual_data_manager.call(&"prepare_loop", initial_loop_index)
	save_data.call(&"create_world_snapshot")
	_refresh_residual_presentation()
	print(
		"T1.5 smoke: loop %d ready; persistence loaded"
		% initial_loop_index
	)


func _on_area_selected(
	region_id: StringName,
	_display_name: String,
	_description: String
) -> void:
	var action: Dictionary = action_manager.call(&"get_action", region_id)
	if action.is_empty():
		selection_label.text = "行动不可用"
		detail_label.text = "UNKNOWN_ACTION_ID · %s" % region_id
		return
	var action_accepted: bool = bool(
		loop_manager.call(&"request_action", region_id)
	)
	if not action_accepted:
		return

	var action_result: Dictionary = action_manager.call(
		&"execute_action",
		region_id
	)
	if not bool(action_result.get("ok", false)):
		loop_manager.call(&"cancel_action", region_id)
		selection_label.text = "行动被拒绝"
		detail_label.text = String(action_result.get("error", "ACTION_ERROR"))
		return

	selection_count += 1
	selection_label.text = String(action.get("display_name", region_id))
	detail_label.text = String(action.get("description", ""))
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
	var has_ghost_save: bool = bool(
		anomaly_controller.call(&"has_completed_overwrite")
	)
	ghost_save_slot.visible = has_ghost_save
	force_overwrite_button.visible = has_ghost_recording and not has_ghost_save
	force_overwrite_button.disabled = not force_overwrite_button.visible


func _on_force_overwrite_pressed() -> void:
	var started: bool = bool(
		anomaly_controller.call(&"request_force_overwrite")
	)
	if not started:
		return

	_set_interaction_enabled(false)
	overwrite_overlay.visible = true
	overwrite_progress.value = 0.0
	overwrite_stage_label.text = "FORCED OVERWRITE · READING"
	save_03_line_label.text = ""
	overwrite_continue_button.visible = false


func _on_overwrite_progress_changed(value: float) -> void:
	overwrite_progress.value = value


func _on_overwrite_stage_changed(stage: int) -> void:
	match stage:
		1:
			overwrite_stage_label.text = "FORCED OVERWRITE · READING"
		2:
			overwrite_stage_label.text = "99% · SIGNAL HELD"
		3:
			overwrite_stage_label.text = "OVERRIDE REJECTED · REVERSING"
		4:
			overwrite_stage_label.text = "SAVE_03 CORE · FRACTURE DETECTED"
		5:
			overwrite_stage_label.text = "GHOST SAVE · UNDELETABLE"
		6:
			overwrite_stage_label.text = "她曾经来过"


func _on_overwrite_completed() -> void:
	save_03_line_label.text = "SAVE_03：你可以回去。\n她留下。"
	overwrite_continue_button.visible = true
	ghost_save_slot.visible = true
	force_overwrite_button.visible = false
	save_data.call(&"save_persistent_state")


func _on_overwrite_continue_pressed() -> void:
	overwrite_overlay.visible = false
	_set_interaction_enabled(true)
	_refresh_residual_presentation()


func _set_interaction_enabled(enabled: bool) -> void:
	var loop_has_timed_out: bool = bool(loop_manager.get("timed_out"))
	for area: Button in investigation_areas:
		area.disabled = not enabled or loop_has_timed_out
	load_button.disabled = not enabled or not loop_has_timed_out
	delete_recording_button.disabled = (
		not enabled or not delete_recording_button.visible
	)
	force_overwrite_button.disabled = (
		not enabled or not force_overwrite_button.visible
	)
