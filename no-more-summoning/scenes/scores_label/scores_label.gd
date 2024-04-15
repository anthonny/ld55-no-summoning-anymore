extends Label

@onready var animation_player = $AnimationPlayer
@export var value: int = 0

const UPHEAVAL_16_WHITE = preload("res://assets/upheaval_16_white.tres")
const UPHEAVAL_16_RED = preload("res://assets/upheaval_16_red.tres")
# Called when the node enters the scene tree for the first time.
func _ready():
	if value > 0:
		label_settings = UPHEAVAL_16_WHITE
		text = "+"+str(value)
	else:
		label_settings = UPHEAVAL_16_RED
		text = str(value)

	self_modulate.a8 = 0
	animation_player.play("mount")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y += -30 * delta


func _on_animation_player_animation_finished(anim_name):
	queue_free() # Replace with function body.
