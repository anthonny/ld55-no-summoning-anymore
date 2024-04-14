extends Area2D

enum STATES {STANDING, DASHING, JUMPING}
enum ACTIONS {TICK, STAND, DASH, JUMP}

@export var dash_speed: float = 1500.0
@onready var animation_player = $AnimationPlayer

var state = {}

@onready var dash_timer = $DashTimer
@onready var sprite_2d = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	state = {
		"delta": 0.0,
		"player_state": STATES.STANDING,
		"targeted_position": position,
		"current_direction": Vector2(0, 0)
	}


func _physics_process(delta):
	state.delta = delta
	state = update(ACTIONS.TICK, state)


func update(action: ACTIONS, state):
	if (action != ACTIONS.TICK):
		print("Action: %s, State: %s" % [str(ACTIONS.keys()[action]), str(STATES.keys()[state.player_state])])
	match [action, state.player_state]:
		[ACTIONS.STAND, STATES.DASHING]:
			state.player_state = STATES.STANDING
			return state
		[ACTIONS.DASH, STATES.STANDING]:
			return handle_dash_action(state)
		[ACTIONS.JUMP, ..]:
			return state
			#return handle_dash_action(state)
		[ACTIONS.TICK, STATES.DASHING]:
			return handle_dashing(state)
		[ACTIONS.TICK, STATES.STANDING]:
			return handle_tick(state)
		[ACTIONS.TICK, STATES.DASHING]:
			return handle_tick(state)
		_:
			print_debug("Unsupported transition", str(ACTIONS.keys()[action]), str(STATES.keys()[state.player_state]))
			return state

func handle_tick(state):
	if (Input.is_action_just_pressed("dash")):
		print("handle_tick: dash")
		state = update(ACTIONS.DASH, state)
	if (Input.is_action_just_pressed("jump")):
		print("handle_tick: jump")
		state = update(ACTIONS.JUMP, state)
	return state

func handle_dashing(state):
	var velocity = state.current_direction * dash_speed
	var new_position = position + velocity * state.delta
	if (new_position.distance_to(state.targeted_position) + 16 < position.distance_to(state.targeted_position)):
		position = new_position
	else:
		position = state.targeted_position

	return state

func handle_dash_action(state):
	var gmp = get_global_mouse_position()
	state.targeted_position = gmp
	state.current_direction = state.targeted_position - position

	if (state.current_direction.length() < 16.0):
		state.player_state = STATES.STANDING
		return state

	if state.current_direction.x <= 0:
		animation_player.play("prepare_left_dash")
	else:
		animation_player.play("prepare_right_dash")
	return state


func handle_execute_dash_action(state):

	print(state.current_direction.x)
	if state.current_direction.x <= 0:
		animation_player.play("left_dash")
	else:
		animation_player.play("right_dash")

	state.player_state = STATES.DASHING
	state.current_direction = state.current_direction.normalized()
	dash_timer.start()
	return state


func _on_dash_timeout() -> void:
	state = update(ACTIONS.STAND, state)
	animation_player.play("idle")

#func _on_area_entered(area):
	#state = update(ACTIONS.STAND, state)


func _on_animation_finished(anim_name):
	match anim_name:
		"prepare_left_dash":
			handle_execute_dash_action(state)
		"prepare_right_dash":
			handle_execute_dash_action(state)
		"left_dash":
			animation_player.play("left_dash_recovery")
		"right_dash":
			animation_player.play("right_dash_recovery")
		_:
			return
