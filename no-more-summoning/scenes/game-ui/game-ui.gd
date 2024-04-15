extends Control

@onready var score_value = $MC/VBoxContainer/VBS/ScoreValue
@onready var high_score_value = $MC/VBoxContainer/VBHS/HighScoreValue


func _ready():
	_handle_score_updated()
	LevelManager.scores_updated.connect(_handle_score_updated)

func _process(delta):
	pass

func _handle_score_updated():
	var scores = LevelManager.get_scores()
	score_value.text = str(scores.score)
	high_score_value.text = str(scores.high_score)
