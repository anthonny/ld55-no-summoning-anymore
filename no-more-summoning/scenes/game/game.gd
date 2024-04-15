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

	var next_level = LevelManager.get_next_level()
	level_holder.add_child(next_level.instantiate())

func _handle_shake():
	camera_2d.shake
