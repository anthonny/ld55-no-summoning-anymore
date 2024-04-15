extends Node2D

@onready var level_holder = $LevelHolder
@onready var camera_2d = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_level_changed()
	SignalManager.level_changed.connect(_handle_level_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


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
