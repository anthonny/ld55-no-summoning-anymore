extends Node

const TRIANGLE_LEVEL = preload("res://scenes/level/levels/triangle_level.tscn")

const GAME = preload("res://scenes/game/game.tscn")

func load_game_scene():
	get_tree().change_scene_to_packed(GAME)
