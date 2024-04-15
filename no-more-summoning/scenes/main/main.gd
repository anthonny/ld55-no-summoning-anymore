extends Control

@onready var player_holder = $PlayerHolder
@onready var marker_2d = $Marker2D
@onready var reset_timer = $ResetTimer
@onready var player = $Player
@onready var jump_to_start = $JumpToStart
@onready var start_timer = $StartTimer

const POINT = preload("res://scenes/point/point.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	_handle_point_locked()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("start"):
		GameManager.load_game_scene()

func _handle_point_locked():
	jump_to_start.text = "OUPS TOO LATE"
	reset_timer.start()

func _handle_point_active():
	jump_to_start.visible = true

func _handle_point_validated():
	jump_to_start.text = "LET'S GO!\nNEXT TIME PRESS ENTER"
	start_timer.start()

func _on_reset_timer_timeout():
	for child in player_holder.get_children():
		child.queue_free()

	var new_point = POINT.instantiate()
	new_point.position = marker_2d.position
	new_point.delay_until_locked = 5.0
	new_point.delay_until_pop = 0.1

	jump_to_start.visible = false
	jump_to_start.text = "JUMP ON TO START"
	new_point.locked.connect(_handle_point_locked)
	new_point.active.connect(_handle_point_active)
	new_point.validated.connect(_handle_point_validated)
	player_holder.add_child(new_point)


func _on_start_timer_timeout():
	GameManager.load_game_scene()
