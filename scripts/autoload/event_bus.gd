extends Node

signal action_requested(action_id: StringName)
signal action_resolved(action_id: StringName, result: Dictionary)
signal loop_started(loop_index: int)
signal loop_ended(loop_index: int)
signal save_requested(mode: StringName)
signal save_decision_ready(decision: Dictionary)
signal persona_changed(delta: Dictionary)
signal residual_data_spawned(item_id: StringName)
signal ending_requested(ending_id: StringName)
