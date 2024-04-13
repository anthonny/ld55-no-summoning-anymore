extends Area2D

enum STATES {HIDDEN, APPEARING, IDLE_STEP_1, STEP_1, IDLE_STEP_2, STEP_2, IDLE_STEP_3, STEP_3, IDLE_ACTIVE, ACTIVE, LOCKED}
enum ACTIONS {TICK, APPEARS, DELAY_RUN_STEP_1, RUN_STEP_1, DELAY_RUN_STEP_2, RUN_STEP_2, DELAY_RUN_STEP_3, RUN_STEP_3, DELAY_RUN_ACTIVE, RUN_ACTIVE, RUN_LOCKED}

@export var delay: float
@export var interval: float = 0.02
@export var forced_state: STATES

@onready var sequence_timer = $SequenceTimer
@onready var animation_player = $AnimationPlayer

var state = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = true
	state = {
		"point_state": STATES.HIDDEN,
		"delta": 0.0
	}
	sequence_timer.wait_time = delay
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
			animation_player.play("first_step")
			return state
		[ACTIONS.DELAY_RUN_STEP_2, STATES.STEP_1]:
			state.point_state = STATES.IDLE_STEP_2
			sequence_timer.start()
			return state
		[ACTIONS.RUN_STEP_2, STATES.IDLE_STEP_2]:
			state.point_state = STATES.STEP_2
			animation_player.play("second_step")
			return state
		[ACTIONS.DELAY_RUN_STEP_3, STATES.STEP_2]:
			state.point_state = STATES.IDLE_STEP_3
			sequence_timer.start()
			return state
		[ACTIONS.RUN_STEP_3, STATES.IDLE_STEP_3]:
			state.point_state = STATES.STEP_3
			animation_player.play("third_step")
			return state
		[ACTIONS.DELAY_RUN_ACTIVE, STATES.STEP_3]:
			state.point_state = STATES.IDLE_ACTIVE
			sequence_timer.start()
			return state
		[ACTIONS.RUN_ACTIVE, STATES.IDLE_ACTIVE]:
			state.point_state = STATES.ACTIVE
			animation_player.play("fourth_step")
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
			return  update(ACTIONS.DELAY_RUN_ACTIVE, state)
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
		STATES.IDLE_ACTIVE:
			return ACTIONS.RUN_ACTIVE
		_ :
			return ACTIONS.TICK
