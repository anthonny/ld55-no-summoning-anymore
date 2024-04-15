extends Area2D
class_name Level

enum STATES {IDLE, WON, SEMI_VICTORY, LOST}
enum ACTIONS {TICK, VALIDATE_POINT, LOCK_POINT, FINISH}

@export var point_scene: PackedScene
@export var delay_level_finished: float = 1.5

@onready var markers = $Markers
@onready var level_finished_timer = $LevelFinishedTimer

var state = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	state = {
		"validated_count": 0,
		"locked_count": 0,
		"level_state": STATES.IDLE,
		"nb_points": len(markers.get_children())
	}

	level_finished_timer.wait_time = delay_level_finished

	if not point_scene:
		printerr("No point scene associated")
	var rng = RandomNumberGenerator.new()
	var markers = markers.get_children()
	var nb_markers = len(markers)

	markers.sort_custom(func(a, b): return a.position.y < b.position.y)
	var pop_delays = range(nb_markers)

	for marker in markers:
		var pop_delay_index = pop_delays.pick_random()
		pop_delays = pop_delays.filter(func(a): return a != pop_delay_index)
		var new_point = point_scene.instantiate()
		new_point.pop_delay = (pop_delay_index + 1) * 1.5
		new_point.position = marker.position
		new_point.validated.connect(_on_point_validated)
		new_point.locked.connect(_on_point_locked)
		add_child(new_point)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	state = update(ACTIONS.TICK, state)

func update(action: ACTIONS, state):
	match [action, state.level_state]:
		[ACTIONS.VALIDATE_POINT, STATES.IDLE]:
			state.validated_count += 1
			SignalManager.point_validated.emit()
			SignalManager.shake_screen.emit()
			return handle_score(state)
		[ACTIONS.LOCK_POINT, STATES.IDLE]:
			state.locked_count += 1
			SignalManager.point_locked.emit()
			return handle_score(state)
		[ACTIONS.FINISH, STATES.LOST]:
			SignalManager.level_lost.emit()
			return state
		[ACTIONS.FINISH, STATES.WON]:
			SignalManager.level_won.emit()
			return state
		[ACTIONS.FINISH, STATES.SEMI_VICTORY]:
			SignalManager.level_semi_won.emit()
			return state
		[ACTIONS.TICK, ..]:
			return state
		_ :
			return state

func handle_score(state):

	if (state.validated_count == state.nb_points):
		state.level_state = STATES.WON
	elif (state.locked_count == state.nb_points):
		state.level_state = STATES.LOST
	elif (state.validated_count + state.locked_count == state.nb_points):
		state.level_state = STATES.SEMI_VICTORY

	if (state.level_state != STATES.IDLE):
		level_finished_timer.start()

	return state

func _on_point_validated():
	state = update(ACTIONS.VALIDATE_POINT, state)

func _on_point_locked():
	state = update(ACTIONS.LOCK_POINT, state)

func _on_level_finished():
	state = update(ACTIONS.FINISH, state)
