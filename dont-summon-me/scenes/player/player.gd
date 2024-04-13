extends Area2D


var normal_speed: float = 120.0
var dash_speed: float = 1200.0
var current_speed: float = normal_speed
var velocity: Vector2 = Vector2(0, 0)
var is_dashing: bool = false

var current_direction: Vector2 = Vector2(0, 0)


@onready var dash_timer = $DashTimer


# Called when the node enters the scene tree for the first time.
func _ready():
	current_direction = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if (not is_dashing):
		print("ahaha")
		var gmp = get_global_mouse_position()
		current_direction = gmp - position

		if (current_direction.length() < 1.0):
			return
		#if direction.length() > 1.0:
		current_direction = current_direction.normalized()

		if Input.is_action_just_pressed("dash"):
			is_dashing = true
			current_speed = dash_speed
			dash_timer.start()

	velocity = current_direction * current_speed
	position += velocity * delta

	#if direction.length() > 0.0:
		#rotation = velocity.angle()

func _on_dash_timeout() -> void:
	current_speed = normal_speed
	is_dashing = false
