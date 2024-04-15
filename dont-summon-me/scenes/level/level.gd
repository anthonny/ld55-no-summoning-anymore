extends Area2D
class_name Level

enum STATES {IDLE, WON, LOST}
enum ACTIONS {TICK, VALIDATE_POINT, LOCK_POINT}

@export var point_scene: PackedScene

@onready var markers = $Markers

var state = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	state = {
		"validated_count": 0,
		"locked_count": 0,
		"level_state": STATES.IDLE,
		"nb_points": len(markers.get_children())
	}

	if not point_scene:
		printerr("No point scene associated")
	var markers = markers.get_children()
	markers.shuffle()
	for point_index in len(markers):
		var new_point = point_scene.instantiate()
		new_point.pop_delay = (point_index + 1) * 1.5
		new_point.position = markers[point_index].position
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
			return handle_score(state)
		[ACTIONS.LOCK_POINT, STATES.IDLE]:
			state.locked_count += 1
			return handle_score(state)
		[ACTIONS.TICK, ..]:
			return state
		_ :
			return state

func handle_score(state):
	if (state.validated_count == state.nb_points):
		state.level_state = STATES.WON
		SignalManager.level_validated.emit()
	elif (state.validated_count + state.locked_count == state.nb_points):
		state.level_state = STATES.LOST
		SignalManager.level_lost.emit()

	return state

func _on_point_validated():
	state = update(ACTIONS.VALIDATE_POINT, state)
	SignalManager.point_validated.emit()

func _on_point_locked():
	state = update(ACTIONS.LOCK_POINT, state)
	SignalManager.point_locked.emit()

