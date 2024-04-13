extends Area2D


enum PLAYER_STATE {STANDING, DASHING, JUMPING}
enum ACTIONS {TICK, STAND, DASH, JUMP}

@export var dash_speed: float = 1500.0

var state = {}

@onready var dash_timer = $DashTimer
@onready var sprite_2d = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	state = {
		"delta": 0.0,
		"player_state": PLAYER_STATE.STANDING,
		"targeted_position": position,
		"current_direction": Vector2(0, 0)
	}


func _physics_process(delta):
	state.delta = delta
	state = update(ACTIONS.TICK, state)


func update(action: ACTIONS, state):
	match [action, state.player_state]:
		[ACTIONS.STAND, PLAYER_STATE.DASHING]:
			print("ACTIONS.STAND, PLAYER_STATE.DASHING")
			state.player_state = PLAYER_STATE.STANDING
			return state
		[ACTIONS.DASH, PLAYER_STATE.STANDING]:
			print("ACTIONS.DASH, PLAYER_STATE.STANDING")
			return handle_dash_action(state)
		[ACTIONS.TICK, PLAYER_STATE.DASHING]:
			print("ACTIONS.TICK, PLAYER_STATE.DASHING")
			return handle_dashing(state)
		[ACTIONS.TICK, PLAYER_STATE.STANDING]:
			if (Input.is_action_just_pressed("dash")):
				print("ACTIONS.TICK, PLAYER_STATE.STANDING: dash")
				state = update(ACTIONS.DASH, state)
			return state
		_:
			print_debug("Unsupported transition", str(ACTIONS.keys()[action]), str(PLAYER_STATE.keys()[state.player_state]))
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

	#print("current_direction", current_direction.length())
	if (state.current_direction.length() < 16.0):
		state.player_state = PLAYER_STATE.STANDING
		return state

	state.player_state = PLAYER_STATE.DASHING
	state.current_direction = state.current_direction.normalized()
	dash_timer.start()
	return state

func _on_dash_timeout() -> void:
	state = update(ACTIONS.STAND, state)


func _on_body_entered(body):
	print("collide")


func _on_area_entered(area):
	state = update(ACTIONS.STAND, state)
