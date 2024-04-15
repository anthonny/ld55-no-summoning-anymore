extends Node

const SCORES_PATH = "user://scores.json"
const LEVEL_BASE_PATH: String = "res://scenes/level"

signal scores_updated

var _delay_between_points_start: float = 1.0
var _delay_between_points_step: float = 1.0
var _duration_point_active: float = 1.0
var _level_index: int = 2
var _levels = []
var _score = 0
var _scores: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	_scores  = {
		"high_score": 0,
		"high_level": 2
	}
	load_scores_from_disc()
	load_levels(_level_index)

	SignalManager.point_validated.connect(func(): _add_to_score(50) )
	SignalManager.point_locked.connect(func(): _add_to_score(-20) )
	SignalManager.level_won.connect(_handle_level_won)
	SignalManager.level_semi_won.connect(_handle_level_semi_won)
	SignalManager.level_lost.connect(_handle_level_lost)


func _add_to_score(score):
	_score += score
	_score = clampf(_score, 0, absf(_score))
	if _score > _scores.high_score:
		_scores.high_score = _score
		save_to_disc()
	scores_updated.emit()

func _handle_level_won():
	_add_to_score(200)
	SignalManager.level_changed.emit()
func _handle_level_semi_won():
	SignalManager.level_changed.emit()

func _handle_level_lost():
	_add_to_score(-100)
	SignalManager.level_changed.emit()

func load_levels(level: int):
	var dir = DirAccess.open("%s/levels%s" % [LEVEL_BASE_PATH, level])
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				_levels.append(file_name.replace(".remap", ""))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func load_scores_from_disc():
	var file = FileAccess.open(SCORES_PATH,FileAccess.READ)
	if file == null:
		save_to_disc()
	else:
		var data = file.get_as_text()
		_scores = JSON.parse_string(data)

func save_to_disc():
	var file = FileAccess.open(SCORES_PATH, FileAccess.WRITE)
	var score_json_str = JSON.stringify(_scores)
	file.store_string(score_json_str)

func get_next_level():
	var next_level = _levels.pick_random()
	if not next_level:
		print("Not next level")

	print("%s/levels%s/%s" % [LEVEL_BASE_PATH, _level_index, next_level])
	var level_scene = load("%s/levels%s/%s" % [LEVEL_BASE_PATH, _level_index, next_level])

	if len(_levels) > 0:
		_levels = _levels.filter(func(name): return name != next_level)
		if (len(_levels) == 0):
			_level_index += 1
			load_levels(_level_index)

	return level_scene

func get_scores():
	return {
		"score": _score,
		"high_score": _scores.high_score
	}
