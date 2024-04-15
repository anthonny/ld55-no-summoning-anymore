extends Camera2D

@export var random_strength_base: float = 25.0
@export var shake_fade: float = 5.0

enum STATES {IDLE, SHAKING}
enum ACTIONS {TICK, SHAKE, STOP}

var _rng = RandomNumberGenerator.new()
var _shake_strength: float = 0.0

var state = {}

func _ready():
	state = {
		"camera_state": STATES.IDLE,
		"delta": 0
	}
	SignalManager.shake_screen.connect(_handle_shake)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	state.delta = delta
	update(ACTIONS.TICK, state)
	pass

func update(action: ACTIONS, state):
	#if (action != ACTIONS.TICK):
		#print("Action: %s, State: %s" % [str(ACTIONS.keys()[action]), str(STATES.keys()[state.camera_state])])
	match [action, state.camera_state]:
		[ACTIONS.SHAKE, STATES.IDLE]:
			reset_shake()
			state.camera_state = STATES.SHAKING
			return state
		[ACTIONS.TICK, STATES.SHAKING]:
			if (int(_shake_strength) <= 0):
				state.camera_state = STATES.IDLE
			else:
				_shake_strength = lerpf(_shake_strength, 0, shake_fade * state.delta)
				offset = Vector2(0, _rng.randf_range(-_shake_strength, _shake_strength))

			return state
		_:
			return state


func _handle_shake():
	state = update(ACTIONS.SHAKE, state)

func reset_shake():
	_shake_strength = random_strength_base
