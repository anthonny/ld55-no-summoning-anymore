extends Node

const SCORES_PATH = "user://scores.json"
const LEVEL_BASE_PATH: String = "res://scenes/level"
const MAX_LEVEL: int = 7

signal scores_updated

## A BIT HARD
#var _delay_until_level_finished: float = 0.3
#var _delay_until_points_start: float = 0.5
#var _delay_between_points_steps: float =  0.3
#var _delay_until_point_lock: float = 1.0

var _delay_until_level_finished: float = 1.0 #1.5
var _delay_until_points_start: float = 1.5 # 1.0
var _delay_between_points_steps: float = 0.5 # 1.0
var _delay_until_point_lock: float = 1.5 #1.5

var _level_index: int = 6
var _all_levels = []
var _levels = []
var _score = 0
var _level_won_streak = 0

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
	scores_updated.emit(score)

func _handle_level_won():
	_level_won_streak += 1
	_add_to_score(200)
	SignalManager.level_changed.emit()
	SignalManager.level_won_streak.emit(_level_won_streak)

func _handle_level_semi_won():
	SignalManager.level_changed.emit()

func _handle_level_lost():
	_level_won_streak = 0
	_add_to_score(-100)
	SignalManager.level_changed.emit()

func load_levels(level_index: int):
	if (level_index > MAX_LEVEL):
		_levels = _all_levels

	match level_index:
		2:
			_delay_until_level_finished = 1.0
			_delay_until_points_start = 1.5
			_delay_between_points_steps = 0.5
			_delay_until_point_lock = 1.5
		3:
			_delay_until_level_finished = 1.0
			_delay_until_points_start = 1.4
			_delay_between_points_steps = 0.5
			_delay_until_point_lock = 1.5
		4:
			_delay_until_level_finished = 1.0
			_delay_until_points_start = 1.3
			_delay_between_points_steps = 0.5
			_delay_until_point_lock = 1.4
		5:
			_delay_until_level_finished = 1.0
			_delay_until_points_start = 1.2
			_delay_between_points_steps = 0.5
			_delay_until_point_lock = 1.4
		6:
			_delay_until_level_finished = 1.0
			_delay_until_points_start = 1.1
			_delay_between_points_steps = 0.45
			_delay_until_point_lock = 1.3
		7:
			_delay_until_level_finished = 1.0
			_delay_until_points_start = 1.0
			_delay_between_points_steps = 0.45
			_delay_until_point_lock = 1.3
		_:
			_delay_until_level_finished = 1.0
			_delay_until_points_start = 1.0
			_delay_between_points_steps = 0.45
			_delay_until_point_lock = 1.3


	var dir = DirAccess.open("%s/levels%s" % [LEVEL_BASE_PATH, level_index])
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				var level_name = file_name.replace(".remap", "")
				var level = {
					"level": level_index,
					"name": level_name
				}
				_all_levels.append(level)
				_levels.append(level)
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

	print("%s/levels%s/%s" % [LEVEL_BASE_PATH, next_level.level, next_level.name])
	var level_scene = load("%s/levels%s/%s" % [LEVEL_BASE_PATH, next_level.level, next_level.name])

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

func get_delays():
	return {
		"delay_until_level_finished": _delay_until_level_finished,
		"delay_until_points_start": _delay_until_points_start,
		"delay_between_points_steps": _delay_between_points_steps,
		"delay_until_point_lock": _delay_until_point_lock
	}
