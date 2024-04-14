extends Area2D

enum STATES {STANDING, PREPARE_LEFT_DASHING, LEFT_DASHING, RECOVER_LEFT_DASHING,PREPARE_RIGHT_DASHING, RIGHT_DASHING, RECOVER_RIGHT_DASHING, JUMPING}
enum ACTIONS {TICK, STAND, DASH, JUMP}

@export var dash_speed: float = 1500.0
@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D

var state = {}

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
		[ACTIONS.STAND, STATES.LEFT_DASHING]:
			state.player_state = STATES.STANDING
			return state
		[ACTIONS.STAND, STATES.RIGHT_DASHING]:
			state.player_state = STATES.STANDING
			return state
		[ACTIONS.STAND, STATES.JUMPING]:
			animation_player.play("idle")
			state.player_state = STATES.STANDING
			return state
		[ACTIONS.DASH, STATES.STANDING]:
			return handle_dash_action(state)
		[ACTIONS.DASH, STATES.PREPARE_LEFT_DASHING]:
			animation_player.play("left_dash")
			state.player_state = STATES.LEFT_DASHING
			state.current_direction = state.current_direction.normalized()
			return state
		[ACTIONS.DASH, STATES.PREPARE_RIGHT_DASHING]:
			animation_player.play("right_dash")
			state.player_state = STATES.RIGHT_DASHING
			state.current_direction = state.current_direction.normalized()
			return state
		[ACTIONS.DASH, STATES.LEFT_DASHING]:
			state.player_state = STATES.RECOVER_LEFT_DASHING
			animation_player.play("recover_left_dash")
			return state
		[ACTIONS.DASH, STATES.RIGHT_DASHING]:
			state.player_state = STATES.RECOVER_RIGHT_DASHING
			animation_player.play("recover_right_dash")
			return state
		[ACTIONS.DASH, STATES.RECOVER_LEFT_DASHING]:
			state.player_state = STATES.STANDING
			animation_player.play("idle")
			return state
		[ACTIONS.DASH, STATES.RECOVER_RIGHT_DASHING]:
			state.player_state = STATES.STANDING
			animation_player.play("idle")
			return state
		[ACTIONS.JUMP, STATES.STANDING]:
			animation_player.play("jump")
			state.player_state = STATES.JUMPING
			return state
		[ACTIONS.JUMP, STATES.RECOVER_LEFT_DASHING]:
			animation_player.play("jump")
			state.player_state = STATES.JUMPING
			return state
		[ACTIONS.JUMP, STATES.RECOVER_RIGHT_DASHING]:
			animation_player.play("jump")
			state.player_state = STATES.JUMPING
			return state
		[ACTIONS.JUMP, ..]:
			return state
			#return handle_dash_action(state)
		[ACTIONS.TICK, STATES.LEFT_DASHING]:
			return handle_dashing(state)
		[ACTIONS.TICK, STATES.RIGHT_DASHING]:
			return handle_dashing(state)
		[ACTIONS.TICK, STATES.STANDING]:
			return handle_tick(state)
		[ACTIONS.TICK, STATES.LEFT_DASHING]:
			return handle_tick(state)
		[ACTIONS.TICK, STATES.RIGHT_DASHING]:
			return handle_tick(state)
		[ACTIONS.TICK, STATES.PREPARE_LEFT_DASHING]:
			return state
		[ACTIONS.TICK, STATES.PREPARE_RIGHT_DASHING]:
			return state
		[ACTIONS.TICK, STATES.RECOVER_LEFT_DASHING]:
			return handle_tick(state)
		[ACTIONS.TICK, STATES.RECOVER_RIGHT_DASHING]:
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
		if (state.player_state == STATES.LEFT_DASHING):
			state.player_state = STATES.RECOVER_LEFT_DASHING
			animation_player.play("recover_left_dash")
		elif (state.player_state == STATES.RIGHT_DASHING):
			state.player_state = STATES.RECOVER_RIGHT_DASHING
			animation_player.play("recover_right_dash")

	return state

func handle_dash_action(state):
	var gmp = get_global_mouse_position()
	state.targeted_position = gmp
	state.current_direction = state.targeted_position - position

	if (state.current_direction.length() < 16.0):
		state.player_state = STATES.STANDING
		return state

	if state.current_direction.x <= 0:
		state.player_state = STATES.PREPARE_LEFT_DASHING
		animation_player.play("prepare_left_dash")
	else:
		state.player_state = STATES.PREPARE_RIGHT_DASHING
		animation_player.play("prepare_right_dash")

	return state


#func _on_area_entered(area):
	#state = update(ACTIONS.STAND, state)


func _on_animation_finished(anim_name):
	if (anim_name.begins_with("prepare_")):
		state = update(ACTIONS.DASH, state)
	if (anim_name.begins_with("recover_")):
		state = update(ACTIONS.DASH, state)
	if (anim_name =="jump"):
		state = update(ACTIONS.STAND, state)

