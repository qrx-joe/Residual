extends Node

enum Phase {
	BOOT,
	INTRO,
	LOOP_PLAY,
	ACTION_RESOLVE,
	LOOP_TIMEOUT,
	SAVE_REQUEST,
	SAVE_NEGOTIATION,
	SAVE_DECISION,
	WORLD_RESET,
	NEXT_LOOP,
	FINAL_REVEAL,
	FINAL_CHOICE,
	ENDING,
}

var phase: Phase = Phase.BOOT
var loop_index: int = 0
var world_state: Dictionary = {}
var player_knowledge: Dictionary = {}
var persona_state: Dictionary = {}
var residual_state: Dictionary = {}
var history: Array = []
