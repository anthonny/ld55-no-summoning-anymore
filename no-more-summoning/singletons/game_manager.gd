extends Node

enum STATES {DISPLAYING_MAIN, DISPLAYING_GAME, DISPLAYING_PAUSE}
enum ACTIONS {DISPLAY_GAME, DISPLAY_MAIN}

const MAIN = preload("res://scenes/main/main.tscn")
const GAME = preload("res://scenes/game/game.tscn")

var state = STATES.DISPLAYING_MAIN

func update(action: ACTIONS, state):
	match [action, state]:
		[ACTIONS.DISPLAY_GAME, STATES.DISPLAYING_MAIN]:
			get_tree().change_scene_to_packed(GAME)
			return state
		[ACTIONS.DISPLAY_MAIN, STATES.DISPLAYING_GAME]:
			get_tree().change_scene_to_packed(MAIN)
			return state
		_:
			return state

func load_game_scene():
	state  = update(ACTIONS.DISPLAY_GAME, state)

func load_main_scene():
	state  = update(ACTIONS.DISPLAY_MAIN, state)
#
