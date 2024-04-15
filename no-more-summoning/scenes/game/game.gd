extends Node2D

@onready var level_holder = $LevelHolder
@onready var camera_2d = $Camera2D
@onready var scores_marker = $ScoresMarker

const SCORES_LABEL = preload("res://scenes/scores_label/scores_label.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_level_changed()
	SignalManager.level_changed.connect(_handle_level_changed)
	LevelManager.scores_updated.connect(handle_score_updated)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("quit"):
		GameManager.load_main_scene()


func _handle_level_changed():
	for level in level_holder.get_children():
		level.queue_free()

	var next_level_packed_scene = LevelManager.get_next_level()
	var delays = LevelManager.get_delays()
	var next_level = next_level_packed_scene.instantiate()

	next_level.delay_until_level_finished = delays.delay_until_level_finished
	next_level.delay_until_points_start = delays.delay_until_points_start
	next_level.delay_between_points_steps = delays.delay_between_points_steps
	next_level.delay_until_point_lock = delays.delay_until_point_lock

	level_holder.add_child(next_level)

func _handle_shake():
	camera_2d.shake

func handle_score_updated(score):
	var scoresLabel = SCORES_LABEL.instantiate()
	scoresLabel.value = score
	scoresLabel.position = scores_marker.position
	add_child(scoresLabel)
