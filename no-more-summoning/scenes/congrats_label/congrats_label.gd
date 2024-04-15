extends Label


@onready var animation_player = $AnimationPlayer
@export var value: int = 0

const UPHEAVAL_16_WHITE = preload("res://assets/upheaval_16_white.tres")
const UPHEAVAL_16_RED = preload("res://assets/upheaval_16_red.tres")
# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.level_won_streak.connect(_handle_level_won_streak)
	SignalManager.level_lost.connect(_handle_level_lost)
	#self_modulate.a8 = 0

func _handle_level_won_streak(streak):
	label_settings = UPHEAVAL_16_WHITE
	var label
	match streak:
		1:
			label = "GOOD!"
		2:
			label = "GREAT!"
		3:
			label = "EXCELLENT!"
		4:
			label = "AMAZING!"
		5:
			label = "INCREDIBLE!"
		6:
			label = "LEGENDARY!"
		7:
			label = "GODLIKE!"
		_:
			label = "GODLIKE!"
	text= label
	pivot_offset.x = size.x / 2
	pivot_offset.y = size.y / 2
	animation_player.play("bounce")

func _handle_level_lost():
	label_settings = UPHEAVAL_16_RED
	text= "Outch!"
	pivot_offset.x = size.x / 2
	pivot_offset.y = size.y / 2
	animation_player.play("bounce")
