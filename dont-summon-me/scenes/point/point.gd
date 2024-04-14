extends Area2D

enum STATES {HIDDEN, APPEARING, IDLE_STEP_1, STEP_1, IDLE_STEP_2, STEP_2, IDLE_STEP_3, STEP_3, IDLE_STEP_4, STEP_4, ACTIVE, VALIDATED, LOCKED}
enum ACTIONS {TICK, APPEARS, DELAY_RUN_STEP_1, RUN_STEP_1, DELAY_RUN_STEP_2, RUN_STEP_2, DELAY_RUN_STEP_3, RUN_STEP_3, DELAY_RUN_STEP_4, RUN_STEP_4, RUN_ACTIVE, EVALUATE_RESULT, RUN_LOCKED, VALIDATE}

@export var pop_delay: float
@export var interval: float = 0.20 #0.02
@export var locked_delay: float = 1.0

signal locked
signal validated

@onready var sequence_timer = $SequenceTimer
@onready var animation_player = $AnimationPlayer
@onready var validate_player = $Sounds/ValidatePlayer
@onready var locked_player = $Sounds/LockedPlayer
@onready var portal_player = $Sounds/PortalPlayer
@onready var portal_open_player = $Sounds/PortalOpenPlayer

var state = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = true
	state = {
		"point_state": STATES.HIDDEN,
		"delta": 0.0
	}
	sequence_timer.wait_time = pop_delay
	sequence_timer.start()
	sequence_timer.wait_time = interval

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	state.delta = delta
	state = update(ACTIONS.TICK, state)

func update(action: ACTIONS, state):
	if (action != ACTIONS.TICK):
		print("Action: %s, State: %s" % [str(ACTIONS.keys()[action]), str(STATES.keys()[state.point_state])])
	match [action, state.point_state]:
		[ACTIONS.APPEARS, STATES.HIDDEN]:
			state.point_state = STATES.APPEARING
			animation_player.play("appears")
			return state
		[ACTIONS.DELAY_RUN_STEP_1, STATES.APPEARING]:
			state.point_state = STATES.IDLE_STEP_1
			sequence_timer.start()
			return state
		[ACTIONS.RUN_STEP_1, STATES.IDLE_STEP_1]:
			state.point_state = STATES.STEP_1
			portal_player.play()
			animation_player.play("first_step")
			return state
		[ACTIONS.DELAY_RUN_STEP_2, STATES.STEP_1]:
			state.point_state = STATES.IDLE_STEP_2
			sequence_timer.start()
			return state
		[ACTIONS.RUN_STEP_2, STATES.IDLE_STEP_2]:
			state.point_state = STATES.STEP_2
			portal_player.play()
			animation_player.play("second_step")
			return state
		[ACTIONS.DELAY_RUN_STEP_3, STATES.STEP_2]:
			state.point_state = STATES.IDLE_STEP_3
			sequence_timer.start()
			return state
		[ACTIONS.RUN_STEP_3, STATES.IDLE_STEP_3]:
			state.point_state = STATES.STEP_3
			portal_player.play()
			animation_player.play("third_step")
			return state
		[ACTIONS.DELAY_RUN_STEP_4, STATES.STEP_3]:
			state.point_state = STATES.IDLE_STEP_4
			sequence_timer.start()
			return state
		[ACTIONS.RUN_STEP_4, STATES.IDLE_STEP_4]:
			state.point_state = STATES.STEP_4
			portal_open_player.play()
			animation_player.play("fourth_step")
			return state
		[ACTIONS.RUN_ACTIVE, STATES.STEP_4]:
			state.point_state = STATES.ACTIVE
			animation_player.play("active")
			sequence_timer.wait_time = locked_delay
			sequence_timer.start()
			return state
		[ACTIONS.EVALUATE_RESULT, STATES.ACTIVE]:
			state.point_state = STATES.LOCKED
			animation_player.play("locked")
			locked_player.play()
			locked.emit()
			return state
		[ACTIONS.VALIDATE, STATES.ACTIVE]:
			state.point_state = STATES.VALIDATED
			animation_player.play("validated")
			validate_player.play()
			validated.emit()
			return state
		_:
			return state


func _on_animation_finished(anim_name):
	match anim_name:
		"appears":
			return  update(ACTIONS.DELAY_RUN_STEP_1, state)
		"first_step":
			return  update(ACTIONS.DELAY_RUN_STEP_2, state)
		"second_step":
			return  update(ACTIONS.DELAY_RUN_STEP_3, state)
		"third_step":
			return  update(ACTIONS.DELAY_RUN_STEP_4, state)
		"fourth_step":
			return  update(ACTIONS.RUN_ACTIVE, state)
		_ :
			return state

func _on_sequence_timer_timeout():
	var next_action = ACTIONS.RUN_LOCKED if state.point_state == STATES.LOCKED else next_action_from_state(state)
	state = update(next_action, state)

func next_action_from_state(state) -> ACTIONS:
	match(state.point_state):
		STATES.HIDDEN:
			return ACTIONS.APPEARS
		STATES.APPEARING:
			return ACTIONS.DELAY_RUN_STEP_1
		STATES.IDLE_STEP_1:
			return ACTIONS.RUN_STEP_1
		STATES.IDLE_STEP_2:
			return ACTIONS.RUN_STEP_2
		STATES.IDLE_STEP_3:
			return ACTIONS.RUN_STEP_3
		STATES.IDLE_STEP_4:
			return ACTIONS.RUN_STEP_4
		STATES.ACTIVE:
			return ACTIONS.EVALUATE_RESULT
		_ :
			return ACTIONS.TICK

func validate():
	state = update(ACTIONS.VALIDATE, state)
