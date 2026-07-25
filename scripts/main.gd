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
@onready var ghost_evidence_header_label: Label = %GhostEvidenceHeaderLabel
@onready var force_overwrite_button: Button = %ForceOverwriteButton
@onready var overwrite_overlay: Control = %OverwriteOverlay
@onready var overwrite_progress: ProgressBar = %OverwriteProgress
@onready var overwrite_stage_label: Label = %OverwriteStageLabel
@onready var save_03_line_label: Label = %Save03LineLabel
@onready var overwrite_continue_button: Button = %OverwriteContinueButton
@onready var ghost_save_slot: VBoxContainer = %GhostSaveSlot
@onready var crisis_label: Label = %CrisisLabel
@onready var first_loop_decision_overlay: Control = %FirstLoopDecisionOverlay
@onready var delete_audio_choice_button: Button = %DeleteAudioChoiceButton
@onready var keep_audio_choice_button: Button = %KeepAudioChoiceButton
@onready var decision_title: Label = %DecisionTitle
@onready var decision_detail: Label = %DecisionDetail
@onready var negotiation_entry_overlay: Control = %NegotiationEntryOverlay
@onready var negotiation_title_label: Label = %NegotiationTitleLabel
@onready var negotiation_detail_label: Label = %NegotiationDetailLabel
@onready var enter_negotiation_button: Button = %EnterNegotiationButton
@onready var negotiation_options_overlay: Control = %NegotiationOptionsOverlay
@onready var confess_button: Button = %ConfessButton
@onready var bargain_button: Button = %BargainButton
@onready var conceal_button: Button = %ConcealButton
@onready var negotiation_force_button: Button = %ForceButton
@onready var negotiation_result_label: Label = %NegotiationResultLabel
@onready var continue_after_negotiation_button: Button = (
	%ContinueAfterNegotiationButton
)
@onready var loop_manager: Node = %LoopManager
@onready var residual_data_manager: Node = %ResidualDataManager
@onready var anomaly_controller: Node = %AnomalyController
@onready var action_manager: Node = %ActionManager
@onready var first_loop_content_manager: Node = %FirstLoopContentManager
@onready var second_loop_content_manager: Node = %SecondLoopContentManager
@onready var save_will_manager: Node = %SaveWillManager
@onready var save_data: Node = get_node("/root/SaveData")
@onready var investigation_areas: Array[Button] = [
	%PhoneArea,
	%ComputerArea,
	%DrawerArea,
]

var selection_count: int = 0
var pending_first_loop_failure: Dictionary = {}
var pending_negotiation_result: Dictionary = {}


func _ready() -> void:
	for area: Button in investigation_areas:
		area.connect(&"area_selected", _on_area_selected)

	loop_manager.connect(&"state_changed", _on_loop_state_changed)
	loop_manager.connect(&"loop_timed_out", _on_loop_timed_out)
	load_button.pressed.connect(_on_load_pressed)
	delete_recording_button.pressed.connect(_on_delete_recording_pressed)
	force_overwrite_button.pressed.connect(_on_force_overwrite_pressed)
	overwrite_continue_button.pressed.connect(_on_overwrite_continue_pressed)
	delete_audio_choice_button.pressed.connect(
		_on_first_loop_choice.bind(&"DELETE_AUDIO")
	)
	keep_audio_choice_button.pressed.connect(
		_on_first_loop_choice.bind(&"KEEP_AUDIO")
	)
	enter_negotiation_button.pressed.connect(_on_enter_negotiation_pressed)
	confess_button.pressed.connect(
		_on_negotiation_choice.bind(&"CONFESS")
	)
	bargain_button.pressed.connect(
		_on_negotiation_choice.bind(&"BARGAIN")
	)
	conceal_button.pressed.connect(
		_on_negotiation_choice.bind(&"CONCEAL")
	)
	negotiation_force_button.pressed.connect(
		_on_negotiation_choice.bind(&"FORCE")
	)
	continue_after_negotiation_button.pressed.connect(
		_on_continue_after_negotiation
	)
	anomaly_controller.connect(&"progress_changed", _on_overwrite_progress_changed)
	anomaly_controller.connect(&"stage_changed", _on_overwrite_stage_changed)
	anomaly_controller.connect(&"overwrite_completed", _on_overwrite_completed)

	var game_state: Node = get_node("/root/GameState")
	var initial_loop_index: int = maxi(int(game_state.get("loop_index")), 1)
	loop_manager.call(&"start_loop", initial_loop_index)
	first_loop_content_manager.call(&"initialize_loop", initial_loop_index)
	second_loop_content_manager.call(&"initialize_loop", initial_loop_index)
	residual_data_manager.call(&"prepare_loop", initial_loop_index)
	save_data.call(&"create_world_snapshot")
	crisis_label.visible = initial_loop_index == 1
	if initial_loop_index == 1:
		selection_label.text = "03:00 前找到阿栀留下的证据"
		detail_label.text = String(
			first_loop_content_manager.call(&"get_crisis_text")
		)
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
	var action: Dictionary = action_manager.call(
		&"get_available_action_for_region",
		region_id
	)
	if action.is_empty():
		selection_label.text = "该区域暂无线索"
		detail_label.text = "已检查当前时间线中可用的内容。"
		return
	var action_id: StringName = StringName(String(action.get("id", "")))
	var action_accepted: bool = bool(
		loop_manager.call(&"request_action", action_id)
	)
	if not action_accepted:
		return

	var action_result: Dictionary = action_manager.call(
		&"execute_action",
		action_id
	)
	if not bool(action_result.get("ok", false)):
		loop_manager.call(&"cancel_action", action_id)
		selection_label.text = "行动被拒绝"
		detail_label.text = String(action_result.get("error", "ACTION_ERROR"))
		return

	selection_count += 1
	selection_label.text = String(action.get("display_name", region_id))
	detail_label.text = String(action.get("description", ""))
	_update_delete_recording_action(action_id)
	print("Action selected: %s" % action_id)

	var feedback_tween: Tween = create_tween()
	feedback_tween.tween_property(
		feedback_panel,
		"modulate",
		Color(0.56, 0.83, 0.85, 0.72),
		0.1
	)
	feedback_tween.tween_property(feedback_panel, "modulate", Color.WHITE, 0.18)
	await feedback_tween.finished
	loop_manager.call(&"complete_action", action_id)
	_maybe_offer_first_loop_choice()


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
	if (
		pending_negotiation_result.is_empty()
		and pending_first_loop_failure.is_empty()
	):
		var game_state: Node = get_node("/root/GameState")
		if int(game_state.get("loop_index")) == 1:
			pending_first_loop_failure = (
				first_loop_content_manager.call(&"get_timeout_failure")
			)
	if not pending_negotiation_result.is_empty():
		selection_label.text = String(
			pending_negotiation_result.get("title", "谈判已完成")
		)
		detail_label.text = String(
			pending_negotiation_result.get(
				"detail",
				"决定已保存。读取 SAVE_01 进入下一轮。"
			)
		)
	elif not pending_first_loop_failure.is_empty():
		selection_label.text = String(
			pending_first_loop_failure.get("title", "03:00 · 调查结束")
		)
		detail_label.text = String(
			pending_first_loop_failure.get(
				"detail",
				"当前时间线失败。读取 SAVE_01 再试一次。"
			)
		)
	else:
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
	first_loop_content_manager.call(&"initialize_loop", next_loop_index)
	second_loop_content_manager.call(&"initialize_loop", next_loop_index)
	residual_data_manager.call(&"prepare_loop", next_loop_index)
	for area: Button in investigation_areas:
		area.disabled = false

	selection_label.text = "已恢复至 02:47"
	detail_label.text = "世界状态已恢复；已获得的知识与 SAVE_03 人格不会回滚。"
	delete_recording_button.visible = false
	first_loop_decision_overlay.visible = false
	negotiation_entry_overlay.visible = false
	negotiation_options_overlay.visible = false
	pending_first_loop_failure.clear()
	pending_negotiation_result.clear()
	crisis_label.visible = false
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
	delete_recording_button.visible = false
	delete_recording_button.disabled = true


func _maybe_offer_first_loop_choice() -> void:
	var game_state: Node = get_node("/root/GameState")
	var loop_index: int = int(game_state.get("loop_index"))
	var first_loop_choice_ready: bool = bool(
		first_loop_content_manager.call(
			&"should_offer_choice",
			loop_index
		)
	)
	var second_loop_choice_ready: bool = bool(
		second_loop_content_manager.call(
			&"should_offer_choice",
			loop_index
		)
	)
	if not first_loop_choice_ready and not second_loop_choice_ready:
		return
	_set_interaction_enabled(false)
	first_loop_decision_overlay.visible = true
	if loop_index == 2:
		decision_title.text = "SAVE_03 已记录上一次选择"
		decision_detail.text = (
			"同一份证据，同一段声音。\n"
			+ "这次操作将决定 SAVE_03 是否开启谈判。"
		)
	else:
		decision_title.text = "空间冲突 · 此操作无法撤销"
		decision_detail.text = (
			"EVIDENCE_03.enc 需要 2.4 GB，当前仅 0.6 GB。\n"
			+ "删除阿栀的语音缓存才能解压证据。"
		)
	delete_audio_choice_button.disabled = false
	keep_audio_choice_button.disabled = false


func _on_first_loop_choice(choice_id: StringName) -> void:
	if not first_loop_decision_overlay.visible:
		return
	delete_audio_choice_button.disabled = true
	keep_audio_choice_button.disabled = true

	var game_state: Node = get_node("/root/GameState")
	var loop_index: int = int(game_state.get("loop_index"))
	var action: Dictionary = action_manager.call(&"get_action", choice_id)
	var cost: int = int(action.get("cost", 0)) if loop_index == 1 else 0
	if cost > 0 and not bool(loop_manager.call(&"request_action", choice_id)):
		return
	var action_result: Dictionary = action_manager.call(
		&"execute_action",
		choice_id
	)
	if not bool(action_result.get("ok", false)):
		if cost > 0:
			loop_manager.call(&"cancel_action", choice_id)
		detail_label.text = String(action_result.get("error", "ACTION_ERROR"))
		delete_audio_choice_button.disabled = false
		keep_audio_choice_button.disabled = false
		return

	first_loop_decision_overlay.visible = false
	if loop_index == 2:
		var second_result: Dictionary = second_loop_content_manager.call(
			&"complete_choice",
			choice_id,
			residual_data_manager
		)
		if not bool(second_result.get("ok", false)):
			detail_label.text = String(
				second_result.get("error", "SECOND_LOOP_CHOICE_ERROR")
			)
			_set_interaction_enabled(true)
			return
		negotiation_title_label.text = String(second_result.get("title", ""))
		negotiation_detail_label.text = String(
			second_result.get("detail", "")
		)
		negotiation_entry_overlay.visible = true
		save_data.call(&"save_persistent_state")
		_refresh_residual_presentation()
		return

	pending_first_loop_failure = first_loop_content_manager.call(
		&"complete_choice",
		choice_id
	)
	if choice_id == &"DELETE_AUDIO":
		residual_data_manager.call(&"record_recording_deletion")
	else:
		residual_data_manager.call(&"record_recording_preservation")
	save_data.call(&"save_persistent_state")
	if cost > 0:
		loop_manager.call(&"complete_action", choice_id)
	if not bool(loop_manager.get("timed_out")):
		loop_manager.call(&"end_loop_early", choice_id)


func _on_enter_negotiation_pressed() -> void:
	if not bool(second_loop_content_manager.call(&"enter_negotiation")):
		return
	negotiation_entry_overlay.visible = false
	negotiation_options_overlay.visible = true
	negotiation_result_label.visible = false
	continue_after_negotiation_button.visible = false
	for button: Button in _get_negotiation_buttons():
		button.disabled = false
	loop_status_label.text = "SAVE NEGOTIATION"


func _on_negotiation_choice(decision_id: StringName) -> void:
	var result: Dictionary = save_will_manager.call(
		&"resolve_decision",
		decision_id
	)
	if not bool(result.get("ok", false)):
		negotiation_result_label.text = String(
			result.get("error", "NEGOTIATION_ERROR")
		)
		negotiation_result_label.visible = true
		return
	for button: Button in _get_negotiation_buttons():
		button.disabled = true
	save_data.call(&"save_persistent_state")

	if bool(result.get("trigger_force_overwrite", false)):
		negotiation_options_overlay.visible = false
		var started: bool = bool(
			anomaly_controller.call(&"request_force_overwrite")
		)
		if started:
			_set_interaction_enabled(false)
			overwrite_overlay.visible = true
			overwrite_progress.value = 0.0
			overwrite_stage_label.text = "FORCED OVERWRITE · READING"
			save_03_line_label.text = ""
			overwrite_continue_button.visible = false
			return
		if bool(anomaly_controller.call(&"has_completed_overwrite")):
			pending_negotiation_result = result
			_on_continue_after_negotiation()
		return

	negotiation_result_label.text = "%s\n%s" % [
		String(result.get("title", "")),
		String(result.get("detail", "")),
	]
	negotiation_result_label.visible = true
	continue_after_negotiation_button.visible = true
	pending_negotiation_result = result


func _on_continue_after_negotiation() -> void:
	if not bool(save_will_manager.call(&"can_continue_after_negotiation")):
		return
	negotiation_options_overlay.visible = false
	if not bool(loop_manager.get("timed_out")):
		loop_manager.call(&"end_loop_early", &"NEGOTIATION_COMPLETE")
	selection_label.text = String(
		pending_negotiation_result.get("title", "谈判已完成")
	)
	detail_label.text = (
		String(pending_negotiation_result.get("detail", ""))
		+ "\n决定已保存。读取 SAVE_01 进入下一轮。"
	)
	load_button.disabled = false
	save_data.call(&"save_persistent_state")


func _get_negotiation_buttons() -> Array[Button]:
	return [
		confess_button,
		bargain_button,
		conceal_button,
		negotiation_force_button,
	]


func _refresh_residual_presentation() -> void:
	var has_ghost_recording: bool = bool(
		residual_data_manager.call(&"has_ghost_recording")
	)
	ghost_waveform_label.visible = has_ghost_recording
	ghost_evidence_header_label.visible = bool(
		residual_data_manager.call(&"has_ghost_evidence_header")
	)
	var has_visible_residual: bool = (
		has_ghost_recording or ghost_evidence_header_label.visible
	)
	save_status_label.text = "已记录" if has_visible_residual else "已保存"
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
	var player_knowledge: Dictionary = (
		get_node("/root/GameState").get("player_knowledge")
	)
	if String(player_knowledge.get(&"negotiation_choice", "")) == "FORCE":
		overwrite_continue_button.text = "保存决定并读档"
	ghost_save_slot.visible = true
	force_overwrite_button.visible = false
	save_data.call(&"save_persistent_state")


func _on_overwrite_continue_pressed() -> void:
	overwrite_overlay.visible = false
	var player_knowledge: Dictionary = (
		get_node("/root/GameState").get("player_knowledge")
	)
	if String(player_knowledge.get(&"negotiation_choice", "")) == "FORCE":
		pending_negotiation_result = {
			"title": "强制覆盖完成",
			"detail": "你可以回去。她留下。",
		}
		_on_continue_after_negotiation()
		return
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
